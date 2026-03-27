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

bool Overlays::lineSegmentIntersectSegment(const QPointF &p1, const QPointF &p2, const QPointF &p3, const QPointF &p4)
{
    // Test if line segment p1-p2 intersects line segment p3-p4 using orientation method.
    // This approach checks orientation of ordered triplets to determine intersection.

    auto orientation = [](const QPointF &p, const QPointF &q, const QPointF &r) -> int {
        // Find orientation of ordered triplet (p, q, r).
        // Returns 0 if collinear, 1 if clockwise, 2 if counterclockwise.
        double val = (q.y() - p.y()) * (r.x() - q.x()) - (q.x() - p.x()) * (r.y() - q.y());
        if (qAbs(val) < 1e-12) return 0;  // collinear
        return (val > 0) ? 1 : 2;
    };

    auto onSegment = [](const QPointF &p, const QPointF &q, const QPointF &r) -> bool {
        // Check if point q lies on segment pr (assumes p, q, r are collinear).
        return q.x() <= qMax(p.x(), r.x()) && q.x() >= qMin(p.x(), r.x()) &&
               q.y() <= qMax(p.y(), r.y()) && q.y() >= qMin(p.y(), r.y());
    };

    int o1 = orientation(p1, p2, p3);
    int o2 = orientation(p1, p2, p4);
    int o3 = orientation(p3, p4, p1);
    int o4 = orientation(p3, p4, p2);

    // General case: segments intersect if orientations differ
    if (o1 != o2 && o3 != o4)
        return true;

    // Special cases: collinear points
    if (o1 == 0 && onSegment(p1, p3, p2)) return true;
    if (o2 == 0 && onSegment(p1, p4, p2)) return true;
    if (o3 == 0 && onSegment(p3, p1, p4)) return true;
    if (o4 == 0 && onSegment(p3, p2, p4)) return true;

    return false;
}

bool Overlays::lineSegmentCrossesRing(double lat1, double lon1, double lat2, double lon2, const ZoneRing &ring)
{
    // Test if line segment from (lat1, lon1) to (lat2, lon2) crosses any edge of the ring.
    // Uses simple cartographic projection (lon -> x, lat -> y) for small geographic areas.

    const QPointF p1(lon1, lat1);
    const QPointF p2(lon2, lat2);

    const int n = ring.points.size();
    for (int i = 0, j = n - 1; i < n; j = i++) {
        // Each edge of the ring: from ring[j] to ring[i]
        const QPointF p3 = ring.points[j];
        const QPointF p4 = ring.points[i];
        if (lineSegmentIntersectSegment(p1, p2, p3, p4))
            return true;
    }
    return false;
}

bool Overlays::doesLineSegmentCrossNoFlyZone(double lat1, double lon1, double lat2, double lon2) const
{
    // Check if the path from (lat1, lon1) to (lat2, lon2) crosses any no-fly-zone boundary.
    // Uses bounding-box prefiltering to skip zones that cannot intersect the segment AABB.

    if (m_zoneIndex.isEmpty())
        return false;

    // Compute AABB of the segment for quick zone rejection
    const double segMinLat = qMin(lat1, lat2);
    const double segMaxLat = qMax(lat1, lat2);
    const double segMinLon = qMin(lon1, lon2);
    const double segMaxLon = qMax(lon1, lon2);

    for (const NoFlyZoneData &zone : m_zoneIndex) {
        if (zone.skipHitTest) continue;

        // Quick AABB rejection: skip if segment and zone do not overlap geographically
        if (segMaxLat < zone.minLat || segMinLat > zone.maxLat ||
            segMaxLon < zone.minLon || segMinLon > zone.maxLon)
            continue;

        // Test against outer ring boundary
        if (lineSegmentCrossesRing(lat1, lon1, lat2, lon2, zone.outer))
            return true;

        // Test against hole boundaries (exit holes don't block, but entry/exit does)
        for (const ZoneRing &hole : zone.holes) {
            if (lineSegmentCrossesRing(lat1, lon1, lat2, lon2, hole))
                return true;
        }
    }

    return false;
}

QPointF Overlays::projectToMeters(double lat, double lon, double refLat, double refLon)
{
    // Equirectangular local projection around refLat/refLon for fast small-area distances.
    const double metersPerDegLat = 111320.0;
    const double metersPerDegLon = 111320.0 * qCos(qDegreesToRadians(refLat));
    return QPointF((lon - refLon) * metersPerDegLon, (lat - refLat) * metersPerDegLat);
}

double Overlays::distancePointToSegmentMeters(const QPointF &p, const QPointF &a, const QPointF &b)
{
    const double abx = b.x() - a.x();
    const double aby = b.y() - a.y();
    const double apx = p.x() - a.x();
    const double apy = p.y() - a.y();
    const double ab2 = abx * abx + aby * aby;
    if (ab2 <= 1e-12) {
        const double dx = p.x() - a.x();
        const double dy = p.y() - a.y();
        return qSqrt(dx * dx + dy * dy);
    }

    double t = (apx * abx + apy * aby) / ab2;
    t = qBound(0.0, t, 1.0);

    const double cx = a.x() + t * abx;
    const double cy = a.y() + t * aby;
    const double dx = p.x() - cx;
    const double dy = p.y() - cy;
    return qSqrt(dx * dx + dy * dy);
}

double Overlays::distanceToRingMeters(double lat, double lon, const ZoneRing &ring)
{
    const int n = ring.points.size();
    if (n < 2) {
        return std::numeric_limits<double>::infinity();
    }

    const QPointF p = projectToMeters(lat, lon, lat, lon);
    double minDistance = std::numeric_limits<double>::infinity();

    for (int i = 0, j = n - 1; i < n; j = i++) {
        const QPointF a = projectToMeters(ring.points[j].y(), ring.points[j].x(), lat, lon);
        const QPointF b = projectToMeters(ring.points[i].y(), ring.points[i].x(), lat, lon);
        const double d = distancePointToSegmentMeters(p, a, b);
        if (d < minDistance) {
            minDistance = d;
        }
    }

    return minDistance;
}

double Overlays::distanceToNoFlyZoneMeters(double lat, double lon) const
{
    // Workflow entrypoint for proximity monitoring:
    // 1) quick skip for empty index, 2) per-zone prune via AABB lower bound,
    // 3) exact edge distance only for promising candidates.
    if (m_zoneIndex.isEmpty()) {
        return -1.0;
    }

    const double metersPerDegLat = 111320.0;
    const double metersPerDegLon = 111320.0 * qCos(qDegreesToRadians(lat));
    double minDistance = std::numeric_limits<double>::infinity();

    for (const NoFlyZoneData &zone : m_zoneIndex) {
        if (zone.skipHitTest) {
            continue;
        }

        // If the point is truly inside a restricted area (and not inside a hole),
        // proximity is zero so callers can treat it as immediate danger.
        const bool insideOuter = pointInRing(lat, lon, zone.outer);
        if (insideOuter) {
            bool inHole = false;
            for (const ZoneRing &hole : zone.holes) {
                if (pointInRing(lat, lon, hole)) {
                    inHole = true;
                    break;
                }
            }
            if (!inHole) {
                return 0.0;
            }
        }

        // Cheap lower bound distance to the zone AABB for pruning exact edge checks.
        const double dLat = (lat < zone.minLat) ? (zone.minLat - lat)
                         : (lat > zone.maxLat) ? (lat - zone.maxLat)
                         : 0.0;
        const double dLon = (lon < zone.minLon) ? (zone.minLon - lon)
                         : (lon > zone.maxLon) ? (lon - zone.maxLon)
                         : 0.0;
        const double lowerBound = qSqrt(dLat * dLat * metersPerDegLat * metersPerDegLat
                                      + dLon * dLon * metersPerDegLon * metersPerDegLon);
        if (lowerBound >= minDistance) {
            continue;
        }

        // Exact geometry distance against the outer ring and hole rings.
        double zoneDistance = distanceToRingMeters(lat, lon, zone.outer);
        for (const ZoneRing &hole : zone.holes) {
            zoneDistance = qMin(zoneDistance, distanceToRingMeters(lat, lon, hole));
        }

        if (zoneDistance < minDistance) {
            minDistance = zoneDistance;
        }
    }

    // Returns -1 when no eligible zone contributed a finite distance.
    return std::isfinite(minDistance) ? minDistance : -1.0;
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
