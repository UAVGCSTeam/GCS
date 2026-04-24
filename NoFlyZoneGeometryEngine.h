#ifndef NOFLYZONEGEOMETRYENGINE_H
#define NOFLYZONEGEOMETRYENGINE_H

#include <QJsonArray>
#include <QJsonObject>
#include <QPointF>
#include <QVariantList>
#include <QVector>

class NoFlyZoneGeometryEngine
{
public:
    struct ZoneRing {
        QVector<QPointF> points; // x = lon, y = lat

        static ZoneRing fromGeoJsonRing(const QJsonArray &ring);
        QVariantList toVariantPointList() const;
        bool isValid() const;
        bool contains(double lat, double lon) const;
        bool crossesSegment(double lat1, double lon1, double lat2, double lon2) const;
        double distanceToBoundaryMeters(double lat, double lon) const;
    };

    struct NoFlyZoneData {
        ZoneRing outer;
        QVector<ZoneRing> holes;
        double minLat = 0.0;
        double maxLat = 0.0;
        double minLon = 0.0;
        double maxLon = 0.0;
        bool skipHitTest = false; // true for offshore 12NM border-only zones

        static NoFlyZoneData fromGeoJsonPolygon(const QJsonArray &polygonRings, const QJsonObject &properties);
        bool contains(double lat, double lon) const;
        bool overlapsBoundingBox(double minLatValue, double maxLatValue,
                                 double minLonValue, double maxLonValue) const;
        bool crossesSegment(double lat1, double lon1, double lat2, double lon2) const;
        double distanceToBoundaryMeters(double lat, double lon) const;

    private:
        void computeBounds();
    };

    NoFlyZoneGeometryEngine() = default;

    /**
     * function addZone()
     * @brief Adds a no-fly zone to the internal index.
     *
     * @param zone  The zone data to add.
     */
    void addZone(const NoFlyZoneData &zone);

    /**
     * function clearZones()
     * @brief Removes all zones from the index.
     */
    void clearZones();

    /**
     * function isPointInNoFlyZone()
     * @brief Checks whether a point lies inside a restricted no-fly polygon.
     *
     * @param lat  Latitude of the query point (degrees).
     * @param lon  Longitude of the query point (degrees).
     *
     * @return true if the point is inside a restricted zone; false otherwise.
     */
    bool isPointInNoFlyZone(double lat, double lon) const;

    /**
     * function doesLineSegmentCrossNoFlyZone()
     * @brief Checks whether a line segment crosses a no-fly zone boundary.
     *
     * @param lat1  Starting latitude (degrees).
     * @param lon1  Starting longitude (degrees).
     * @param lat2  Ending latitude (degrees).
     * @param lon2  Ending longitude (degrees).
     *
     * @return true if the segment crosses a zone boundary; false otherwise.
     */
    bool doesLineSegmentCrossNoFlyZone(double lat1, double lon1, double lat2, double lon2) const;

    /**
     * function distanceToNoFlyZoneMeters()
     * @brief Computes distance from a point to the nearest no-fly zone boundary.
     *
     * @param lat  Latitude of the query point (degrees).
     * @param lon  Longitude of the query point (degrees).
     *
     * @return Distance in meters to closest boundary, 0.0 if inside a zone, or -1.0 if no zones.
     */
    double distanceToNoFlyZoneMeters(double lat, double lon) const;

    /**
     * function zoneCount()
     * @brief Returns the number of zones in the index.
     *
     * @return Number of zones.
     */
    int zoneCount() const;

private:
    struct GeometryUtils {
        static bool lineSegmentIntersectSegment(const QPointF &p1, const QPointF &p2,
                                                const QPointF &p3, const QPointF &p4);
        static QPointF projectToMeters(double lat, double lon, double refLat, double refLon);
        static double distancePointToSegmentMeters(const QPointF &p, const QPointF &a, const QPointF &b);
    };

    QVector<NoFlyZoneData> m_zones;
};

#endif // NOFLYZONEGEOMETRYENGINE_H
