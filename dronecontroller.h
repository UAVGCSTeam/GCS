#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QObject>
#include <QList>
#include "backend/dbmanager.h"
#include "droneclass.h"
#include <QSharedPointer>
#include <array>
using namespace std;
// #include "drone.h"

/*
 * Qt uses Slots and Signals to create responsive UI/GUI applications.
 * It allows for communication between QML and C++.
 * https://doc.qt.io/qt-6/signalsandslots.html
*/


/*
 * Button Press:
 * 1. DroneController -- Saves Drone to update on UI
 * 2. DroneManager -- Holds the list of Drone C++ objects and modifies it. -- vectorList
 * 3. DroneClass - Is the data model that can take real time updates
 * 4. DBManager -- Connects Drone Database
*/

// Drone Controller will notify UI
// Serves as a middle man from UI and backend.
class DroneController : public QObject {
    Q_OBJECT
public:
    // idk how to pass the parent function
    explicit DroneController(DBManager &gcsdb_in, QObject *parent = nullptr);

public slots:
    void saveDrone(const QString &name, const QString &type, const QString &xbeeId, const QString &xbeeAddress);
    QVector3D fetchPosition(int droneIndex);

signals:
    void droneAdded();

private:
    DBManager &dbManager;
    static QList<QSharedPointer<DroneClass>> droneList;
    //DroneClass &droneClass;

};


#endif // DRONECONTROLLER_H
