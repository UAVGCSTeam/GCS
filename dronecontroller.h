#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include "backend/dbmanager.h"
#include <QObject>
#include <QDebug>


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

class DroneController : public QObject {
    Q_OBJECT
public:
    explicit DroneController(QObject *parent = nullptr);

public slots:
    void saveDrone(const QString &name, const QString &type, const QString &xbeeId, const QString &xbeeAddress);
};

#endif // DRONECONTROLLER_H
