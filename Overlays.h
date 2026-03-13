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
    Q_INVOKABLE bool isPointInNoFlyZone(double lat, double lon) const;

    QVariantList noFlyZones() const;

signals:
    void noFlyZonesChanged();

private:
    QVariantList m_noFlyZones;
    QVector<NoFlyZoneData> m_zoneIndex;

    bool addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties);
    QVariantList buildPointListFromPolygonRing(const QJsonArray &ring) const;
    ZoneRing buildZoneRing(const QJsonArray &ring) const;
    static bool pointInRing(double lat, double lon, const ZoneRing &ring);
};