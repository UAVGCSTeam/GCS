#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QObject>
#include <QList>
#include "backend/dbmanager.h"
#include "droneclass.h"
#include <QSharedPointer>
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

// DroneController is responsible for managing drones within the system
class DroneController : public QObject {
    Q_OBJECT
public:
    // Constructor that initializes the DroneController with database manager.
    explicit DroneController(DBManager &gcsdb_in, QObject *parent = nullptr);
    // Prints Drone vector for debugging
    void debugPrintDrones() const;

public slots:
    // Saves drone to database
    void saveDrone(const QString &name, const QString &type, const QString &xbeeId, const QString &xbeeAddress);
    // Adds drone to Vector list
    void addDrone(DroneClass* drone);

    // Creates a new drone instance and adds it to the system.
    void createDrone(const QString &input_name);
    QVariantList getAllDrones() const;

signals:
    // Signal emmited to QML when new drone is added
    void droneAdded();

private:
    DBManager &dbManager;
    // List of all drones managed by this controller.
    static QVector<DroneClass*> droneList;
};


#endif // DRONECONTROLLER_H
