#include "NoFlyZoneGeometryEngine.h"

#include <QJsonValue>
#include <QtMath>

#include <limits>

bool NoFlyZoneGeometryEngine::GeometryUtils::lineSegmentIntersectSegment(
    const QPointF &p1,
    const QPointF &p2,
    const QPointF &p3,
    const QPointF &p4)
{
    // Orientation test identifies relative turning direction of 3 ordered points.
    auto orientation = [](const QPointF &p, const QPointF &q, const QPointF &r) -> int {
        const double value = (q.y() - p.y()) * (r.x() - q.x()) - (q.x() - p.x()) * (r.y() - q.y());
        if (qAbs(value) < 1e-12) {
            return 0;
        }
        return (value > 0) ? 1 : 2;
    };

    // Point-on-segment test used by collinear edge cases.
    auto onSegment = [](const QPointF &p, const QPointF &q, const QPointF &r) -> bool {
        return q.x() <= qMax(p.x(), r.x()) && q.x() >= qMin(p.x(), r.x())
            && q.y() <= qMax(p.y(), r.y()) && q.y() >= qMin(p.y(), r.y());
    };

    const int o1 = orientation(p1, p2, p3);
    const int o2 = orientation(p1, p2, p4);
    const int o3 = orientation(p3, p4, p1);
    const int o4 = orientation(p3, p4, p2);

    // General intersection case.
    if (o1 != o2 && o3 != o4) {
        return true;
    }

    // Collinear special cases where segments still touch.
    if (o1 == 0 && onSegment(p1, p3, p2)) return true;
    if (o2 == 0 && onSegment(p1, p4, p2)) return true;
    if (o3 == 0 && onSegment(p3, p1, p4)) return true;
    if (o4 == 0 && onSegment(p3, p2, p4)) return true;

    return false;
}

QPointF NoFlyZoneGeometryEngine::GeometryUtils::projectToMeters(double lat, double lon, double refLat, double refLon)
{
    // Local equirectangular projection centered at refLat/refLon.
    // Accurate enough for short no-fly-zone proximity checks.
    const double metersPerDegLat = 111320.0;
    const double metersPerDegLon = 111320.0 * qCos(qDegreesToRadians(refLat));
    return QPointF((lon - refLon) * metersPerDegLon, (lat - refLat) * metersPerDegLat);
}

double NoFlyZoneGeometryEngine::GeometryUtils::distancePointToSegmentMeters(
    const QPointF &p,
    const QPointF &a,
    const QPointF &b)
{
    // Vector projection of AP onto AB, clamped to the segment endpoints.
    const double abx = b.x() - a.x();
    const double aby = b.y() - a.y();
    const double apx = p.x() - a.x();
    const double apy = p.y() - a.y();
    const double ab2 = abx * abx + aby * aby;

    // Degenerate segment: treat as point distance.
    if (ab2 <= 1e-12) {
        const double dx = p.x() - a.x();
        const double dy = p.y() - a.y();
        return qSqrt(dx * dx + dy * dy);
    }

    double t = (apx * abx + apy * aby) / ab2;
    t = qBound(0.0, t, 1.0);

    const double closestX = a.x() + t * abx;
    const double closestY = a.y() + t * aby;
    const double dx = p.x() - closestX;
    const double dy = p.y() - closestY;
    return qSqrt(dx * dx + dy * dy);
}

NoFlyZoneGeometryEngine::ZoneRing NoFlyZoneGeometryEngine::ZoneRing::fromGeoJsonRing(const QJsonArray &ring)
{
    // Parse one GeoJSON ring: each coordinate is [lon, lat].
    // Invalid coordinates are ignored to keep parsing resilient.
    ZoneRing zoneRing;
    for (const QJsonValue &value : ring) {
        if (!value.isArray()) {
            continue;
        }

        const QJsonArray coordinate = value.toArray();
        if (coordinate.size() < 2 || !coordinate[0].isDouble() || !coordinate[1].isDouble()) {
            continue;
        }

        zoneRing.points.append(QPointF(coordinate[0].toDouble(), coordinate[1].toDouble()));
    }

    return zoneRing;
}

QVariantList NoFlyZoneGeometryEngine::ZoneRing::toVariantPointList() const
{
    // Convert internal points to QML-friendly {lat, lon} maps.
    QVariantList pointList;
    for (const QPointF &point : points) {
        QVariantMap variantPoint;
        variantPoint["lat"] = point.y();
        variantPoint["lon"] = point.x();
        pointList.append(variantPoint);
    }
    return pointList;
}

bool NoFlyZoneGeometryEngine::ZoneRing::isValid() const
{
    // Minimum vertices for an area-bearing polygon ring.
    return points.size() >= 3;
}

bool NoFlyZoneGeometryEngine::ZoneRing::contains(double lat, double lon) const
{
    // Guard against malformed rings before running ray casting.
    if (!isValid()) {
        return false;
    }

    // Even-odd ray-casting test in lon/lat space.
    bool inside = false;
    const int pointCount = points.size();
    int previousIndex = pointCount - 1;

    for (int index = 0; index < pointCount; ++index) {
        const double xi = points[index].x();
        const double yi = points[index].y();
        const double xj = points[previousIndex].x();
        const double yj = points[previousIndex].y();

        if (((yi > lat) != (yj > lat))
            && (lon < (xj - xi) * (lat - yi) / (yj - yi) + xi)) {
            inside = !inside;
        }

        previousIndex = index;
    }

    return inside;
}

bool NoFlyZoneGeometryEngine::ZoneRing::crossesSegment(double lat1, double lon1, double lat2, double lon2) const
{
    // No edges means no possible intersection.
    if (!isValid()) {
        return false;
    }

    const QPointF segmentStart(lon1, lat1);
    const QPointF segmentEnd(lon2, lat2);

    // Test query segment against each ring edge.
    const int pointCount = points.size();
    for (int index = 0, previousIndex = pointCount - 1; index < pointCount; previousIndex = index++) {
        if (GeometryUtils::lineSegmentIntersectSegment(segmentStart, segmentEnd, points[previousIndex], points[index])) {
            return true;
        }
    }

    return false;
}

double NoFlyZoneGeometryEngine::ZoneRing::distanceToBoundaryMeters(double lat, double lon) const
{
    // Needs at least one edge to produce a finite boundary distance.
    const int pointCount = points.size();
    if (pointCount < 2) {
        return std::numeric_limits<double>::infinity();
    }

    // Compute minimum point-to-edge distance in locally projected meters.
    const QPointF queryPoint = GeometryUtils::projectToMeters(lat, lon, lat, lon);
    double minDistance = std::numeric_limits<double>::infinity();

    for (int index = 0, previousIndex = pointCount - 1; index < pointCount; previousIndex = index++) {
        const QPointF edgeStart = GeometryUtils::projectToMeters(points[previousIndex].y(), points[previousIndex].x(), lat, lon);
        const QPointF edgeEnd = GeometryUtils::projectToMeters(points[index].y(), points[index].x(), lat, lon);
        const double distance = GeometryUtils::distancePointToSegmentMeters(queryPoint, edgeStart, edgeEnd);
        minDistance = qMin(minDistance, distance);
    }

    return minDistance;
}

NoFlyZoneGeometryEngine::NoFlyZoneData NoFlyZoneGeometryEngine::NoFlyZoneData::fromGeoJsonPolygon(
    const QJsonArray &polygonRings,
    const QJsonObject &properties)
{
    // Build one zone from a GeoJSON Polygon coordinate array.
    // Ring 0 is outer boundary; remaining rings are holes.
    NoFlyZoneData zone;
    if (polygonRings.isEmpty() || !polygonRings[0].isArray()) {
        return zone;
    }

    zone.outer = ZoneRing::fromGeoJsonRing(polygonRings[0].toArray());

    // Keep existing behavior: offshore 12NM boundary polygons are visual-only.
    zone.skipHitTest = properties.value("Airspace").toString()
        .contains("Airspace over waters from US shore to line (12NM)");

    for (int ringIndex = 1; ringIndex < polygonRings.size(); ++ringIndex) {
        if (!polygonRings[ringIndex].isArray()) {
            continue;
        }

        ZoneRing hole = ZoneRing::fromGeoJsonRing(polygonRings[ringIndex].toArray());
        if (hole.isValid()) {
            zone.holes.append(hole);
        }
    }

    zone.computeBounds();
    return zone;
}

void NoFlyZoneGeometryEngine::NoFlyZoneData::computeBounds()
{
    // Empty rings keep a zeroed AABB to avoid stale bounds.
    if (outer.points.isEmpty()) {
        minLat = maxLat = minLon = maxLon = 0.0;
        return;
    }

    minLat = 90.0;
    maxLat = -90.0;
    minLon = 180.0;
    maxLon = -180.0;

    for (const QPointF &point : outer.points) {
        minLat = qMin(minLat, point.y());
        maxLat = qMax(maxLat, point.y());
        minLon = qMin(minLon, point.x());
        maxLon = qMax(maxLon, point.x());
    }
}

bool NoFlyZoneGeometryEngine::NoFlyZoneData::contains(double lat, double lon) const
{
    // A point must be inside outer and not inside any hole.
    if (!outer.contains(lat, lon)) {
        return false;
    }

    for (const ZoneRing &hole : holes) {
        if (hole.contains(lat, lon)) {
            return false;
        }
    }

    return true;
}

bool NoFlyZoneGeometryEngine::NoFlyZoneData::overlapsBoundingBox(
    double minLatValue,
    double maxLatValue,
    double minLonValue,
    double maxLonValue) const
{
    // Standard axis-aligned bounding box overlap check.
    return !(maxLatValue < minLat || minLatValue > maxLat
          || maxLonValue < minLon || minLonValue > maxLon);
}

bool NoFlyZoneGeometryEngine::NoFlyZoneData::crossesSegment(double lat1, double lon1, double lat2, double lon2) const
{
    // Crossing either outer boundary or a hole boundary counts as intersection.
    if (outer.crossesSegment(lat1, lon1, lat2, lon2)) {
        return true;
    }

    for (const ZoneRing &hole : holes) {
        if (hole.crossesSegment(lat1, lon1, lat2, lon2)) {
            return true;
        }
    }

    return false;
}

double NoFlyZoneGeometryEngine::NoFlyZoneData::distanceToBoundaryMeters(double lat, double lon) const
{
    // Distance is the nearest boundary among outer and all holes.
    double minDistance = outer.distanceToBoundaryMeters(lat, lon);
    for (const ZoneRing &hole : holes) {
        minDistance = qMin(minDistance, hole.distanceToBoundaryMeters(lat, lon));
    }
    return minDistance;
}

void NoFlyZoneGeometryEngine::addZone(const NoFlyZoneData &zone)
{
    m_zones.append(zone);
}

void NoFlyZoneGeometryEngine::clearZones()
{
    m_zones.clear();
}

int NoFlyZoneGeometryEngine::zoneCount() const
{
    return m_zones.size();
}

bool NoFlyZoneGeometryEngine::isPointInNoFlyZone(double lat, double lon) const
{
    // Fast path query over pre-indexed geometry.
    for (const NoFlyZoneData &zone : m_zones) {
        if (zone.skipHitTest) {
            continue;
        }

        // Cheap AABB prefilter before expensive point-in-polygon checks.
        if (lat < zone.minLat || lat > zone.maxLat || lon < zone.minLon || lon > zone.maxLon) {
            continue;
        }

        if (zone.contains(lat, lon)) {
            return true;
        }
    }

    return false;
}

bool NoFlyZoneGeometryEngine::doesLineSegmentCrossNoFlyZone(double lat1, double lon1, double lat2, double lon2) const
{
    // No zones means no crossing.
    if (m_zones.isEmpty()) {
        return false;
    }

    // Segment AABB used to quickly reject non-overlapping zones.
    const double segmentMinLat = qMin(lat1, lat2);
    const double segmentMaxLat = qMax(lat1, lat2);
    const double segmentMinLon = qMin(lon1, lon2);
    const double segmentMaxLon = qMax(lon1, lon2);

    for (const NoFlyZoneData &zone : m_zones) {
        if (zone.skipHitTest) {
            continue;
        }

        if (!zone.overlapsBoundingBox(segmentMinLat, segmentMaxLat, segmentMinLon, segmentMaxLon)) {
            continue;
        }

        if (zone.crossesSegment(lat1, lon1, lat2, lon2)) {
            return true;
        }
    }

    return false;
}

double NoFlyZoneGeometryEngine::distanceToNoFlyZoneMeters(double lat, double lon) const
{
    // Return sentinel when no valid zone data is available.
    if (m_zones.isEmpty()) {
        return -1.0;
    }

    // Latitude-dependent conversion for quick AABB lower-bound pruning.
    const double metersPerDegLat = 111320.0;
    const double metersPerDegLon = 111320.0 * qCos(qDegreesToRadians(lat));
    double minDistance = std::numeric_limits<double>::infinity();

    for (const NoFlyZoneData &zone : m_zones) {
        if (zone.skipHitTest) {
            continue;
        }

        // Inside a restricted area means zero distance to violation.
        if (zone.contains(lat, lon)) {
            return 0.0;
        }

        const double deltaLat = (lat < zone.minLat) ? (zone.minLat - lat)
                              : (lat > zone.maxLat) ? (lat - zone.maxLat)
                              : 0.0;
        const double deltaLon = (lon < zone.minLon) ? (zone.minLon - lon)
                              : (lon > zone.maxLon) ? (lon - zone.maxLon)
                              : 0.0;

        const double lowerBound = qSqrt(deltaLat * deltaLat * metersPerDegLat * metersPerDegLat
                                      + deltaLon * deltaLon * metersPerDegLon * metersPerDegLon);
        // Skip exact edge distance when this zone cannot improve current best.
        if (lowerBound >= minDistance) {
            continue;
        }

        minDistance = qMin(minDistance, zone.distanceToBoundaryMeters(lat, lon));
    }

    return std::isfinite(minDistance) ? minDistance : -1.0;
}
