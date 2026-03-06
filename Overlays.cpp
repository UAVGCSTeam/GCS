#include "Overlays.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QUrl>

Overlays::Overlays(QObject *parent)
    : QObject(parent)
{
}

QVariantList Overlays::noFlyZones() const
{
    // Exposes the parsed no-fly-zone list to QML via Q_PROPERTY binding.
    return m_noFlyZones;
}

void Overlays::clearNoFlyZones()
{
    // Clears all loaded zones and notifies QML so the overlay is removed.
    if (m_noFlyZones.isEmpty()) {
        return;
    }

    m_noFlyZones.clear();
    emit noFlyZonesChanged();
}

QVariantList Overlays::buildPointListFromPolygonRing(const QJsonArray &ring) const
{
    // Converts one GeoJSON polygon ring ([[lon,lat], ...]) into
    // our internal QVariantList format: [{lat, lon}, ...].
    // Non-numeric or malformed points are skipped.
    QVariantList points;
    for (const QJsonValue &coordinateValue : ring) {
        if (!coordinateValue.isArray()) {
            continue;
        }

        const QJsonArray coordinate = coordinateValue.toArray();
        if (coordinate.size() < 2 || !coordinate[0].isDouble() || !coordinate[1].isDouble()) {
            continue;
        }

        const double longitude = coordinate[0].toDouble();
        const double latitude = coordinate[1].toDouble();

        QVariantMap point;
        point["lat"] = latitude;
        point["lon"] = longitude;
        points.append(point);
    }

    return points;
}

bool Overlays::addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties)
{
    // Converts a GeoJSON geometry object into one or more internal zone records.
    // Supported geometry types: Polygon and MultiPolygon.
    // Returns true if at least one zone was added.
    const QString geometryType = geometry.value("type").toString();
    const QJsonArray coordinates = geometry.value("coordinates").toArray();

    if (geometryType == "Polygon") {
        if (coordinates.isEmpty() || !coordinates[0].isArray()) {
            return false;
        }

        const QVariantList points = buildPointListFromPolygonRing(coordinates[0].toArray());
        if (points.size() < 3) {
            return false;
        }

        QVariantList holes;
        for (int ringIndex = 1; ringIndex < coordinates.size(); ++ringIndex) {
            if (!coordinates[ringIndex].isArray()) {
                continue;
            }

            const QVariantList holePoints = buildPointListFromPolygonRing(coordinates[ringIndex].toArray());
            if (holePoints.size() < 3) {
                continue;
            }

            holes.append(holePoints);
        }

        QVariantMap zone;
        zone["id"] = zoneId;
        zone["type"] = "polygon";
        zone["points"] = points;
        zone["holes"] = holes;
        zone["label"] = properties.value("NAME").toString(properties.value("name").toString(zoneId));
        zone["airspace"] = properties.value("Airspace").toString();
        zone["reason"] = properties.value("Reason").toString();
        zone["state"] = properties.value("State").toString();
        zone["area"] = properties.value("Shape__Area").toDouble();
        m_noFlyZones.append(zone);
        return true;
    }

    if (geometryType == "MultiPolygon") {
        bool addedAny = false;
        int polygonIndex = 0;

        for (const QJsonValue &polygonValue : coordinates) {
            if (!polygonValue.isArray()) {
                continue;
            }

            const QJsonArray polygon = polygonValue.toArray();
            if (polygon.isEmpty() || !polygon[0].isArray()) {
                continue;
            }

            const QVariantList points = buildPointListFromPolygonRing(polygon[0].toArray());
            if (points.size() < 3) {
                continue;
            }

            QVariantList holes;
            for (int ringIndex = 1; ringIndex < polygon.size(); ++ringIndex) {
                if (!polygon[ringIndex].isArray()) {
                    continue;
                }

                const QVariantList holePoints = buildPointListFromPolygonRing(polygon[ringIndex].toArray());
                if (holePoints.size() < 3) {
                    continue;
                }

                holes.append(holePoints);
            }

            QVariantMap zone;
            zone["id"] = QString("%1_%2").arg(zoneId).arg(polygonIndex++);
            zone["type"] = "polygon";
            zone["points"] = points;
            zone["holes"] = holes;
            zone["label"] = properties.value("NAME").toString(properties.value("name").toString(zoneId));
            zone["airspace"] = properties.value("Airspace").toString();
            zone["reason"] = properties.value("Reason").toString();
            zone["state"] = properties.value("State").toString();
            zone["area"] = properties.value("Shape__Area").toDouble();
            m_noFlyZones.append(zone);
            addedAny = true;
        }

        return addedAny;
    }

    return false;
}

bool Overlays::loadNoFlyZones(const QString &geoJsonPath)
{
    // Main entry point used by QML at startup (or manual reload) to parse
    // a GeoJSON file/resource and replace the current no-fly-zone dataset.
    // Accept common path styles from QML/resources and normalize to QFile-compatible format.
    QString resolvedPath = geoJsonPath;
    if (resolvedPath.startsWith("qrc:/")) {
        resolvedPath.replace(0, 4, ":");
    } else if (resolvedPath.startsWith("file:/")) {
        const QUrl url(resolvedPath);
        if (url.isLocalFile()) {
            resolvedPath = url.toLocalFile();
        }
    }

    QFile file(resolvedPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[Overlays.cpp] Unable to open no-fly GeoJSON:" << geoJsonPath << "resolved as" << resolvedPath;
        return false;
    }

    const QByteArray rawData = file.readAll();
    file.close();

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(rawData, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        qWarning() << "[Overlays.cpp] Invalid GeoJSON:" << parseError.errorString();
        return false;
    }

    const QJsonObject root = document.object();
    const QJsonArray features = root.value("features").toArray();

    int idCounter = 0;

    // Replace previous data on each load so the overlay reflects the latest source file.
    const QVariantList existingZones = m_noFlyZones;
    m_noFlyZones.clear();

    // Parse each GeoJSON feature into our simplified zone model used by QML.
    for (const QJsonValue &featureValue : features) {
        if (!featureValue.isObject()) {
            continue;
        }

        const QJsonObject feature = featureValue.toObject();
        const QJsonObject geometry = feature.value("geometry").toObject();
        const QJsonObject properties = feature.value("properties").toObject();
        if (geometry.isEmpty()) {
            continue;
        }

        QString zoneId = properties.value("OBJECTID").toVariant().toString();
        if (zoneId.isEmpty()) {
            zoneId = QString("zone_%1").arg(idCounter++);
        }

        // addGeoJsonGeometry() handles Polygon and MultiPolygon conversion to point lists.
        const int beforeCount = m_noFlyZones.size();
        addGeoJsonGeometry(zoneId, geometry, properties);
        if (m_noFlyZones.size() == beforeCount) {
            continue;
        }
    }

    // If parsing produced nothing, restore previous data to avoid blanking a working overlay.
    if (m_noFlyZones.isEmpty()) {
        m_noFlyZones = existingZones;
        qWarning() << "[Overlays.cpp] No supported no-fly geometries were loaded.";
        return false;
    }

    // Notify QML bindings so MapItemView refreshes the rendered polygons.
    emit noFlyZonesChanged();
    qDebug() << "[Overlays.cpp] Loaded no-fly zones:" << m_noFlyZones.size();
    return !m_noFlyZones.isEmpty();
}
