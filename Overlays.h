#define OVERLAYS_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>
#include <QVector>
#include <QPointF>

struct ZoneRing {
    QVector<QPointF> points; // x = lon, y = lat
};

struct NoFlyZoneData {
    ZoneRing outer;
    QVector<ZoneRing> holes;
    double minLat, maxLat, minLon, maxLon;
    bool skipHitTest; // true for offshore 12NM border-only zones
};

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
    QVariantList m_noFlyZones;
    QVector<NoFlyZoneData> m_zoneIndex;

    bool addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties);
    QVariantList buildPointListFromPolygonRing(const QJsonArray &ring) const;
    ZoneRing buildZoneRing(const QJsonArray &ring) const;

    /**
     * function pointInRing()
     * @brief Performs an even-odd point-in-polygon ring test.
     *
     * @param lat   Query latitude (degrees).
     * @param lon   Query longitude (degrees).
     * @param ring  Polygon ring represented as lon/lat points.
     *
     * @return true if the point is inside the ring; false otherwise.
     */
    static bool pointInRing(double lat, double lon, const ZoneRing &ring);

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
    static bool lineSegmentIntersectSegment(const QPointF &p1, const QPointF &p2, const QPointF &p3, const QPointF &p4);

    /**
     * function lineSegmentCrossesRing()
     * @brief Checks if a line segment crosses any edge of a polygon ring.
     *
     * @param lat1  Start latitude of the segment (degrees).
     * @param lon1  Start longitude of the segment (degrees).
     * @param lat2  End latitude of the segment (degrees).
     * @param lon2  End longitude of the segment (degrees).
     * @param ring  Polygon ring to test against.
     *
     * @return true if the segment crosses the ring boundary; false otherwise.
     */
    static bool lineSegmentCrossesRing(double lat1, double lon1, double lat2, double lon2, const ZoneRing &ring);
};