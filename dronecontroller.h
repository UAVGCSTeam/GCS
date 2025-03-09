#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QObject>
#include <QList>
#include "backend/dbmanager.h"
#include "droneclass.h"
#include <QSharedPointer>
#include <QSharedMemory>
#include <QTimer>
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
    ~DroneController();

    // Initialize shared memory for XBee communication
    bool initXbeeSharedMemory();

    // Send command to a specific drone via XBee
    Q_INVOKABLE void sendCommandToDrone(const QString &droneName, const QString &command);

    // Get latest recieved XBee data
    QString getLatestXbeeData();

public slots:
    // Process data recieved from XBee via shared memory
    void saveDrone(const QString &name, const QString &type, const QString &xbeeId, const QString &xbeeAddress);

private slots:
    void processXbeeData();

signals:
    void droneAdded();
    void droneStateChanged(const QString &droneName);

private:
    DBManager &dbManager;
    static QList<QSharedPointer<DroneClass>> droneList;
    //DroneClass &droneClass;

    // Shared memory for XBee Communication
    QSharedMemory xbeeSharedMemory;
    QTimer xbeeDataTimer;

    // Method to find drone by name
    QSharedPointer<DroneClass> getDroneByName(const QString &name);
};


#endif // DRONECONTROLLER_H
