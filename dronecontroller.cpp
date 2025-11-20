#include "dronecontroller.h"
#include "droneclass.h"
#include "XbeeLink.h"
#include "MavlinkReceiver.h"
#include "MavlinkSender.h"
#include <QDebug>
#include <memory>
#include "MavlinkReceiver.h"
#include <QMetaType>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QDir>
#include <QCoreApplication>
#include <QTextStream>
#include <QStandardPaths>

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

QList<QSharedPointer<DroneClass>> DroneController::droneList; // Define the static variable

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db)
{
    int index = 0; 

    // function loads all drones from the database on startup
    qRegisterMetaType<mavlink_message_t>("mavlink_message_t");
    QList<QVariantMap> droneRecords = dbManager.fetchAllDrones();
    for (const QVariantMap &record : droneRecords)
    {
        QString name = record["drone_name"].toString();
        QString role = record["drone_role"].toString();
        QString xbeeID = record["xbee_id"].toString();
        int sysID = -1;
        int compID = -1;
        QString xbeeAddress = record["xbee_address"].toString();
        // Should? work with other fields like xbee_id or drone_id if needed
        // existing table can have added columns for the lati and longi stuff and input here
        // TODO: Change this, add xbee id?
        
        if (index == 0) { 
            droneList.append(QSharedPointer<DroneClass>::create(name, role, xbeeID, xbeeAddress, 67, 34.06126372594308, -117.83284231468927, 10, nullptr));
        } else if (index == 1) { 
            droneList.append(QSharedPointer<DroneClass>::create(name, role, xbeeID, xbeeAddress, 67, 34.06202196849312, -117.82905560740794, 10, nullptr));
        } else if (index == 2) { 
            droneList.append(QSharedPointer<DroneClass>::create(name, role, xbeeID, xbeeAddress, 67, 34.06025272532348, -117.82775448760746, 10, nullptr));
        } else { 
            droneList.append(QSharedPointer<DroneClass>::create(name, role, xbeeID, xbeeAddress, 67, 34.059174611493965, -117.82051240067321, 10, nullptr));
        }
        
        index++;
    }
    qDebug() << "Loaded" << droneList.size() << "drones from the database.";
}

// method so QML can retrieve the drone list.
QVariantList DroneController::getAllDrones() const
{
    // qInfo() << "DEBUGGING" << Qt::endl;
    // int index = 0;
    QVariantList list;
    for (const QSharedPointer<DroneClass> &drone : droneList)
    {
        QVariantMap droneMap;
        // these method calls have to match our DroneClass interface
        droneMap["name"] = drone->getName();
        droneMap["role"] = drone->getRole(); // <-- we been using "drone type" in UI and everything but its called drone role in droneclass.h lul
        droneMap["xbeeId"] = drone->getXbeeID();
        droneMap["xbeeAddress"] = drone->getXbeeAddress();
        // Adds placeholder values for status and battery and leave other fields blank
        droneMap["status"] = drone->getBatteryLevel() > 0 ? "Connected" : "Not Connected";
        droneMap["battery"] = drone->getBatteryLevel() > 0 ? QString::number(drone->getBatteryLevel()) + "%" : "Battery not received";

        droneMap["latitude"] = drone->getLatitude();
        droneMap["longitude"] = drone->getLongitude();
        droneMap["altitude"] = drone->getAltitude();
        droneMap["airspeed"] = drone->getAirspeed();

        list.append(droneMap);
        // index++;
    }
    return list;
}

DroneController::~DroneController()
{
    // Cleanup code if needed
    if (xbeeDataTimer.isActive())
    {
        xbeeDataTimer.stop();
    }
    if (reconnectTimer.isActive())
    {
        reconnectTimer.stop();
    }
}

// Get the correct file path to check
QString DroneController::getDataFilePath()
{
    // On Windows, always check user's TEMP folder first
#ifdef _WIN32
    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString tempFilePath = tempPath + "/xbee_tmp/xbee_data.json";

    QFile tempFile(tempFilePath);
    if (tempFile.exists())
    {
        qDebug() << "Using Windows temp path:" << tempFilePath;
        return tempFilePath;
    }

    // Log the paths we're checking to aid debugging
    qDebug() << "Checked for XBee data file at:" << tempFilePath << "(not found)";
#endif

    // Original fallback paths
    QFile file(DEFAULT_DATA_FILE_PATH);
    if (file.exists())
    {
        qDebug() << "Using default path:" << DEFAULT_DATA_FILE_PATH;
        return DEFAULT_DATA_FILE_PATH;
    }
    qDebug() << "Checked for XBee data file at:" << DEFAULT_DATA_FILE_PATH << "(not found)";

#ifdef _WIN32
    // Additional Windows fallbacks
    QString fallbackPath = tempPath + "/xbee_data.json";
    QFile fallbackFile(fallbackPath);
    if (fallbackFile.exists())
    {
        qDebug() << "Using fallback path:" << fallbackPath;
        return fallbackPath;
    }
    qDebug() << "Checked for XBee data file at:" << fallbackPath << "(not found)";
#endif

    // Return the default path if nothing else found
    return DEFAULT_DATA_FILE_PATH;
}

// Steps in saving a drone.
/* User Clicks button to save drone information
 * Saving Drone
 * 1. Added To Database
 * 2. Added as Drone Object ?
 * 3. Added to a List of Drones from DroneManager
 * 4. Automatically view
 *
 * Viewable Drone
 */

// new function so the QML can create a drone using strings
void DroneController::createDrone(const QString &input_name,
                                const QString &input_role,
                                const QString &input_xbeeID,
                                const QString &input_xbeeAddress,
                                double input_batteryLevel,
                                double input_latitude,
                                double input_longitude,
                                double input_altitude,
                                QObject *parent)
{
    auto drone = QSharedPointer<DroneClass>::create();
    drone->setName(input_name);
    drone->setRole(input_role);
    drone->setXbeeID(input_xbeeID);
    drone->setXbeeAddress(input_xbeeAddress);
    drone->setBatteryLevel(input_batteryLevel);
    drone->setLatitude(input_latitude);
    drone->setLongitude(input_longitude);
    drone->setAltitude(input_altitude);
    saveDroneToDB(drone); // call the internal method
}


void DroneController::saveDroneToDB(const QSharedPointer<DroneClass> &drone)
{
    // remmber to update db appropriately as well
    if (!drone)
        return;

    qDebug() << "saveDroneToDB called with:" << drone->getName()
             << drone->getRole()
             << drone->getXbeeID()
             << drone->getXbeeAddress();

    // Avoid duplicates
    for (const auto &d : droneList)
    {
        if (d->getXbeeAddress() == drone->getXbeeAddress())
        {
            qDebug() << "Drone already exists with address:" << drone->getXbeeAddress();
            return;
        }
    }

    // Add Drone to Database
    int newDroneID = -1;
    if (dbManager.createDrone(drone->getName(),
                              drone->getRole(),
                              drone->getXbeeID(),
                              drone->getXbeeAddress(),
                              &newDroneID))
    {
        qDebug() << "Drone created in DB successfully with ID:" << newDroneID;

        // Add to the in-memory list
        droneList.push_back(drone);

        qDebug() << "About to emit dronesChanged and droneAdded signals after adding drone";
        emit droneAdded(drone); // right now this is not being used anywhere
        emit dronesChanged();
        // Adding update to the new QML list
        rebuildVariant();
        qDebug() << "dronesChanged signal emitted";
        qDebug() << "Drone saved:" << drone->getName();
    }
    else
    {
        qWarning() << "Failed to save drone to DB:" << drone->getName();
    }
}

void DroneController::updateDrone(const QSharedPointer<DroneClass> &drone)
{
    // Find the drone in our list by its xbeeID (im assuming is unique)
    if (!drone)
        return;

    for (int i = 0; i < droneList.size(); ++i)
    {
        if (droneList[i]->getXbeeID() == drone->getXbeeID())
        {
            // Update in-memory
            droneList[i]->setName(drone->getName());
            droneList[i]->setRole(drone->getRole());
            droneList[i]->setXbeeID(drone->getXbeeID());
            droneList[i]->setXbeeAddress(drone->getXbeeAddress());

            // Update database
            QSqlQuery query;
            query.prepare("SELECT drone_id FROM drones WHERE xbee_id = :xbeeId");
            query.bindValue(":xbeeId", drone->getXbeeID());
            if (query.exec() && query.next())
            {
                int droneID = query.value(0).toInt();
                dbManager.editDrone(droneID,
                                    drone->getName(),
                                    drone->getRole(),
                                    drone->getXbeeID(),
                                    drone->getXbeeAddress());
            }

            emit droneUpdated(drone);
            emit dronesChanged();
            // Adding update to the new QML list
            rebuildVariant();
            qDebug() << "Drone updated:" << drone->getName();
            break;
        }
    }
}

void DroneController::deleteDrone(const QString &input_xbeeID)
{
    if (input_xbeeID.isEmpty())
    {
        qWarning() << "Drone Controller: xbeeID not passed by UI.";
        return;
    }

    // Try to find and delete the drone from memory first
    bool found = false;
    for (int i = 0; i < droneList.size(); i++)
    {
        if (droneList[i]->getXbeeID() == input_xbeeID ||
            droneList[i]->getXbeeAddress() == input_xbeeID)
        {
            droneList.removeAt(i);
            found = true;
            qDebug() << "Removed drone from memory with ID/address:" << input_xbeeID;
            break;
        }
    }

    // Now delete from database, even if not found in memory
    if (dbManager.deleteDrone(input_xbeeID))
    {
        qDebug() << "Drone deleted successfully from database:" << input_xbeeID;
        emit dronesChanged();
        // Adding update to the new QML list
        rebuildVariant();
    }
    else
    {
        qWarning() << "Failed to delete drone from database:" << input_xbeeID;
        // If we removed from memory but failed to delete from DB, sync
        if (found)
        {
            emit dronesChanged();
            // Adding update to the new QML list
            rebuildVariant();
        }
    }
}

// if we're being honest the slots being called by any function is in my head and i cant figure out if i need something rn
void DroneController::deleteALlDrones_UI()
{
    if (dbManager.deleteAllDrones())
    {
        droneList.clear(); // also delete drones in C++ memory

        qDebug() << "[dronecontroller.cpp]: All drones deleted successfully!";
        // Adding update to the new QML list
        rebuildVariant();
        emit dronesChanged();

        addNewDrone = true; // DELETE THIS -- DEMO
    }
    else
    {
        qWarning() << "Failed to delete all drones.";
    }
}


QString DroneController::getConfigFilePath() const
{
    QString configPath;

#ifdef _WIN32
    // Windows: User's AppData folder
    configPath = QDir::homePath() + "/AppData/Local/GCS";
#elif defined(__APPLE__)
    // macOS
    configPath = QDir::homePath() + "/Library/Application Support/GCS";
#else
    // Linux and other Unix systems
    configPath = QDir::homePath() + "/.config/gcs";
#endif

    // Make sure the directory exists
    QDir dir(configPath);
    if (!dir.exists())
    {
        dir.mkpath(".");
    }

    configPath += "/xbee_config.json";
    qDebug() << "Config file path:" << configPath;
    return configPath;
}

// If want to query by name
QSharedPointer<DroneClass> DroneController::getDroneByName(const QString &name)
{
    for (const auto &drone : droneList)
    {
        if (drone->getName() == name)
        {
            return drone;
        }
    }
    return QSharedPointer<DroneClass>(); // Return null pointer if not found
}

// If want to query by address
QSharedPointer<DroneClass> DroneController::getDroneByXbeeAddress(const QString &address)
{
    qDebug() << "Looking for drone with address:" << address;

    // First try exact address match
    for (const auto &drone : droneList)
    {
        if (drone->getXbeeAddress() == address)
        {
            qDebug() << "Found drone by address:" << drone->getName();
            return drone;
        }
    }

    // If not found, try xbeeID match
    for (const auto &drone : droneList)
    {
        if (drone->getXbeeID() == address)
        {
            qDebug() << "Found drone by XBee ID:" << drone->getName();
            return drone;
        }
    }

    // Attempt a more flexible match (case insensitive, partial)
    for (const auto &drone : droneList)
    {
        if (drone->getXbeeAddress().contains(address, Qt::CaseInsensitive) ||
            address.contains(drone->getXbeeAddress(), Qt::CaseInsensitive))
        {
            qDebug() << "Found drone by partial address match:" << drone->getName();
            return drone;
        }
    }

    qDebug() << "No drone found with address:" << address;
    return QSharedPointer<DroneClass>(); // Return null pointer if not found
}

// Check if the data file exists
bool DroneController::checkDataFileExists()
{
    QString filePath = getDataFilePath();
    QFile file(filePath);
    if (file.exists())
    {
        qDebug() << "Found XBee data file at:" << filePath;
        return true;
    }
    else
    {
        qDebug() << "XBee data file not found at:" << filePath;
        return false;
    }
}

// Try to connect to the data file
void DroneController::tryConnectToDataFile()
{
    if (checkDataFileExists())
    {
        qDebug() << "Successfully found XBee data file";
        reconnectTimer.stop(); // Stop trying to reconnect

        // Start timer to check for XBee data
        xbeeDataTimer.start(50); // Check every 50ms
        emit xbeeConnectionChanged(true);
    }
}

QString DroneController::getLatestXbeeData()
{
    QString result;
    QString filePath = getDataFilePath();
    QFile file(filePath);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        result = QString::fromUtf8(file.readAll());
        file.close();
    }
    else
    {
        qWarning() << "Failed to open XBee data file:" << file.errorString();
    }

    return result;
}

// Gets drones, but is used to REBUILD the drone list; so it refreshes and keeps the drone list up to date
QVariantList DroneController::getDrones() const
{ // DOUBLE CHECK THIS BRANDON
    QVariantList result;

    // Ensure the database is open
    if (!dbManager.isOpen())
    {
        qWarning() << "Database is not open!";
        return result;
    }

    // Execute a simple SELECT query
    QSqlQuery query("SELECT drone_id, drone_name, drone_role, xbee_id, xbee_address FROM drones");

    if (query.exec())
    {
        while (query.next())
        {
            QVariantMap drone;
            drone["id"] = query.value(0).toInt();
            drone["name"] = query.value(1).toString();
            drone["role"] = query.value(2).toString(); // Changed from "type" to "role"
            drone["xbeeId"] = query.value(3).toString();
            drone["xbeeAddress"] = query.value(4).toString();
            result.append(drone);
        }
        qDebug() << "Found" << result.size() << "drones in database";

        // Initialize droneList with database contents
        droneList.clear();
        for (const QVariant &droneVar : result)
        {
            QVariantMap droneMap = droneVar.toMap();
            droneList.append(QSharedPointer<DroneClass>::create(
                droneMap["name"].toString(),
                droneMap["role"].toString(), // Changed from "type" to "role"
                droneMap["xbeeId"].toString(),
                droneMap["xbeeAddress"].toString()));
        }
    }
    else
    {
        qWarning() << "Failed to fetch drones from database:" << query.lastError().text();
    }

    return result;
}



DroneClass *DroneController::getDrone(int index) const
{
    if (index < 0 || index >= droneList.size())
    {
        qWarning() << "getDrone: index out of range" << index;
        return nullptr;
    }
    // QSharedPointer::data() gives you the raw pointer, ownership stays with the list
    return droneList.at(index).data();
}



bool DroneController::openXbee(const QString& port, int baud)
{
    if (!xbee_) xbee_ = std::make_unique<XbeeLink>(this);
    if (!mav_)  mav_  = std::make_unique<MavlinkSender>(xbee_.get(), this);

    //  set up receiver & wire signals
    if (!mavRx_) {
        mavRx_ = std::make_unique<MavlinkReceiver>(this);
        connect(xbee_.get(), &XbeeLink::bytesReceived,
                mavRx_.get(), &MavlinkReceiver::onBytes);
        connect(mavRx_.get(), &MavlinkReceiver::messageReceived,
                this,        &DroneController::onMavlinkMessage);
    }

    const bool ok = xbee_->open(port, baud);
    if (!ok) {
        qWarning() << "[DroneController] Failed to open XBee port" << port << "baud" << baud;
        return false;
    }
    qInfo()  << "[DroneController] XBee opened on" << port << "@" << baud;
    return true;
}


bool DroneController::sendArm(const QString& droneKeyOrAddr, bool arm)
{
    // Use your existing resolver so callers can pass either address or ID
    QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(droneKeyOrAddr);
    if (drone.isNull()) {
        qWarning() << "[DroneController] sendArm: unknown drone/address:" << droneKeyOrAddr;
        return false;
    }

    if (!mav_) {
        qWarning() << "[DroneController] MAVLink sender not ready; call openXbee() first";
        return false;
    }

    // TODO: make these configurable or read from DB later
    // targetSys and targetComp are both 0 when dealing with ArduPilot SITL
    const uint8_t targetSys  = 1;   
    const uint8_t targetComp = 1;   // MAV_COMP_ID_AUTOPILOT1

    const bool ok = mav_->sendArm(targetSys, targetComp, arm);
    qInfo() << "[DroneController] ARM" << (arm ? "ON" : "OFF")
            << "->" << drone->getName() << drone->getXbeeAddress()
            << "sent=" << ok;
    return ok;
}




// Helper: find (or lazily bind) a drone for a sysid.
// Header must have: QHash<uint8_t, QSharedPointer<DroneClass>> sysMap_;
QSharedPointer<DroneClass> droneForSysId_lazyBind(uint8_t sysid,
                                                  QList<QSharedPointer<DroneClass>>& list,
                                                  QHash<uint8_t, QSharedPointer<DroneClass>>& map)
{
    if (map.contains(sysid)) return map.value(sysid);
    if (!list.isEmpty()) {
        // TEMP heuristic: bind first drone we have (until you provide a real mapping)
        auto d = list.first();
        map.insert(sysid, d);
        qInfo() << "[DroneController] Bound sysid" << sysid << "to drone" << d->getName();
        return d;
    }
    return {};
}




void DroneController::onMavlinkMessage(const RxMavlinkMsg& m)
{
    // Rebuild a mavlink_message_t from the envelope so we can use decode helpers
    mavlink_message_t msg{};
    msg.sysid = m.sysid;
    msg.compid = m.compid;
    msg.msgid = static_cast<uint32_t>(m.msgid);
    msg.len   = static_cast<uint8_t>(m.payload.size());
    memcpy(_MAV_PAYLOAD_NON_CONST(&msg), m.payload.constData(), msg.len);

    uint8_t sysid = msg.sysid; 
    // qInfo() << "[onMavlinkMessage] received message";
        
    // qInfo() << "[onMavlinkMessage] Orientation: " << droneList[0]->getOrientation();

    switch (msg.msgid) {
    case MAVLINK_MSG_ID_HEARTBEAT: {
        // qInfo() << "Got a heartbeat";
        mavlink_heartbeat_t hb;
        mavlink_msg_heartbeat_decode(&msg, &hb);
        updateDroneTelem(sysid, "connected", true);
        updateDroneTelem(sysid, "base_mode",   static_cast<int>(hb.base_mode));
        updateDroneTelem(sysid, "custom_mode", static_cast<int>(hb.custom_mode));
        break;
    }
    case MAVLINK_MSG_ID_SYS_STATUS: {
        mavlink_sys_status_t s;
        mavlink_msg_sys_status_decode(&msg, &s);
        updateDroneTelem(sysid, "battery_v",   s.voltage_battery/1000.0);
        updateDroneTelem(sysid, "battery_pct", static_cast<int>(s.battery_remaining));
        break;
    }
    case MAVLINK_MSG_ID_GLOBAL_POSITION_INT: {
        mavlink_global_position_int_t p;
        mavlink_msg_global_position_int_decode(&msg, &p);
        updateDroneTelem(sysid, "lat",   p.lat/1e7);
        updateDroneTelem(sysid, "lon",   p.lon/1e7);
        // updateDroneTelem(sysid, "alt_m", p.alt/1000.0);
        updateDroneTelem(sysid, "alt_m", p.relative_alt / 1000.0);
        break;
    }
    case MAVLINK_MSG_ID_ATTITUDE: {
        // qInfo() << "Got attitude";
        mavlink_attitude_t a;
        mavlink_msg_attitude_decode(&msg, &a);
        updateDroneTelem(sysid, "roll", a.roll);
        updateDroneTelem(sysid, "pitch", a.pitch);
        updateDroneTelem(sysid, "yaw",  a.yaw);
        break;
    }
    case MAVLINK_MSG_ID_COMMAND_ACK: {
        // qInfo() << "Got msg id ack";
        mavlink_command_ack_t ack;
        mavlink_msg_command_ack_decode(&msg, &ack);
        qInfo().nospace()
            << "[MAVRX] COMMAND_ACK cmd=" << ack.command
            << " result=" << static_cast<int>(ack.result)
            << " (sysid=" << static_cast<int>(sysid)
            << ", compid=" << static_cast<int>(msg.compid) << ")";

        updateDroneTelem(sysid, "last_command", static_cast<int>(ack.command));
        updateDroneTelem(sysid, "last_result",  static_cast<int>(ack.result));
        break;
    }
    default:
        break;
    }
}


void DroneController::updateDroneTelem(uint8_t sysid, const QString& field, const QVariant& value)
{
    // NOTE: add 'sysMap_' as a private member in your header:
    //   QHash<uint8_t, QSharedPointer<DroneClass>> sysMap_;
    auto d = droneForSysId_lazyBind(sysid, droneList, sysMap_);
    if (d.isNull()) return;

    if (field == "connected") {
        d->setConnected(value.toBool());                 // if you have it
    } else if (field == "battery_v") {
        d->setBatteryVoltage(value.toDouble());          // or setBatteryLevel if that's what you track
    } else if (field == "battery_pct") {
        d->setBatteryLevel(value.toInt());               // 0–100
    } else if (field == "lat") {
        d->setLatitude(value.toDouble());
    } else if (field == "lon") {
        d->setLongitude(value.toDouble());
    } else if (field == "alt_m") {
        d->setAltitude(value.toDouble());
    } else if (field == "roll") {
        d->setRoll(value.toDouble());                    // if you surface attitude
    } else if (field == "pitch") {
        d->setPitch(value.toDouble());
    } else if (field == "yaw") {
        d->setYaw(value.toDouble());
    } else if (field == "base_mode" || field == "custom_mode") {
        d->setModeField(field, value);                   // generic hook if you prefer
    }

    emit dronesChanged();
    // emit droneStateChanged(d->getName());
} 


// Called when the droneList is updated
void DroneController::rebuildVariant()
{
    m_dronesVariant.clear();
    m_dronesVariant.reserve(droneList.size());
    for (const auto &sp : droneList)
    {
        m_dronesVariant << QVariant::fromValue(static_cast<QObject *>(sp.data()));
    }
}


// Telemetry update for ONE existing drone (same object pointer)
void DroneController::onTelemetry(const QString &name, double lat, double lon)
{
    auto it = std::find_if(droneList.begin(), droneList.end(),
                           [&](const QSharedPointer<DroneClass> &d)
                           { return d->getName() == name; });
    if (it == droneList.end())
        return;
    (*it)->setLatitude(lat);  // emits latitudeChanged → QML updates
    (*it)->setLongitude(lon); // emits longitudeChanged
}



QObject* DroneController::getDroneByNameQML(const QString &name) const {
    for (const auto &sp : droneList) {                 // QList<QSharedPointer<DroneClass>>
        if (sp && sp->getName() == name)                  // use your getter names
        return static_cast<QObject*>(sp.data());   // expose raw QObject* to QML
    }
    return nullptr;
}

