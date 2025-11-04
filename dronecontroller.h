#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QObject>
#include <QList>
#include "backend/dbmanager.h"
#include "droneclass.h"
#include <QSharedPointer>
#include <QSharedMemory>
#include <QTimer>
#include <memory>
#include <cstdint>
#include <QHash>
#include <QVariant>
#include "MavlinkReceiver.h"   // brings RxMavlinkMsg and its Q_DECLARE_METATYPE


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



class XbeeLink;
class MavlinkSender;
class MavlinkReceiver;

class DroneController : public QObject {
    Q_OBJECT
public:
    // idk how to pass the parent function
    explicit DroneController(DBManager &gcsdb_in, QObject *parent = nullptr);
    ~DroneController();

    // Initialize shared memory for XBee communication
    bool checkDataFileExists();
    void startXbeeMonitoring();
    Q_INVOKABLE QVariantList getDrones();
    Q_INVOKABLE bool isSimulationMode() const;
    Q_INVOKABLE bool openXbee(const QString &port, int baud = 57600);
    Q_INVOKABLE bool sendArm(const QString &droneKeyOrAddr, bool arm = true);


public slots:
    void saveDrone(const QString &name, const QString &role, const QString &xbeeId, const QString &xbeeAddress);
    void updateDrone(const QString &oldXbeeId, const QString &name, const QString &role, const QString &xbeeId, const QString &xbeeAddress);
    void deleteDrone(const QString &xbeeId);
    void deleteALlDrones_UI();

// Declaration for retrieving the drone list
public:
    Q_INVOKABLE QVariantList getDroneList() const;
    // Process data recieved from XBee via shared memory
    Q_INVOKABLE QVariantList getAllDrones() const;


private slots:
    void processXbeeData();
    void tryConnectToDataFile();
    void onMavlinkMessage(const RxMavlinkMsg& msg);


signals:
    void droneAdded();
    void droneUpdated();
    void droneDeleted();
    void droneStateChanged(const QString &droneName);
    void xbeeConnectionChanged(bool connected);
    void dronesChanged();

private:
    DBManager &dbManager;
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

    std::unique_ptr<XbeeLink>    xbee_;
    std::unique_ptr<MavlinkSender> mav_;
    std::unique_ptr<MavlinkReceiver> mavRx_;
    void updateDroneTelem(uint8_t sysid, const QString& field, const QVariant& value);
    QHash<uint8_t, QSharedPointer<DroneClass>> sysMap_;
    QList<QSharedPointer<DroneClass>> droneList;

};


#endif // DRONECONTROLLER_H
