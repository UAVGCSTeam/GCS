#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QList>
#include <QObject>
#include <QSharedMemory>
#include <QSharedPointer>
#include <QTimer>
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
    Q_INVOKABLE QVariantList getDrones() const;
    Q_INVOKABLE bool openXbee(const QString &port, int baud = 57600);
    Q_INVOKABLE bool sendArm(const QString &droneKeyOrAddr, bool arm = true);

    Q_INVOKABLE DroneClass *getDrone(int index) const;
    // Declaration for retrieving the drone list
    Q_INVOKABLE QVariantList getAllDrones() const;
    QVariantList drones() const { return m_dronesVariant; }
    void rebuildVariant();
    Q_INVOKABLE QObject* getDroneByNameQML(const QString &name) const;

public slots:
    void saveDroneToDB(const QSharedPointer<DroneClass> &drone);
    void createDrone(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const QString &input_xbeeAddress,
                       double input_batteryLevel,
                       double input_latitude,
                       double input_longitude,
                       double input_altitude,
                       QObject *parent);
    void updateDrone(const QSharedPointer<DroneClass> &drone);
    void deleteDrone(const QString &xbeeid);
    void deleteALlDrones_UI();
    
    // Functions for serial / MAVLink connections
    void onMavlinkMessage(const RxMavlinkMsg& msg);

signals:
    void droneAdded(const QSharedPointer<DroneClass> &drone);
    void droneUpdated(const QSharedPointer<DroneClass> &drone);
    void droneDeleted(const QSharedPointer<DroneClass> &drone);
    void droneStateChanged(const DroneClass *drone);
    void dronesChanged();

private:
    DBManager &dbManager;

    std::unique_ptr<XbeeLink>    xbee_;
    std::unique_ptr<MavlinkSender> mav_;
    std::unique_ptr<MavlinkReceiver> mavRx_;
    QHash<uint8_t, QSharedPointer<DroneClass>> sysMap_;
    static QList<QSharedPointer<DroneClass>> droneList;
    
    QSharedPointer<DroneClass> getDroneByName(const QString &name);
    QSharedPointer<DroneClass> getDroneByXbeeAddress(const QString &address);
    void updateDroneTelem(uint8_t sysid, const QString& field, const QVariant& value);
    void onTelemetry(const QString& name, double lat, double lon);

    // Trying out caching QVariantList for QML property usage
    QVariantList m_dronesVariant; // cached QObject* view for QML
};

#endif // DRONECONTROLLER_H
