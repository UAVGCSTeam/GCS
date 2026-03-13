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
    m_zoneIndex.clear();
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

ZoneRing Overlays::buildZoneRing(const QJsonArray &ring) const
{
    ZoneRing zr;
    for (const QJsonValue &v : ring) {
        if (!v.isArray()) continue;
        const QJsonArray c = v.toArray();
        if (c.size() < 2 || !c[0].isDouble() || !c[1].isDouble()) continue;
        zr.points.append(QPointF(c[0].toDouble(), c[1].toDouble())); // x=lon, y=lat
    }
    return zr;
}

bool Overlays::pointInRing(double lat, double lon, const ZoneRing &ring)
{
    // Standard even-odd ray-casting test against one polygon ring.
    // Coordinates are stored as QPointF(x=lon, y=lat).
    bool inside = false;
    const int n = ring.points.size();
    int j = n - 1;
    for (int i = 0; i < n; ++i) {
        const double xi = ring.points[i].x(), yi = ring.points[i].y();
        const double xj = ring.points[j].x(), yj = ring.points[j].y();
        if (((yi > lat) != (yj > lat)) &&
            (lon < (xj - xi) * (lat - yi) / (yj - yi) + xi))
            inside = !inside;
        j = i;
    }
    return inside;
}

bool Overlays::isPointInNoFlyZone(double lat, double lon) const
{
    // Fast path: scan pre-built native index instead of iterating QVariant data from QML.
    for (const NoFlyZoneData &zone : m_zoneIndex) {
        if (zone.skipHitTest) continue;
        // Bounding-box pre-filter: skip full ray-cast if outside the AABB
        if (lat < zone.minLat || lat > zone.maxLat || lon < zone.minLon || lon > zone.maxLon)
            continue;
        // Must be inside outer ring and outside every hole to be considered blocked.
        if (!pointInRing(lat, lon, zone.outer)) continue;
        bool inHole = false;
        for (const ZoneRing &hole : zone.holes) {
            if (pointInRing(lat, lon, hole)) { inHole = true; break; }
        }
        if (!inHole) return true;
    }
    return false;
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

        // Build index entry for fast hit-testing
        {
            NoFlyZoneData idx;
            idx.outer = buildZoneRing(coordinates[0].toArray());
            // Keep behavior aligned with map rendering: offshore 12NM band is border-only.
            idx.skipHitTest = properties.value("Airspace").toString()
                .contains("Airspace over waters from US shore to line (12NM)");
            double minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
            for (const QPointF &p : idx.outer.points) {
                if (p.y() < minLat) minLat = p.y();
                if (p.y() > maxLat) maxLat = p.y();
                if (p.x() < minLon) minLon = p.x();
                if (p.x() > maxLon) maxLon = p.x();
            }
            idx.minLat = minLat; idx.maxLat = maxLat;
            idx.minLon = minLon; idx.maxLon = maxLon;
            for (int ringIndex = 1; ringIndex < coordinates.size(); ++ringIndex) {
                if (!coordinates[ringIndex].isArray()) continue;
                ZoneRing hole = buildZoneRing(coordinates[ringIndex].toArray());
                if (hole.points.size() >= 3)
                    idx.holes.append(hole);
            }
            m_zoneIndex.append(idx);
        }
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

            // Build index entry for fast hit-testing
            {
                NoFlyZoneData idx;
                idx.outer = buildZoneRing(polygon[0].toArray());
                idx.skipHitTest = properties.value("Airspace").toString()
                    .contains("Airspace over waters from US shore to line (12NM)");
                double minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
                for (const QPointF &p : idx.outer.points) {
                    if (p.y() < minLat) minLat = p.y();
                    if (p.y() > maxLat) maxLat = p.y();
                    if (p.x() < minLon) minLon = p.x();
                    if (p.x() > maxLon) maxLon = p.x();
                }
                idx.minLat = minLat; idx.maxLat = maxLat;
                idx.minLon = minLon; idx.maxLon = maxLon;
                for (int ringIndex = 1; ringIndex < polygon.size(); ++ringIndex) {
                    if (!polygon[ringIndex].isArray()) continue;
                    ZoneRing hole = buildZoneRing(polygon[ringIndex].toArray());
                    if (hole.points.size() >= 3)
                        idx.holes.append(hole);
                }
                m_zoneIndex.append(idx);
            }
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
    m_zoneIndex.clear();

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
