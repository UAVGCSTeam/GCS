#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QObject>
#include <QList>
#include "backend/dbmanager.h"
#include "DroneClass.h"
#include <QSharedPointer>
#include <QSharedMemory>
#include <QTimer>
#include <memory>
#include <cstdint>
#include <QHash>
#include <QVariant>
#include "MAVLinkReceiver.h"   // brings RxMavlinkMsg and its Q_DECLARE_METATYPE



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



class UARTLink;
class MAVLinkSender;
class MAVLinkReceiver;

class DroneController : public QObject 
{
    Q_OBJECT
    Q_PROPERTY(QVariantList drones READ drones NOTIFY dronesChanged)
public:
    // idk how to pass the parent function
    explicit DroneController(DBManager &gcsdb_in, QObject *parent = nullptr);
    ~DroneController();

    Q_INVOKABLE QVariantList getDrones() const;
    Q_INVOKABLE bool openUART(const QString &port, int baud = 57600);
    Q_INVOKABLE bool sendArm(const QString &droneKeyOrAddr, bool arm = true);

    Q_INVOKABLE DroneClass *getDrone(int index) const;
    // Declaration for retrieving the drone list
    Q_INVOKABLE QVariantList getAllDrones() const;
    QVariantList drones() const { return m_dronesVariant; }
    void rebuildVariant();
    Q_INVOKABLE QObject* getDroneByNameQML(const QString &name) const;
    Q_INVOKABLE void updateWaypoints(const QString &droneName, const QVariantList &wps)
    {
        QList<QVariantMap> list;
        for (const QVariant &v : wps)
            list.append(v.toMap());
        droneWaypoints[droneName] = list;
    }

  Q_INVOKABLE void renameDrone(const QString &xbeeID, const QString &newName);
  Q_INVOKABLE void setXbeeAddress(const QString &xbeeID, const QString &newXbeeAddress);
  Q_INVOKABLE void setBatteryLevel(const QString &xbeeID, const double &newBattery);
  Q_INVOKABLE void setRole(const QString &xbeeID, const QString &newRole);
  Q_INVOKABLE void setXbeeID(const QString &xbeeID, const QString &newXbeeID);
  Q_INVOKABLE void setPosition(const QString &xbeeID, const QVector3D &newPosition);
  Q_INVOKABLE void setLatitude(const QString &xbeeID, const double &newLatitude);
  Q_INVOKABLE void setLongitude(const QString &xbeeID, const double &newLongitude);
  Q_INVOKABLE void setAltitude(const QString &xbeeID, const double &newAltitude);
  Q_INVOKABLE void setVelocity(const QString &xbeeID, const QVector3D &newVelocity);
  Q_INVOKABLE void setAirspeed(const QString &xbeeID, const double &newAirspeed);
  Q_INVOKABLE void setOrientation(const QString &xbeeID, const QVector3D &newOrientation);

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
    void droneDeleted(const QSharedPointer<DroneClass> &drone);
    void droneStateChanged(const DroneClass *drone);
    void dronesChanged();

private:
    QTimer simulationTimer;       // Timer for simulated movement
    void simulateDroneMovement(); // Function to move a drone periodically
    QHash<QString, QList<QVariantMap>> droneWaypoints; // droneName -> list of waypoints
    DBManager &dbManager;

    std::unique_ptr<UARTLink>    uartDevice_;
    std::unique_ptr<MAVLinkSender> mav_;
    std::unique_ptr<MAVLinkReceiver> mavRx_;
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
