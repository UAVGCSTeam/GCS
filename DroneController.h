#ifndef DRONECONTROLLER_H
#define DRONECONTROLLER_H

#include <QList>
#include <QCoreApplication>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSharedPointer>
#include <QSharedMemory>
#include <QMetaType>
#include <QFile>
#include <QTextStream>
#include <QHash>
#include <QByteArray>
#include <cstdint>

#include "DroneClass.h"
#include "backend/dbmanager.h"
#include "MAVLinkReceiver.h"
#include "MAVLinkSender.h"
#include "UARTLink.h"
#include "UDPLink.h"



// DATA PATH
#ifdef _WIN32
// Try both the original path and the user's temp directory
#define DEFAULT_DATA_FILE_PATH "C:/tmp/xbee_data.json" // Windows path
#else
#define DEFAULT_DATA_FILE_PATH "/tmp/xbee_data.json" // Unix/Mac path
#endif

extern "C" {
#if __has_include(<mavlink/common/mavlink.h>)
#include <mavlink/common/mavlink.h>
#else
#include <common/mavlink.h>
#endif
}




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
class UDPLink;
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
    Q_INVOKABLE bool openUdp(quint16 localPort,
                             const QString &remoteHost = QStringLiteral("127.0.0.1"),
                             quint16 remotePort = 14550);

    
    /**
     * function sendArm() 
     * @brief Sends an arm or disarm command to a drone via MAVLink.
     *
     * Resolves the specified drone using its XBee address (or key), constructs
     * a MAV_CMD_COMPONENT_ARM_DISARM command, and transmits it over the active
     * MAVLink/XBee link.
     *
     * @param droneKeyOrAddr  The drone identifier or XBee address used to resolve
     *                        the target drone.
     * @param arm             If true, sends an ARM command; if false, sends DISARM.
     *
     * @return true if the command was successfully written to the MAVLink link;
     *         false if the drone could not be resolved, the MAVLink sender is not
     *         initialized, the link is not open, or transmission fails.
     *
     * @note Requires a valid and open MAVLink link (openUART() must be called first).
     */
    Q_INVOKABLE bool sendArm(const QString &droneKeyOrAddr, bool arm = true);


    /**
     * function sendTakeoffCmd()
     * @brief Sends a MAVLink takeoff command to the specified drone.
     *
     * This function issues a MAV_CMD_NAV_TAKEOFF command to the target drone,
     * instructing it to take off to a predefined altitude (5 meters above home).
     * The drone is identified using the provided key or XBee address.
     *
     * Behavior:
     * - If @p takeoff is false, the function performs no action and returns true.
     * - If the drone cannot be resolved, a warning is logged and false is returned.
     * - If the MAVLink transmitter is not initialized or the link is not open,
     *   a warning is logged and false is returned.
     * - Otherwise, a takeoff command is sent via MAVLink.
     *
     * Command parameters:
     * - pitch = 0.0f
     * - yaw   = 0.0f
     * - latitude/longitude = 0.0f (use current position for ArduCopter)
     * - altitude = 5.0f (meters above home position)
     *
     * @param droneKeyOrAddr  Identifier used to locate the drone (e.g., XBee address).
     * @param takeoff         If true, a takeoff command is sent. If false,
     *                        no command is sent and the function returns true.
     *
     * @return true if:
     *         - @p takeoff is false, or
     *         - the takeoff command was successfully queued/sent.
     *         Returns false if the drone was not found, the link is not open,
     *         or the send operation failed.
     *
     * @note Requires a valid and open MAVLink transport (e.g., openUDP() or openUART()).
     * @note The altitude is hardcoded to 5 meters AGL (above home).
     *
     * @warning No pre-arm checks or flight mode validation are performed here.
     *          The flight controller must be armed and in a mode that permits takeoff.
     */
    Q_INVOKABLE bool sendTakeoffCmd(const QString &droneKeyOrAddr, bool takeoff);

    Q_INVOKABLE bool sendToCoord(const QString droneName, float lat, float lon);

    /**
     * function sendGuidedMode()
     * @brief Sends a MAVLink command to set the target drone to Guided mode.
     *
     * This function resolves a drone instance using the provided identifier
     * (XBeeAddress or key), verifies that the MAVLink transmission interface
     * is ready, and sends a MAV_CMD_DO_SET_MODE command to the target system.
     *
     * The command is sent with:
     * - param1 = MAV_MODE_FLAG_CUSTOM_MODE_ENABLED
     * - param2 = 4.0f (custom mode value corresponding to GUIDED)
     *
     * If the drone cannot be found or the MAVLink sender is not initialized
     * or open, the function logs a warning and returns false.
     *
     * @param droneKeyOrAddr   Identifier used to locate the drone (e.g., XBee address).
     * @param enableGuidedMode Boolean flag indicating intent to enable or disable
     *                         Guided mode. Currently not used in command construction;
     *                         the function always sends a request to enable GUIDED mode.
     *
     * @return true if the command was successfully queued/sent by the MAVLink
     *         transmitter; false if the drone was not found, the link is not open,
     *         or the send operation failed.
     *
     * @note Requires a valid and open MAVLink transport (e.g., openUDP() or openUART()).
     * @note The GUIDED mode value (4.0f) assumes ArduPilot-compatible custom modes.
     *       Mode mappings may differ across firmware types.
     *
     * @warning The @p enableGuidedMode parameter is not currently used to toggle
     *          modes and does not disable Guided mode when false.
     */
    Q_INVOKABLE bool sendGuidedMode(const QString& droneKeyOrAddr, bool enableGuidedMode);


    /**
     * function requestTelem()
     * @brief Requests periodic telemetry messages (streamed) from the target vehicle.
     *
     * Sends MAV_CMD_SET_MESSAGE_INTERVAL commands to configure the autopilot
     * to stream selected MAVLink telemetry messages at 2 Hz (500,000 µs interval).
     *
     * Each message is requested using COMMAND_LONG with:
     *   param1 = message ID
     *   param2 = interval in microseconds
     *
     * @param targetSysID     MAVLink system ID of the target vehicle.
     * @param targetCompID  MAVLink component ID (typically MAV_COMP_ID_AUTOPILOT1).
     *
     * @return true if all message interval requests were successfully written
     *         to the link; false if the link is null, not open, or any write fails.
     *
     * @note Requires a valid and open MAVLink link.
     * @note The vehicle will continue streaming messages at the requested rate
     *       until the interval is changed or the vehicle reboots.
     */
    Q_INVOKABLE bool requestTelem(QSharedPointer<DroneClass> drone);
    
    Q_INVOKABLE DroneClass *getDrone(int index) const;
    // Declaration for retrieving the drone list
    Q_INVOKABLE QVariantList getAllDrones() const;
    QVariantList drones() const { return m_dronesVariant; }
    void rebuildVariant();
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
    bool updateDrone(const QSharedPointer<DroneClass> &drone);
    void deleteDrone(const QString &xbeeid);
    void deleteALlDrones_UI();
    
    // Functions for serial / MAVLink connections
    void onMavlinkMessage(const RxMavlinkMsg& msg);
    
    //temporary
    void setCheckedHeartBeat(bool checked) {
        checkHeartBeat = checked;
    }

signals:
    void droneAdded(const QSharedPointer<DroneClass> &drone);
    void droneDeleted(const QSharedPointer<DroneClass> &drone);
    void droneStateChanged(const DroneClass *drone);
    void dronesChanged();

private:
    QTimer heartBeatSimTimer; //temporary
    // QTimer simulationTimer;       // Timer for simulated movement
    // void simulateDroneMovement(); // Function to move a drone periodically
    QHash<QString, QList<QVariantMap>> droneWaypoints; // droneName -> list of waypoints

    //temporary heartbeat sim
    void simHeartbeat();
    bool checkHeartBeat = false;

    DBManager &dbManager;

    std::unique_ptr<UARTLink>    uartDevice_;
    std::unique_ptr<UDPLink>     udp_;
    std::unique_ptr<MAVLinkSender> mavTx_;
    std::unique_ptr<MAVLinkReceiver> mavRx_;
    QHash<uint32_t, QSharedPointer<DroneClass>> dronesMap_;
    static QList<QSharedPointer<DroneClass>> droneList;
    
    QSharedPointer<DroneClass> getDroneByName(const QString &name);
    QSharedPointer<DroneClass> getDroneByXbeeAddress(const QString &address);
    void updateDroneTelem(QSharedPointer<DroneClass> drone, const QString& field, const QVariant& value);

    /**
     * function onUdpBytesReceived()
     * @brief FOR DEBUGGING: Handles raw UDP payloads received from the active link.
     *
     * This function is invoked when a UDP datagram is received. It logs
     * the total number of bytes received and prints a hexadecimal preview
     * of the payload (up to the first 32 bytes) for diagnostic purposes.
     *
     * Behavior:
     * - Computes the total payload size.
     * - Extracts up to the first 32 bytes.
     * - Converts the preview portion to a space-separated hexadecimal string.
     * - Emits a debug log entry containing the size and preview data.
     *
     * @param bytes  Raw UDP datagram payload.
     *
     * @note This function performs logging only and does not parse or process
     *       the payload contents.
     * @note Logging large volumes of UDP traffic may impact performance
     *       when debug output is enabled.
     */
    void onUdpBytesReceived(const QByteArray& bytes);

    // Trying out caching QVariantList for QML property usage
    QVariantList m_dronesVariant; // cached QObject* view for QML
};

#endif // DRONECONTROLLER_H
