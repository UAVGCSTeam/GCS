#ifndef OVERLAYS_H
#define OVERLAYS_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>
#include <QVector>

#include "NoFlyZoneGeometryEngine.h"

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
    QVariantList m_noFlyZones;
    NoFlyZoneGeometryEngine m_engine;

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