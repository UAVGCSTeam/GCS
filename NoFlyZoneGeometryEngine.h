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

        /**
         * function fromGeoJsonRing()
         * @brief Builds a ring from GeoJSON coordinate data.
         *
         * @param ring  GeoJSON ring coordinates in [lon, lat] form.
         *
         * @return Parsed ring.
         */
        static ZoneRing fromGeoJsonRing(const QJsonArray &ring);

        /**
         * function toVariantPointList()
         * @brief Converts ring points into QML-friendly latitude and longitude maps.
         *
         * @return List of points as QVariantMap entries.
         */
        QVariantList toVariantPointList() const;

        /**
         * function isValid()
         * @brief Checks whether the ring contains enough points to form a polygon.
         *
         * @return true if the ring is valid; false otherwise.
         */
        bool isValid() const;

        /**
         * function contains()
         * @brief Checks whether a point lies inside the ring.
         *
         * @param lat  Latitude of the query point (degrees).
         * @param lon  Longitude of the query point (degrees).
         *
         * @return true if the point is inside the ring; false otherwise.
         */
        bool contains(double lat, double lon) const;

        /**
         * function crossesSegment()
         * @brief Checks whether a line segment intersects the ring boundary.
         *
         * @param lat1  Starting latitude (degrees).
         * @param lon1  Starting longitude (degrees).
         * @param lat2  Ending latitude (degrees).
         * @param lon2  Ending longitude (degrees).
         *
         * @return true if the segment crosses the ring; false otherwise.
         */
        bool crossesSegment(double lat1, double lon1, double lat2, double lon2) const;

        /**
         * function distanceToBoundaryMeters()
         * @brief Computes the distance from a point to the nearest ring edge.
         *
         * @param lat  Latitude of the query point (degrees).
         * @param lon  Longitude of the query point (degrees).
         *
         * @return Distance in meters to the closest boundary.
         */
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

        /**
         * function fromGeoJsonPolygon()
         * @brief Builds a zone from GeoJSON polygon ring data.
         *
         * @param polygonRings  GeoJSON polygon rings.
         * @param properties  Feature properties associated with the polygon.
         *
         * @return Parsed no-fly zone data.
         */
        static NoFlyZoneData fromGeoJsonPolygon(const QJsonArray &polygonRings, const QJsonObject &properties);

        /**
         * function contains()
         * @brief Checks whether a point lies inside the zone and outside any holes.
         *
         * @param lat  Latitude of the query point (degrees).
         * @param lon  Longitude of the query point (degrees).
         *
         * @return true if the point is inside the zone; false otherwise.
         */
        bool contains(double lat, double lon) const;

        /**
         * function overlapsBoundingBox()
         * @brief Checks whether the zone bounding box overlaps a query box.
         *
         * @param minLatValue  Minimum latitude of the query box.
         * @param maxLatValue  Maximum latitude of the query box.
         * @param minLonValue  Minimum longitude of the query box.
         * @param maxLonValue  Maximum longitude of the query box.
         *
         * @return true if the bounding boxes overlap; false otherwise.
         */
        bool overlapsBoundingBox(double minLatValue, double maxLatValue,
                                 double minLonValue, double maxLonValue) const;

        /**
         * function crossesSegment()
         * @brief Checks whether a line segment crosses the zone boundary or any hole boundary.
         *
         * @param lat1  Starting latitude (degrees).
         * @param lon1  Starting longitude (degrees).
         * @param lat2  Ending latitude (degrees).
         * @param lon2  Ending longitude (degrees).
         *
         * @return true if the segment crosses the zone; false otherwise.
         */
        bool crossesSegment(double lat1, double lon1, double lat2, double lon2) const;

        /**
         * function distanceToBoundaryMeters()
         * @brief Computes the distance from a point to the closest boundary in the zone.
         *
         * @param lat  Latitude of the query point (degrees).
         * @param lon  Longitude of the query point (degrees).
         *
         * @return Distance in meters to the nearest boundary.
         */
        double distanceToBoundaryMeters(double lat, double lon) const;

    private:
        /**
         * function computeBounds()
         * @brief Computes the zone axis-aligned bounding box from the outer ring.
         */
        void computeBounds();
    };

    /**
     * function NoFlyZoneGeometryEngine()
     * @brief Creates an empty no-fly zone geometry engine.
     */
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
        /**
         * function lineSegmentIntersectSegment()
         * @brief Checks whether two line segments intersect.
         *
         * @param p1  First endpoint of the first segment.
         * @param p2  Second endpoint of the first segment.
         * @param p3  First endpoint of the second segment.
         * @param p4  Second endpoint of the second segment.
         *
         * @return true if the segments intersect; false otherwise.
         */
        static bool lineSegmentIntersectSegment(const QPointF &p1, const QPointF &p2,
                                                const QPointF &p3, const QPointF &p4);
        /**
         * function projectToMeters()
         * @brief Projects latitude and longitude into a local meter-based coordinate system.
         *
         * @param lat  Latitude of the point to project.
         * @param lon  Longitude of the point to project.
         * @param refLat  Reference latitude used for the projection center.
         * @param refLon  Reference longitude used for the projection center.
         *
         * @return Projected point in meters.
         */
        static QPointF projectToMeters(double lat, double lon, double refLat, double refLon);
        /**
         * function distancePointToSegmentMeters()
         * @brief Computes the Euclidean distance from a point to a segment in projected meters.
         *
         * @param p  Query point.
         * @param a  First segment endpoint.
         * @param b  Second segment endpoint.
         *
         * @return Distance from the point to the segment.
         */
        static double distancePointToSegmentMeters(const QPointF &p, const QPointF &a, const QPointF &b);
    };

    QVector<NoFlyZoneData> m_zones;
};

#endif // NOFLYZONEGEOMETRYENGINE_H
