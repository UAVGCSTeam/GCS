#ifndef OVERLAYS_H
#define OVERLAYS_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>
#include <QVector>
#include <QPointF>

class Overlays : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList noFlyZones READ noFlyZones NOTIFY noFlyZonesChanged)

public:
    explicit Overlays(QObject *parent = nullptr);

    Q_INVOKABLE bool loadNoFlyZones(const QString &geoJsonPath);
    Q_INVOKABLE void clearNoFlyZones();

    /**
     * function isPointInNoFlyZone()
     * @brief Checks whether a latitude/longitude point lies inside a restricted no-fly polygon.
     *
     * Evaluates the given point against the precomputed no-fly-zone index generated
     * when GeoJSON data is loaded. The check uses a fast bounding-box prefilter and
     * then performs point-in-polygon evaluation with hole support.
     *
     * @param lat  Latitude of the query point (degrees).
     * @param lon  Longitude of the query point (degrees).
     *
     * @return true if the point is inside a restricted no-fly area; false otherwise.
     *
     * @note Zones flagged as offshore 12NM border-only bands are excluded from hit tests.
     */
    Q_INVOKABLE bool isPointInNoFlyZone(double lat, double lon) const;

    /**
     * function distanceToNoFlyZoneMeters()
     * @brief Computes the nearest distance from a point to any restricted no-fly-zone boundary.
     *
     * Uses the precomputed zone index and returns a metric distance to the closest
     * eligible zone edge. If the point is inside a restricted zone (and not in a hole),
     * this function returns 0.0.
     *
     * @param lat  Latitude of the query point (degrees).
     * @param lon  Longitude of the query point (degrees).
     *
     * @return Distance in meters to the closest restricted boundary,
     *         0.0 if already inside a restricted zone,
     *         or -1.0 if no valid zone distance is available.
     */
    Q_INVOKABLE double distanceToNoFlyZoneMeters(double lat, double lon) const;

    /**
     * function doesLineSegmentCrossNoFlyZone()
     * @brief Checks whether a straight-line path between two geographic points crosses a no-fly zone.
     *
     * Tests if the line segment from (lat1, lon1) to (lat2, lon2) intersects the boundary
     * of any restricted no-fly polygon. Uses bounding-box prefiltering and line-segment
     * intersection testing against zone edges.
     *
     * @param lat1  Starting latitude (degrees).
     * @param lon1  Starting longitude (degrees).
     * @param lat2  Ending latitude (degrees).
     * @param lon2  Ending longitude (degrees).
     *
     * @return true if the path crosses a no-fly zone boundary; false otherwise.
     *
     * @note Returns false if either endpoint is inside a no-fly zone (use isPointInNoFlyZone
     *       separately to check endpoints). Only detects boundary crossings for the path itself.
     */
    Q_INVOKABLE bool doesLineSegmentCrossNoFlyZone(double lat1, double lon1, double lat2, double lon2) const;

    QVariantList noFlyZones() const;

signals:
    void noFlyZonesChanged();

private:
    struct GeometryUtils {
        /**
         * function lineSegmentIntersectSegment()
         * @brief Tests whether two line segments intersect in 2D.
         *
         * @param p1  Start of first segment.
         * @param p2  End of first segment.
         * @param p3  Start of second segment.
         * @param p4  End of second segment.
         *
         * @return true if the segments intersect (including touching endpoints); false otherwise.
         */
        static bool lineSegmentIntersectSegment(const QPointF &p1, const QPointF &p2,
                                                const QPointF &p3, const QPointF &p4);

        /**
         * function projectToMeters()
         * @brief Projects a geographic point into local planar meters around a reference origin.
         *
         * @param lat     Latitude to project (degrees).
         * @param lon     Longitude to project (degrees).
         * @param refLat  Reference origin latitude (degrees).
         * @param refLon  Reference origin longitude (degrees).
         *
         * @return Local XY point in meters (x: east-west, y: north-south).
         */
        static QPointF projectToMeters(double lat, double lon, double refLat, double refLon);

        /**
         * function distancePointToSegmentMeters()
         * @brief Computes shortest Euclidean distance from a point to a line segment in meters.
         *
         * @param p  Query point in local projected meters.
         * @param a  Segment start in local projected meters.
         * @param b  Segment end in local projected meters.
         *
         * @return Shortest distance from point p to segment ab, in meters.
         */
        static double distancePointToSegmentMeters(const QPointF &p, const QPointF &a, const QPointF &b);
    };

    struct ZoneRing {
        QVector<QPointF> points; // x = lon, y = lat

        /**
         * function fromGeoJsonRing()
         * @brief Builds a ZoneRing from a GeoJSON ring array.
         *
         * @param ring  GeoJSON ring represented as [[lon, lat], ...].
         *
         * @return Parsed ring with lon/lat points.
         */
        static ZoneRing fromGeoJsonRing(const QJsonArray &ring);

        /**
         * function toVariantPointList()
         * @brief Converts the ring points into the QVariantList format used by QML.
         *
         * @return List of points as QVariantMap entries with lat/lon keys.
         */
        QVariantList toVariantPointList() const;

        /**
         * function isValid()
         * @brief Checks whether the ring has enough points to form a polygon.
         *
         * @return true if the ring has at least three points; false otherwise.
         */
        bool isValid() const;

        /**
         * function contains()
         * @brief Performs an even-odd point-in-polygon ring test.
         *
         * @param lat   Query latitude (degrees).
         * @param lon   Query longitude (degrees).
         *
         * @return true if the point is inside the ring; false otherwise.
         */
        bool contains(double lat, double lon) const;

        /**
         * function crossesSegment()
         * @brief Checks if a line segment crosses any edge of the ring.
         *
         * @param lat1  Start latitude of the segment (degrees).
         * @param lon1  Start longitude of the segment (degrees).
         * @param lat2  End latitude of the segment (degrees).
         * @param lon2  End longitude of the segment (degrees).
         *
         * @return true if the segment crosses the ring boundary; false otherwise.
         */
        bool crossesSegment(double lat1, double lon1, double lat2, double lon2) const;

        /**
         * function distanceToBoundaryMeters()
         * @brief Computes shortest distance from a geographic point to a polygon ring boundary.
         *
         * @param lat   Query latitude (degrees).
         * @param lon   Query longitude (degrees).
         *
         * @return Minimum boundary distance in meters.
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
         * @brief Builds a no-fly zone record from a GeoJSON polygon ring list.
         *
         * @param polygonRings  GeoJSON polygon coordinates containing one outer ring
         *                      followed by optional hole rings.
         * @param properties    GeoJSON feature properties used for zone metadata.
         *
         * @return Parsed zone data with outer ring, holes, bounds, and hit-test flags.
         */
        static NoFlyZoneData fromGeoJsonPolygon(const QJsonArray &polygonRings, const QJsonObject &properties);

        /**
         * function isValid()
         * @brief Checks whether the zone has a valid outer ring.
         *
         * @return true if the outer ring is valid; false otherwise.
         */
        bool isValid() const;

        /**
         * function contains()
         * @brief Checks whether a point lies inside the zone excluding holes.
         *
         * @param lat  Query latitude (degrees).
         * @param lon  Query longitude (degrees).
         *
         * @return true if the point is inside the zone and outside all holes.
         */
        bool contains(double lat, double lon) const;

        /**
         * function overlapsBoundingBox()
         * @brief Tests whether an axis-aligned bounding box overlaps the zone bounds.
         *
         * @param minLatValue  Minimum latitude of the query box.
         * @param maxLatValue  Maximum latitude of the query box.
         * @param minLonValue  Minimum longitude of the query box.
         * @param maxLonValue  Maximum longitude of the query box.
         *
         * @return true if the boxes overlap; false otherwise.
         */
        bool overlapsBoundingBox(double minLatValue, double maxLatValue, double minLonValue, double maxLonValue) const;

        /**
         * function crossesSegment()
         * @brief Checks whether a line segment crosses the zone boundary or any hole.
         *
         * @param lat1  Start latitude of the segment (degrees).
         * @param lon1  Start longitude of the segment (degrees).
         * @param lat2  End latitude of the segment (degrees).
         * @param lon2  End longitude of the segment (degrees).
         *
         * @return true if the segment crosses the zone or a hole boundary; false otherwise.
         */
        bool crossesSegment(double lat1, double lon1, double lat2, double lon2) const;

        /**
         * function distanceToBoundaryMeters()
         * @brief Computes the shortest distance from a point to the zone boundary or hole boundary.
         *
         * @param lat  Query latitude (degrees).
         * @param lon  Query longitude (degrees).
         *
         * @return Shortest distance in meters to any zone boundary.
         */
        double distanceToBoundaryMeters(double lat, double lon) const;

    private:
        /**
         * function computeBounds()
         * @brief Recomputes the zone's outer-ring bounding box.
         */
        void computeBounds();
    };

    QVariantList m_noFlyZones;
    QVector<NoFlyZoneData> m_zoneIndex;

    /**
     * function addGeoJsonGeometry()
     * @brief Converts a GeoJSON geometry object into one or more internal zone records.
     *
     * @param zoneId      Identifier used for the parsed zone.
     * @param geometry    GeoJSON geometry object.
     * @param properties  GeoJSON feature properties used for metadata.
     *
     * @return true if at least one zone was added; false otherwise.
     */
    bool addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties);

    /**
     * function addPolygonZone()
     * @brief Adds one polygon zone and its hit-test index from parsed ring coordinates.
     *
     * @param zoneId         Identifier used for the parsed zone.
     * @param polygonRings    GeoJSON polygon ring list.
     * @param properties     GeoJSON feature properties used for metadata.
     * @param polygonSuffix   Optional suffix for MultiPolygon members.
     *
     * @return true if the polygon was valid and added; false otherwise.
     */
    bool addPolygonZone(const QString &zoneId, const QJsonArray &polygonRings,
                        const QJsonObject &properties, int polygonSuffix = -1);
};

#endif // OVERLAYS_H