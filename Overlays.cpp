#include "Overlays.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QUrl>
#include <QtMath>

#include <limits>

Overlays::Overlays(QObject *parent)
    : QObject(parent)
{
}

QVariantList Overlays::noFlyZones() const
{
    // Expose parsed overlay geometry to QML via the noFlyZones property.
    return m_noFlyZones;
}

void Overlays::clearNoFlyZones()
{
    // Skip notifications when there is nothing to clear.
    if (m_noFlyZones.isEmpty()) {
        return;
    }

    // Clear both presentation data and geometry index so they stay in sync.
    m_noFlyZones.clear();
    m_engine.clearZones();
    emit noFlyZonesChanged();
}

bool Overlays::isPointInNoFlyZone(double lat, double lon) const
{
    return m_engine.isPointInNoFlyZone(lat, lon);
}

bool Overlays::doesLineSegmentCrossNoFlyZone(double lat1, double lon1, double lat2, double lon2) const
{
    return m_engine.doesLineSegmentCrossNoFlyZone(lat1, lon1, lat2, lon2);
}

double Overlays::distanceToNoFlyZoneMeters(double lat, double lon) const
{
    return m_engine.distanceToNoFlyZoneMeters(lat, lon);
}

bool Overlays::addPolygonZone(
    const QString &zoneId,
    const QJsonArray &polygonRings,
    const QJsonObject &properties,
    int polygonSuffix)
{
    // Build internal geometry first; invalid polygons are discarded.
    const NoFlyZoneGeometryEngine::NoFlyZoneData zoneData =
        NoFlyZoneGeometryEngine::NoFlyZoneData::fromGeoJsonPolygon(polygonRings, properties);
    if (!zoneData.outer.isValid()) {
        return false;
    }

    // Convert holes for QML rendering payload.
    QVariantList holePointLists;
    for (const NoFlyZoneGeometryEngine::ZoneRing &hole : zoneData.holes) {
        holePointLists.append(hole.toVariantPointList());
    }

    QVariantMap zone;
    zone["id"] = (polygonSuffix >= 0)
        ? QString("%1_%2").arg(zoneId).arg(polygonSuffix)
        : zoneId;
    zone["type"] = "polygon";
    zone["points"] = zoneData.outer.toVariantPointList();
    zone["holes"] = holePointLists;
    zone["label"] = properties.value("NAME").toString(properties.value("name").toString(zoneId));
    zone["airspace"] = properties.value("Airspace").toString();
    zone["reason"] = properties.value("Reason").toString();
    zone["state"] = properties.value("State").toString();
    zone["area"] = properties.value("Shape__Area").toDouble();

    // Keep display model and geometry index aligned by appending together.
    m_noFlyZones.append(zone);
    m_engine.addZone(zoneData);
    return true;
}

bool Overlays::addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties)
{
    // Unified geometry entry point for both Polygon and MultiPolygon features.
    const QString geometryType = geometry.value("type").toString();
    const QJsonArray coordinates = geometry.value("coordinates").toArray();

    if (geometryType == "Polygon") {
        return addPolygonZone(zoneId, coordinates, properties);
    }

    if (geometryType == "MultiPolygon") {
        bool addedAny = false;
        int polygonIndex = 0;

        // Treat each polygon member as an independent zone payload entry.
        for (const QJsonValue &polygonValue : coordinates) {
            if (!polygonValue.isArray()) {
                continue;
            }

            const QJsonArray polygonRings = polygonValue.toArray();
            if (addPolygonZone(zoneId, polygonRings, properties, polygonIndex)) {
                ++polygonIndex;
                addedAny = true;
            }
        }

        return addedAny;
    }

    return false;
}

bool Overlays::loadNoFlyZones(const QString &geoJsonPath)
{
    // Normalize common QML path forms so QFile can open them.
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

    // Parse GeoJSON root document.
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

    // Replace data atomically: keep previous snapshot for rollback on empty parse.
    const QVariantList existingZones = m_noFlyZones;
    m_noFlyZones.clear();
    m_engine.clearZones();

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

        addGeoJsonGeometry(zoneId, geometry, properties);
    }

    // Roll back if no usable geometry was parsed.
    if (m_noFlyZones.isEmpty()) {
        m_noFlyZones = existingZones;
        m_engine.clearZones();
        qWarning() << "[Overlays.cpp] No supported no-fly geometries were loaded.";
        return false;
    }

    emit noFlyZonesChanged();
    qDebug() << "[Overlays.cpp] Loaded no-fly zones:" << m_noFlyZones.size();
    return true;
}
