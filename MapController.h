#ifndef MAPCONTROLLER_H
#define MAPCONTROLLER_H

#include <QObject>
#include <QPair>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>
#include "DroneClass.h"

/*
 * Qt uses Slots and Signals to create responsive UI/GUI applications.
 * It allows for communication between QML and C++.
 * https://doc.qt.io/qt-6/signalsandslots.html
*/

/*
 * Our API to control all map functionality.
 * Everything regarding the map should go here.
 * Ensures separation of different functions.
 * Keeps logic in cpp and QML purely for UI.
*/

class MapController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList noFlyZones READ noFlyZones NOTIFY noFlyZonesChanged)

public:
    explicit MapController(QObject *parent = nullptr);
    // Q_INVOKABLE void debugPrintDrones() const;
    Q_INVOKABLE void createDrone(const QString &input_name);
    Q_INVOKABLE bool loadNoFlyZones(const QString &geoJsonPath);
    Q_INVOKABLE void clearNoFlyZones();
    QVariantList noFlyZones() const;


public slots:
    void setCenterPosition(const QVariant &lat, const QVariant &lon);
    void setLocationMarking(const QVariant &lat, const QVariant &lon);
    void changeMapType(int typeIndex);
    void setZoomLevel(double level);
    Q_INVOKABLE void addDrone(DroneClass* drone);
    Q_INVOKABLE QVariantList getAllDrones() const;
signals:
    void centerPositionChanged(const QVariant &lat, const QVariant &lon);
    void locationMarked(const QVariant &lat, const QVariant &lon);
    void mapTypeChanged(int typeIndex);
    void zoomLevelChanged(double level);
    void noFlyZonesChanged();

private:
    QPair<double, double> m_center;
    QVector<QPair<double, double>> m_markers;
    int m_currentMapType;
    int m_supportedMapTypesCount;

    QVector<DroneClass*> m_drones;
    QVariantList m_noFlyZones;

    void updateCenter(const QPair<double, double> &center);
    void addMarker(const QPair<double, double> &position);
    bool addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties);
    QVariantList buildPointListFromPolygonRing(const QJsonArray &ring) const;
};

#endif // MAPCONTROLLER_H
