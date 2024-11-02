
#ifndef MAPCONTROLLER_H
#define MAPCONTROLLER_H

#include <QObject>
#include <QPair>
#include <QVariant>
#include <QVector>

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

public:
    explicit MapController(QObject *parent = nullptr);

public slots:
    void setCenterPosition(const QVariant &lat, const QVariant &lon);
    void setLocationMarking(const QVariant &lat, const QVariant &lon);
    void changeMapType(int typeIndex);

signals:
    void centerPositionChanged(const QVariant &lat, const QVariant &lon);
    void locationMarked(const QVariant &lat, const QVariant &lon);
    void mapTypeChanged(int typeIndex);

private:
    QPair<double, double> m_center;
    QVector<QPair<double, double>> m_markers;
    int m_currentMapType;
    int m_supportedMapTypesCount;

    void updateCenter(const QPair<double, double> &center);
    void addMarker(const QPair<double, double> &position);
};

#endif // MAPCONTROLLER_H
