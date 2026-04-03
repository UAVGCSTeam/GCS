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
    return m_noFlyZones;
}

void Overlays::clearNoFlyZones()
{
    if (m_noFlyZones.isEmpty()) {
        return;
    }

    m_noFlyZones.clear();
    m_zoneIndex.clear();
    emit noFlyZonesChanged();
}

bool Overlays::GeometryUtils::lineSegmentIntersectSegment(
    const QPointF &p1,
    const QPointF &p2,
    const QPointF &p3,
    const QPointF &p4)
{
    auto orientation = [](const QPointF &p, const QPointF &q, const QPointF &r) -> int {
        const double value = (q.y() - p.y()) * (r.x() - q.x()) - (q.x() - p.x()) * (r.y() - q.y());
        if (qAbs(value) < 1e-12) {
            return 0;
        }
        return (value > 0) ? 1 : 2;
    };

    auto onSegment = [](const QPointF &p, const QPointF &q, const QPointF &r) -> bool {
        return q.x() <= qMax(p.x(), r.x()) && q.x() >= qMin(p.x(), r.x())
            && q.y() <= qMax(p.y(), r.y()) && q.y() >= qMin(p.y(), r.y());
    };

    const int o1 = orientation(p1, p2, p3);
    const int o2 = orientation(p1, p2, p4);
    const int o3 = orientation(p3, p4, p1);
    const int o4 = orientation(p3, p4, p2);

    if (o1 != o2 && o3 != o4) {
        return true;
    }

    if (o1 == 0 && onSegment(p1, p3, p2)) return true;
    if (o2 == 0 && onSegment(p1, p4, p2)) return true;
    if (o3 == 0 && onSegment(p3, p1, p4)) return true;
    if (o4 == 0 && onSegment(p3, p2, p4)) return true;

    return false;
}

QPointF Overlays::GeometryUtils::projectToMeters(double lat, double lon, double refLat, double refLon)
{
    const double metersPerDegLat = 111320.0;
    const double metersPerDegLon = 111320.0 * qCos(qDegreesToRadians(refLat));
    return QPointF((lon - refLon) * metersPerDegLon, (lat - refLat) * metersPerDegLat);
}

double Overlays::GeometryUtils::distancePointToSegmentMeters(
    const QPointF &p,
    const QPointF &a,
    const QPointF &b)
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

    const double closestX = a.x() + t * abx;
    const double closestY = a.y() + t * aby;
    const double dx = p.x() - closestX;
    const double dy = p.y() - closestY;
    return qSqrt(dx * dx + dy * dy);
}

Overlays::ZoneRing Overlays::ZoneRing::fromGeoJsonRing(const QJsonArray &ring)
{
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

QVariantList Overlays::ZoneRing::toVariantPointList() const
{
    QVariantList pointList;
    for (const QPointF &point : points) {
        QVariantMap variantPoint;
        variantPoint["lat"] = point.y();
        variantPoint["lon"] = point.x();
        pointList.append(variantPoint);
    }
    return pointList;
}

bool Overlays::ZoneRing::isValid() const
{
    return points.size() >= 3;
}

bool Overlays::ZoneRing::contains(double lat, double lon) const
{
    if (!isValid()) {
        return false;
    }

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

bool Overlays::ZoneRing::crossesSegment(double lat1, double lon1, double lat2, double lon2) const
{
    if (!isValid()) {
        return false;
    }

    const QPointF segmentStart(lon1, lat1);
    const QPointF segmentEnd(lon2, lat2);

    const int pointCount = points.size();
    for (int index = 0, previousIndex = pointCount - 1; index < pointCount; previousIndex = index++) {
        if (GeometryUtils::lineSegmentIntersectSegment(segmentStart, segmentEnd, points[previousIndex], points[index])) {
            return true;
        }
    }

    return false;
}

double Overlays::ZoneRing::distanceToBoundaryMeters(double lat, double lon) const
{
    const int pointCount = points.size();
    if (pointCount < 2) {
        return std::numeric_limits<double>::infinity();
    }

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

Overlays::NoFlyZoneData Overlays::NoFlyZoneData::fromGeoJsonPolygon(
    const QJsonArray &polygonRings,
    const QJsonObject &properties)
{
    NoFlyZoneData zone;
    if (polygonRings.isEmpty() || !polygonRings[0].isArray()) {
        return zone;
    }

    zone.outer = ZoneRing::fromGeoJsonRing(polygonRings[0].toArray());
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

bool Overlays::NoFlyZoneData::isValid() const
{
    return outer.isValid();
}

void Overlays::NoFlyZoneData::computeBounds()
{
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

bool Overlays::NoFlyZoneData::contains(double lat, double lon) const
{
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

bool Overlays::NoFlyZoneData::overlapsBoundingBox(
    double minLatValue,
    double maxLatValue,
    double minLonValue,
    double maxLonValue) const
{
    return !(maxLatValue < minLat || minLatValue > maxLat
          || maxLonValue < minLon || minLonValue > maxLon);
}

bool Overlays::NoFlyZoneData::crossesSegment(double lat1, double lon1, double lat2, double lon2) const
{
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

double Overlays::NoFlyZoneData::distanceToBoundaryMeters(double lat, double lon) const
{
    double minDistance = outer.distanceToBoundaryMeters(lat, lon);
    for (const ZoneRing &hole : holes) {
        minDistance = qMin(minDistance, hole.distanceToBoundaryMeters(lat, lon));
    }
    return minDistance;
}

bool Overlays::isPointInNoFlyZone(double lat, double lon) const
{
    for (const NoFlyZoneData &zone : m_zoneIndex) {
        if (zone.skipHitTest) {
            continue;
        }

        if (lat < zone.minLat || lat > zone.maxLat || lon < zone.minLon || lon > zone.maxLon) {
            continue;
        }

        if (zone.contains(lat, lon)) {
            return true;
        }
    }

    return false;
}

bool Overlays::doesLineSegmentCrossNoFlyZone(double lat1, double lon1, double lat2, double lon2) const
{
    if (m_zoneIndex.isEmpty()) {
        return false;
    }

    const double segmentMinLat = qMin(lat1, lat2);
    const double segmentMaxLat = qMax(lat1, lat2);
    const double segmentMinLon = qMin(lon1, lon2);
    const double segmentMaxLon = qMax(lon1, lon2);

    for (const NoFlyZoneData &zone : m_zoneIndex) {
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

double Overlays::distanceToNoFlyZoneMeters(double lat, double lon) const
{
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
        if (lowerBound >= minDistance) {
            continue;
        }

        minDistance = qMin(minDistance, zone.distanceToBoundaryMeters(lat, lon));
    }

    return std::isfinite(minDistance) ? minDistance : -1.0;
}

bool Overlays::addPolygonZone(
    const QString &zoneId,
    const QJsonArray &polygonRings,
    const QJsonObject &properties,
    int polygonSuffix)
{
    const NoFlyZoneData zoneData = NoFlyZoneData::fromGeoJsonPolygon(polygonRings, properties);
    if (!zoneData.isValid()) {
        return false;
    }

    QVariantList holePointLists;
    for (const ZoneRing &hole : zoneData.holes) {
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

    m_noFlyZones.append(zone);
    m_zoneIndex.append(zoneData);
    return true;
}

bool Overlays::addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties)
{
    const QString geometryType = geometry.value("type").toString();
    const QJsonArray coordinates = geometry.value("coordinates").toArray();

    if (geometryType == "Polygon") {
        return addPolygonZone(zoneId, coordinates, properties);
    }

    if (geometryType == "MultiPolygon") {
        bool addedAny = false;
        int polygonIndex = 0;

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

    const QVariantList existingZones = m_noFlyZones;
    const QVector<NoFlyZoneData> existingZoneIndex = m_zoneIndex;
    m_noFlyZones.clear();
    m_zoneIndex.clear();

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

    if (m_noFlyZones.isEmpty()) {
        m_noFlyZones = existingZones;
        m_zoneIndex = existingZoneIndex;
        qWarning() << "[Overlays.cpp] No supported no-fly geometries were loaded.";
        return false;
    }

    emit noFlyZonesChanged();
    qDebug() << "[Overlays.cpp] Loaded no-fly zones:" << m_noFlyZones.size();
    return true;
}
