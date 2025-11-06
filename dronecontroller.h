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

class DroneController : public QObject 
{
    Q_OBJECT
    Q_PROPERTY(QVariantList drones READ drones NOTIFY dronesChanged)
public:
    // idk how to pass the parent function
    explicit DroneController(DBManager &gcsdb_in, QObject *parent = nullptr);
    ~DroneController();

    // Initialize shared memory for XBee communication
    bool checkDataFileExists();
    bool addNewDrone = true;
    void startXbeeMonitoring();
    Q_INVOKABLE QVariantList getDrones() const;
    Q_INVOKABLE bool isSimulationMode() const;
    Q_INVOKABLE bool openXbee(const QString &port, int baud = 57600);
    Q_INVOKABLE bool sendArm(const QString &droneKeyOrAddr, bool arm = true);
    Q_INVOKABLE bool sendTakeoffCmd(const QString& droneKeyOrAddr);
    Q_INVOKABLE bool sendWaypointCmd(double lat, double lon, const QString& droneKeyOrAddr);


    Q_INVOKABLE DroneClass *getDrone(int index) const;
    // Declaration for retrieving the drone list
    Q_INVOKABLE QVariantList getAllDrones() const;
    QVariantList drones() const { return m_dronesVariant; }
    void rebuildVariant();
    Q_INVOKABLE QObject* getDroneByNameQML(const QString &name) const;

public slots:
    void saveDroneToDB(const QSharedPointer<DroneClass> &drone);
    void createDrone(const QString &name,
                     const QString &role,
                     const QString &xbeeID,
                     const int &sysID,
                     const int &compID,
                     const QString &xbeeAddress);
    void updateDrone(const QSharedPointer<DroneClass> &drone);
    void deleteDrone(const QString &xbeeid);
    void deleteALlDrones_UI();

    // Process data recieved from XBee via shared memory
    void processXbeeData();
    void tryConnectToDataFile();
    void onMavlinkMessage(const RxMavlinkMsg& msg);
    void addSITLDroneToList(int sysID, int compID);
    void addSITLDroneToList(QSharedPointer<DroneClass> drone);

signals:
    void droneAdded(const QSharedPointer<DroneClass> &drone);
    void droneUpdated(const QSharedPointer<DroneClass> &drone);
    void droneDeleted(const QSharedPointer<DroneClass> &drone);
    void droneStateChanged(const DroneClass *drone);
    void xbeeConnectionChanged(bool connected);
    void dronesChanged();

private:
    DBManager &dbManager;

    QTimer simulationTimer; // Timer for simulated movement
    QTimer xbeeDataTimer;   // Timer for data polling
    QTimer reconnectTimer;  // Timer for data polling
    
    std::unique_ptr<XbeeLink>    xbee_;
    std::unique_ptr<MavlinkSender> mav_;
    std::unique_ptr<MavlinkReceiver> mavRx_;
    QHash<uint8_t, QSharedPointer<DroneClass>> sysMap_;
    static QList<QSharedPointer<DroneClass>> droneList;
    
    QSharedPointer<DroneClass> getDroneByName(const QString &name);
    QSharedPointer<DroneClass> getDroneByXbeeAddress(const QString &address);
    QString getLatestXbeeData(); // Get latest data from file (TODO: OUTDATED)
    QString getDataFilePath();
    QString getConfigFilePath() const;
    void simulateDroneMovement(); // Function to move a drone periodically
    void updateDroneTelem(uint8_t sysid, const QString& field, const QVariant& value);
    void onTelemetry(const QString& name, double lat, double lon);

    // Trying out caching QVariantList for QML property usage
    QVariantList m_dronesVariant; // cached QObject* view for QML

    QSharedPointer<DroneClass> demo_lazybinding(int sysid); // DELETE --- DEMO
};

#endif // DRONECONTROLLER_H
