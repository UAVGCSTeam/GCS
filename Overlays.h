#define OVERLAYS_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>

class Overlays : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList noFlyZones READ noFlyZones NOTIFY noFlyZonesChanged)

public:
    explicit Overlays(QObject *parent = nullptr);

    Q_INVOKABLE bool loadNoFlyZones(const QString &geoJsonPath);
    Q_INVOKABLE void clearNoFlyZones();

    QVariantList noFlyZones() const;

signals:
    void noFlyZonesChanged();

private:
    QVariantList m_noFlyZones;

    bool addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties);
    QVariantList buildPointListFromPolygonRing(const QJsonArray &ring) const;
};