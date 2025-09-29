#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QList>
#include <QObject>
#include <QSharedMemory>
#include <QSharedPointer>
#include <QTimer>
#include "backend/dbmanager.h"
#include "droneclass.h"
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
class DroneController : public QObject
{
    Q_OBJECT
public:
    // idk how to pass the parent function
    explicit DroneController(DBManager &gcsdb_in, QObject *parent = nullptr);
    ~DroneController();

    // Initialize shared memory for XBee communication
    bool checkDataFileExists();
    void startXbeeMonitoring();
    Q_INVOKABLE QVariantList getDrones() const;
    Q_INVOKABLE bool isSimulationMode() const;
    Q_INVOKABLE DroneClass *getDrone(int index) const;

public slots:
    void saveDrone(const QSharedPointer<DroneClass> &drone);
    void createDrone(const QString &name,
                     const QString &role,
                     const QString &xbeeId,
                     const QString &xbeeAddress);
    void updateDrone(const QSharedPointer<DroneClass> &drone);
    void deleteDrone(const QString &xbeeid);
    void deleteALlDrones_UI();

    // Declaration for retrieving the drone list
public:
    Q_INVOKABLE QVariantList getDroneList() const;
    // Process data recieved from XBee via shared memory
    Q_INVOKABLE QVariantList getAllDrones() const;

private slots:
    void processXbeeData();
    void tryConnectToDataFile();

signals:
    void droneAdded(const QSharedPointer<DroneClass> &drone);
    void droneUpdated(const QSharedPointer<DroneClass> &drone);
    void droneDeleted(const QSharedPointer<DroneClass> &drone);
    void droneStateChanged(const QString &droneName);
    void xbeeConnectionChanged(bool connected);
    void dronesChanged();

private:
    DBManager &dbManager;
    static QList<QSharedPointer<DroneClass>> droneList;
    //DroneClass &droneClass;
    // Timers for data polling
    QTimer xbeeDataTimer;
    QTimer reconnectTimer;
    // Method to find drone by name
    QSharedPointer<DroneClass> getDroneByName(const QString &name);
    // Get latest data from file
    QString getLatestXbeeData();
    // Method to find drone by XBee address
    QSharedPointer<DroneClass> getDroneByXbeeAddress(const QString &address);

    QString getDataFilePath();
    QString getConfigFilePath() const;
};

#endif // DRONECONTROLLER_H
