#include "DroneController.h"


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
    qDebug() << "[DroneController.cpp] Loaded" << droneList.size() << "drones from the database.";

    // --- Simulated Drone Movement ---
    // connect(&simulationTimer, &QTimer::timeout, this, &DroneController::simulateDroneMovement);
    // simulationTimer.start(250); // Move once per second
    // qDebug() << "[DroneController.cpp] Simulation timer started for drone movement.";
}

// method so QML can retrieve the drone list.
QVariantList DroneController::getAllDrones() const
{
    // qInfo() << "[DroneController.cpp] DEBUGGING" << Qt::endl;
    // int index = 0;
    QVariantList list;
    for (const QSharedPointer<DroneClass> &drone : droneList)
    {
        QVariantMap droneMap;
        // these method calls have to match our DroneClass interface
        droneMap["name"] = drone->getName();
        droneMap["role"] = drone->getRole(); // <-- we been using "drone type" in UI and everything but its called drone role in DroneClass.h lul
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
}



// DroneClass updaters
// We're changing this here so that by default the DroneClass is 
// not able to be updated from QML. Only C++ can update drones
// in the DroneController class

void DroneController::renameDrone(const QString &xbeeID, const QString &newName) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            QString currentName = drone->getName(); 
            drone->setName(newName);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setName(currentName);
            }
            break;
        }
    }
}
void DroneController::setXbeeAddress(const QString &xbeeID, const QString &newXbeeAddress) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            QString currentXbeeAddress = drone->getName(); 
            drone->setXbeeAddress(newXbeeAddress);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setXbeeAddress(currentXbeeAddress);
            }
            break;
        }
    }
}
void DroneController::setBatteryLevel(const QString &xbeeID, const double &newBattery) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            double currentBatteryLevel = drone->getBatteryLevel(); 
            drone->setBatteryLevel(newBattery);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setBatteryLevel(currentBatteryLevel);
            }
            break;
        }
    }
}
void DroneController::setRole(const QString &xbeeID, const QString &newRole) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            QString currentRole = drone->getName(); 
            drone->setRole(newRole);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setRole(currentRole);
            }
            break;
        }
    }
}
void DroneController::setXbeeID(const QString &xbeeID, const QString &newXbeeID) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            QString currentXbeeID = drone->getName(); 
            drone->setXbeeID(newXbeeID);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setXbeeID(currentXbeeID);
            }
            break;
        }
    }
}
void DroneController::setPosition(const QString &xbeeID, const QVector3D &newPosition) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            QVector3D currentPosition = drone->getPosition(); 
            drone->setPosition(newPosition);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setPosition(currentPosition);
            }
            break;
        }
    }
}
void DroneController::setLatitude(const QString &xbeeID, const double &newLatitude) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            double currentLatitude = drone->getLatitude(); 
            drone->setLatitude(newLatitude);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setLatitude(currentLatitude);
            }
            break;
        }
    }
}
void DroneController::setLongitude(const QString &xbeeID, const double &newLongitude) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            double currentLongitude = drone->getLongitude(); 
            drone->setLongitude(newLongitude);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setLongitude(currentLongitude);
            }
            break;
        }
    }
}
void DroneController::setAltitude(const QString &xbeeID, const double &newAltitude) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            double currentAltitude = drone->getAltitude(); 
            drone->setAltitude(newAltitude);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setAltitude(currentAltitude);
            }
            break;
        }
    }
}
void DroneController::setVelocity(const QString &xbeeID, const QVector3D &newVelocity) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            QVector3D currentVelocity = drone->getVelocity(); 
            drone->setVelocity(newVelocity);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setVelocity(currentVelocity);
            }
            break;
        }
    }
}
void DroneController::setAirspeed(const QString &xbeeID, const double &newAirspeed) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            double currentAirspeed = drone->getAirspeed(); 
            drone->setAirspeed(newAirspeed);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setAirspeed(currentAirspeed);
            }
            break;
        }
    }
}
void DroneController::setOrientation(const QString &xbeeID, const QVector3D &newOrientation) {
    for (auto &drone : droneList) {
        if (drone->getXbeeID() == xbeeID) {
            QVector3D currentOrientation = drone->getOrientation(); 
            drone->setOrientation(newOrientation);
            bool response = updateDrone(drone);
            if (!response) {
                drone->setOrientation(currentOrientation);
            }
            break;
        }
    }
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

    qDebug() << "[DroneController.cpp::saveDroneToDB] saveDroneToDB called with:" << drone->getName()
             << drone->getRole()
             << drone->getXbeeID()
             << drone->getXbeeAddress();

    // Avoid duplicates
    for (const auto &d : droneList)
    {
        if (d->getXbeeAddress() == drone->getXbeeAddress())
        {
            qDebug() << "[DroneController.cpp::saveDroneToDB] Drone already exists with address:" << drone->getXbeeAddress();
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
        qDebug() << "[DroneController.cpp] Drone created in DB successfully with ID:" << newDroneID;

        // Add to the in-memory list
        droneList.push_back(drone);

        emit droneAdded(drone); // right now this is not being used anywhere
        emit dronesChanged();
        // Adding update to the new QML list
        rebuildVariant();
        qDebug() << "[DroneController.cpp] dronesChanged signal emitted";
        qDebug() << "[DroneController.cpp] Drone saved:" << drone->getName();
    }
    else
    {
        qWarning() << "Failed to save drone to DB:" << drone->getName();
    }
}

bool DroneController::updateDrone(const QSharedPointer<DroneClass> &drone)
{
    // Find the drone in our list by its xbeeID (im assuming is unique)
    if (!drone)
        return false;

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
            bool response = false;
            if (query.exec() && query.next())
            {
                int droneID = query.value(0).toInt();
                response = dbManager.editDrone(droneID,
                                    drone->getName(),
                                    drone->getRole(),
                                    drone->getXbeeID(),
                                    drone->getXbeeAddress());
            }

            if (response) {
                qInfo() << "[DroneController.cpp] Updated in storage. Updating in memory now";
                emit dronesChanged();
                rebuildVariant();
                return true;
            } else {
                qInfo() << "[DroneController.cpp] Failed to update storage. Not updating memory";
                return false;
            }
            break;
        }
    }

    return false;
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
            qDebug() << "[DroneController.cpp] Removed drone from memory with ID/address:" << input_xbeeID;
            break;
        }
    }

    // Now delete from database, even if not found in memory
    if (dbManager.deleteDrone(input_xbeeID))
    {
        qDebug() << "[DroneController.cpp] Drone deleted successfully from database:" << input_xbeeID;
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

        qDebug() << "[DroneController.cpp]: All drones deleted successfully!";
        // Adding update to the new QML list
        rebuildVariant();
        emit dronesChanged();
    }
    else
    {
        qWarning() << "Failed to delete all drones.";
    }
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
    // First try exact address match
    for (const auto &drone : droneList)
    {
        if (drone->getXbeeAddress() == address)
        {
            // qDebug() << "[DroneController.cpp::getDroneByXbeeAddress] Found drone by address:" << drone->getName();
            return drone;
        }
    }

    // If not found, try xbeeID match
    for (const auto &drone : droneList)
    {
        if (drone->getXbeeID() == address)
        {
            qDebug() << "[DroneController.cpp::getDroneByXbeeAddress] Found drone by XBee ID:" << drone->getName();
            return drone;
        }
    }

    // Attempt a more flexible match (case insensitive, partial)
    for (const auto &drone : droneList)
    {
        if (drone->getXbeeAddress().contains(address, Qt::CaseInsensitive) ||
            address.contains(drone->getXbeeAddress(), Qt::CaseInsensitive))
        {
            qDebug() << "[DroneController.cpp::getDroneByXbeeAddress] Found drone by partial address match:" << drone->getName();
            return drone;
        }
    }

    qDebug() << "[DroneController.cpp::getDroneByXbeeAddress] No drone found with address:" << address;
    return QSharedPointer<DroneClass>(); // Return null pointer if not found
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
        qDebug() << "[DroneController.cpp] Found" << result.size() << "drones in database";

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



bool DroneController::openUdp(quint16 localPort,
                              const QString& remoteHost,
                              quint16 remotePort)
{
    if (!udp_) {
        udp_ = std::make_unique<UdpLink>(this);
        connect(udp_.get(), &UdpLink::bytesReceived,
                this,        &DroneController::onUdpBytesReceived);
    }
    if (!mavTx_) mavTx_ = std::make_unique<MAVLinkSender>(udp_.get(), this);

    if (!mavRx_) {
        mavRx_ = std::make_unique<MAVLinkReceiver>(this);
        connect(udp_.get(), &UdpLink::bytesReceived,
                mavRx_.get(), &MAVLinkReceiver::onBytes);
        connect(mavRx_.get(), &MAVLinkReceiver::messageReceived,
                this,         &DroneController::onMavlinkMessage);
    }

    const bool ok = udp_->open(localPort, QHostAddress(remoteHost), remotePort);
    if (!ok) {
        qWarning() << "[DroneController.cpp] Failed to open UDP on port" << localPort;
        return false;
    }
    qInfo() << "[DroneController.cpp::openUDP] UDP opened on port" << localPort
            << "-> " << remoteHost << ":" << remotePort;
    return true;
}

void DroneController::onUdpBytesReceived(const QByteArray& bytes)
{
    const int size = bytes.size();
    const int previewLen = qMin(size, 32);
    QByteArray hex = bytes.left(previewLen).toHex(' ');
    // qDebug() << "[DroneController.cpp::onUdpBytesReceived] UDP received" << size << "bytes"
             // << (previewLen < size ? QString("(first %1):").arg(previewLen) : ":")
             // << hex;
}




bool DroneController::openUART(const QString& port, int baud)
{
    if (!uartDevice_) uartDevice_ = std::make_unique<UARTLink>(this);
    if (!mavTx_)  mavTx_  = std::make_unique<MAVLinkSender>(uartDevice_.get(), this);

    //  set up receiver & wire signals
    if (!mavRx_) {
        mavRx_ = std::make_unique<MAVLinkReceiver>(this);
        connect(uartDevice_.get(), &UARTLink::bytesReceived,
                mavRx_.get(), &MAVLinkReceiver::onBytes);
        connect(mavRx_.get(), &MAVLinkReceiver::messageReceived,
                this,        &DroneController::onMavlinkMessage);
    }

    const bool ok = uartDevice_->open(port, baud);
    if (!ok) {
        qWarning() << "[DroneController.cpp::openUART] Failed to open UART port" << port << "baud" << baud;
        return false;
    }
    qInfo()  << "[DroneController.cpp::openUART] UART opened on" << port << "@" << baud;
    return true;
}


bool DroneController::sendArm(const QString& droneKeyOrAddr, bool arm)
{
    QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(droneKeyOrAddr);
    if (drone.isNull()) {
        qWarning() << "[DroneController.cpp::sendArm] sendArm: unknown drone/address:" << droneKeyOrAddr;
        return false;
    }
    // qDebug() << "[DroneController.cpp::sendArm] Found drone:" << drone->getName() << "with sysID:" << drone->getSysID() << "and compID:" << drone->getCompID();

    if (!mavTx_ || !mavTx_->linkOpen()) {
        qWarning() << "[DroneController.cpp::sendArm] MAVLink sender not ready; call openUDP() or openUART() first";
        return false;
    }

    const uint8_t targetSysID  = drone->getSysID();   
    const uint8_t targetCompID = drone->getCompID();

    // use the MAVLinkSender class to package and send the signal
    bool response = mavTx_->sendCommand(
        targetSysID,
        targetCompID,
        MAV_CMD_COMPONENT_ARM_DISARM,
        arm ? 1.0f : 0.0f);

    // qInfo() << "[DroneController.cpp::sendArm] Arm" << (arm ? "ON" : "OFF")
    //         << "->" << drone->getName() << drone->getXbeeAddress()
    //         << "sent=" << response;
    return response;
}


bool DroneController::sendTakeoffCmd(const QString& droneKeyOrAddr, bool takeoff) { 
    if (!takeoff) {
        return true;
    }
    QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(droneKeyOrAddr);
    if (drone.isNull()) {
        qWarning() << "[DroneController.cpp::sendTakeoffCmd] unknown drone:" << droneKeyOrAddr;
        return false;
    }
    // qDebug() << "[DroneController.cpp::sendTakeoffCmd] Found drone:" << drone->getName() << "with sysID:" << drone->getSysID() << "and compID:" << drone->getCompID();
    if (!mavTx_ || !mavTx_->linkOpen()) {
        qWarning() << "[DroneController.cpp::sendTakeoffCmd] MAVLink sender not ready; call openUDP() or openUART() first";
        return false;
    }
    
    const uint8_t targetSysID  = drone->getSysID();   
    const uint8_t targetCompID = drone->getCompID();

    // Send an acknowledged NAV_TAKEOFF command, e.g. to 5m AGL
    bool response = mavTx_->sendCommand(
        targetSysID,
        targetCompID,
        MAV_CMD_NAV_TAKEOFF,
        0.0f,  // pitch
        0.0f,  // empty
        0.0f,
        0.0f,  // yaw
        0.0f,  // lat (0 = use current for Copter)
        0.0f,  // lon (0 = use current for Copter)
        5.0f   // alt meters above home
    );

    qInfo() << "[DroneController.cpp::sendTakeoffCmd] Takeoff:"
    << drone->getName() << drone->getXbeeAddress()
    << "sent=" << response;
    return response;
}


bool DroneController::sendToCoord(const QString droneName, float lat, float lon) { 
    QSharedPointer<DroneClass> drone = getDroneByName(droneName);
    if (drone.isNull()) {
        qWarning() << "[DroneController.cpp::sendToCoord] unknown drone:" << drone;
        return false;
    }
    qDebug() << "[DroneController.cpp::sendToCoord] Found drone:" << drone->getName() << "with sysID:" << drone->getSysID() << "and compID:" << drone->getCompID();
    if (!mavTx_ || !mavTx_->linkOpen()) {
        qWarning() << "[DroneController.cpp::sendToCoord] MAVLink sender not ready; call openUDP() or openUART() first";
        return false;
    }
    
    const uint8_t targetSysID  = drone->getSysID();
    const uint8_t targetCompID = drone->getCompID();

    // In GUIDED mode, Copter expects a position-target message (SET_POSITION_TARGET_GLOBAL_INT)
    // rather than MAV_CMD_NAV_WAYPOINT via COMMAND_LONG.
    bool response = mavTx_->sendSetPositionTargetGlobalInt(
        targetSysID,
        targetCompID,
        static_cast<double>(lat),
        static_cast<double>(lon),
        5.0f   // altitude meters above home
    );

    qInfo() << "[DroneController.cpp::sendToCoord] SendToCoord:"
    << drone->getName() << drone->getXbeeAddress()
    << "sent=" << response;
    return response;
    return true;
}


bool DroneController::sendGuidedMode(const QString& droneKeyOrAddr, bool enableGuidedMode) {
    QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(droneKeyOrAddr);
    if (drone.isNull()) {
        qWarning() << "[DroneController.cpp::sendGuidedMode] unknown drone:" << droneKeyOrAddr;
        return false;
    }
    // qDebug() << "[DroneController.cpp::sendGuidedMode] Found drone:" << drone->getName() << "with sysID:" << drone->getSysID() << "and compID:" << drone->getCompID();

    if (!mavTx_ || !mavTx_->linkOpen()) {
        qWarning() << "[DroneController.cpp::sendGuidedMode] MAVLink sender not ready; call openUDP() or openUART() first";
        return false;
    }

    const uint8_t targetSysID  = drone->getSysID();   
    const uint8_t targetCompID = drone->getCompID();

    // use the MAVLinkSender class to package and send the signal
    bool response = mavTx_->sendCommand(
        targetSysID, 
        targetCompID,
        MAV_CMD_DO_SET_MODE, 
        MAV_MODE_FLAG_CUSTOM_MODE_ENABLED, // param1
        4.0f                                // param2 = GUIDED
    );

    // qInfo() << "[DroneController.cpp::sendTakeoffCmd] Guided mode enabled" << (takeoff ? "ON" : "OFF")
    //     << "->" << drone->getName() << drone->getXbeeAddress()
    //     << "sent=" << response;
    return response;
}


bool DroneController::requestTelem(QSharedPointer<DroneClass> drone) {
    if (drone.isNull()) {
        qWarning() << "[DroneController.cpp::requestTelem] drone is null";
        return false;
    }

    const QList<int> requestDataCommands = {
        MAVLINK_MSG_ID_GLOBAL_POSITION_INT,
        MAVLINK_MSG_ID_SYS_STATUS,
        MAVLINK_MSG_ID_ATTITUDE
    };

    if (!mavTx_ || !mavTx_->linkOpen()) {
        qWarning() << "[DroneController.cpp::requestTelem] MAVLink sender not ready; call openUdp() (or openUART()) first";
        return false;
    }

    uint8_t targetSysID = drone->getSysID();
    uint8_t targetCompID = drone->getCompID();
    qInfo() << "[DroneController.cpp::requestTelem] requesting streams for" << drone->getName()
    << "target sysid=" << targetSysID << "compid=" << targetCompID;
    
    bool response = true;
    for (int cmd : requestDataCommands) {
        if (!mavTx_->sendTelemRequest(targetSysID, targetCompID, cmd)) {
            response = false;
            qInfo() << "[DroneController.cpp::requestTelem] Something went wrong requesting data";
            break;
        }
    }
    qInfo() << "[DroneController.cpp::requestTelem] Data requested";
    return response;
}



/**
 * Helper: find (or lazily bind) a drone for a sysid.
 * Header must have: QHash<uint32_t, QSharedPointer<DroneClass>> dronesMap_;
 * 
 * TODO: Instead of adding a new drone from the list to the map, this function 
 * should return a null ptr so that the function that called it can CREATE a drone.
 * The newly created drone should be added to both the list and the map. 
 * Once that's been done, the drone list should not be needed here; only the map.
 */
QSharedPointer<DroneClass> droneForSysId_lazyBind(uint8_t sysID,
                                                  uint8_t compID,
                                                  QList<QSharedPointer<DroneClass>>& list,
                                                  QHash<uint32_t, QSharedPointer<DroneClass>>& map)
{
    uint32_t hashKey = sysID * 93 + compID * 89; // relying on only one ID will inevitably lead to overlap
    if (map.contains(hashKey)) return map.value(hashKey);

    if (!list.isEmpty()) {
        // TEMP heuristic: bind first drone we have (until you provide a real mapping)
        auto d = list.first();
        if (d->getSysID() == 1) 
        return d;
        map.insert(hashKey, d);
        d->setSysID(sysID);
        d->setCompID(compID);
        qDebug() << "[DroneController.cpp::droneForSysId_lazyBind] Bound sysID" << sysID <<  "and compID" << compID << "to drone" << d->getName();
        return d;
    }
    qDebug() << "[DroneController.cpp::droneForSysId_lazyBind] No drone found with sysID" << sysID <<  "and compID" << compID;
    
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
    uint8_t sysID = msg.sysid;
    uint8_t compID = msg.compid; 
    // qInfo() << "[DroneController.cpp::onMavlinkMessage] received message";
    // qInfo() << "[DroneController.cpp::onMavlinkMessage] sysID: " << sysID;
    // qInfo() << "[DroneController.cpp::onMavlinkMessage] compID: " << compID;
    // qInfo() << "[DroneController.cpp::onMavlinkMessage] Len: " << msg.len;
    // qInfo() << "[DroneController.cpp::onMavlinkMessage] ID:  " << msg.msgid;
    // qInfo() << "[DroneController.cpp::onMavlinkMessage] Orientation: ";
    // qInfo() << droneList[0]->getName() << ": " << droneList[0]->getOrientation();

    auto drone = droneForSysId_lazyBind(sysID, compID, droneList, dronesMap_);
    if (drone.isNull()) {
        qDebug() << "[DroneController.cpp::onMavlinkMessage] NULL Drone";
        return;
    }

    switch (msg.msgid) {
    case MAVLINK_MSG_ID_HEARTBEAT: {
        // qInfo() << "[DroneController.cpp::onMavlinkMessage] Got a heartbeat";
        mavlink_heartbeat_t hb;
        mavlink_msg_heartbeat_decode(&msg, &hb);
        updateDroneTelem(drone, "connected", true);
        updateDroneTelem(drone, "base_mode",   static_cast<int>(hb.base_mode)); // base_mode tells us if the drone is armed
        updateDroneTelem(drone, "custom_mode", static_cast<int>(hb.custom_mode));
        // Request telem streams once per drone when we see first heartbeat (not on every message)
        if (!drone->getRequestedTelem()) {
            bool ok = requestTelem(drone);
            if (ok) drone->setRequestedTelem(true);
            else qDebug() << "[DroneController.cpp::onMavlinkMessage] ERROR requesting telem";
        }

        bool armed = hb.base_mode & MAV_MODE_FLAG_SAFETY_ARMED;
        // qDebug() << "[DroneController.cpp::onMavlinkMessage] Armed =" << armed;
        uint32_t custom_mode = hb.custom_mode;

        switch(custom_mode) {
        case 0:
            // qInfo() << "DroneController.cpp::onMavlinkMessage] The current mode: stabalize (0)";
            break;
        case 3:
            // qInfo() << "DroneController.cpp::onMavlinkMessage] The current mode: auto (3)";
            break;
        case 4:
            // qInfo() << "DroneController.cpp::onMavlinkMessage] The current mode: guided (4)";
            break;
        case 5:
            // qInfo() << "DroneController.cpp::onMavlinkMessage] The current mode: loiter (5)";
            break;
        }

        break;
    }
    case MAVLINK_MSG_ID_SYS_STATUS: {
        // qDebug() << "[DroneController.cpp::onMavlinkMessage] Got system status";
        mavlink_sys_status_t s;
        mavlink_msg_sys_status_decode(&msg, &s);
        updateDroneTelem(drone, "battery_v",   s.voltage_battery/1000.0);
        updateDroneTelem(drone, "battery_pct", static_cast<int>(s.battery_remaining));
        break;
    }
    case MAVLINK_MSG_ID_GLOBAL_POSITION_INT: {
        mavlink_global_position_int_t p{};
        mavlink_msg_global_position_int_decode(&msg, &p);

        const double altMeters = static_cast<double>(p.relative_alt) / 1000.0;
        // qDebug() << "[DroneController.cpp::onMavlinkMessage] Altitude: " <<  altMeters << "m";
        updateDroneTelem(drone, "lat",   p.lat/1e7);
        updateDroneTelem(drone, "lon",   p.lon/1e7);
        updateDroneTelem(drone, "alt_m", altMeters);
        break;
    }
    case MAVLINK_MSG_ID_ATTITUDE: {
        // qDebug() << "[DroneController.cpp::onMavlinkMessage] Got attitude";
        mavlink_attitude_t a;
        mavlink_msg_attitude_decode(&msg, &a);
        updateDroneTelem(drone, "roll", a.roll);
        updateDroneTelem(drone, "pitch", a.pitch);
        updateDroneTelem(drone, "yaw",  a.yaw);
        break;
    }
    case MAVLINK_MSG_ID_COMMAND_LONG: {
        qDebug() << "[DroneController.cpp::onMavlinkMessage] Got COMMAND_LONG (76)";
        mavlink_command_long_t cmd;
        mavlink_msg_command_long_decode(&msg, &cmd);
        qInfo().nospace()
            << "[DroneController.cpp::onMavlinkMessage] COMMAND_LONG msgid=" << MAVLINK_MSG_ID_COMMAND_LONG
            << " command=" << cmd.command
            << " params=[" << cmd.param1 << ", " << cmd.param2 << ", "
            << cmd.param3 << ", " << cmd.param4 << ", " << cmd.param5 << ", "
            << cmd.param6 << ", " << cmd.param7 << "]"
            << " (target_sys=" << static_cast<int>(cmd.target_system)
            << ", target_comp=" << static_cast<int>(cmd.target_component)
            << ", confirmation=" << static_cast<int>(cmd.confirmation) << ")";
        break;
    }
    case MAVLINK_MSG_ID_COMMAND_ACK: {
        // qDebug() << "[DroneController.cpp::onMavlinkMessage] Got msg id ack";
        mavlink_command_ack_t ack;
        mavlink_msg_command_ack_decode(&msg, &ack);
        qInfo().nospace()
            << "[DroneController.cpp::onMavlinkMessage] COMMAND_ACK (for COMMAND_LONG, 76) cmd=" << ack.command
            << " result=" << static_cast<int>(ack.result)
            << " (sysID=" << static_cast<int>(sysID)
            << ", compID=" << static_cast<int>(compID) << ")";

        switch(ack.result) {
        case 0:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_ACCEPTED (0)"; // Command is valid (is supported and has valid parameters), and was executed.
            break;
        case 1:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_TEMPORARILY_REJECTED (1)"; // Command is valid, but cannot be executed at this time. This is used to indicate a problem that should be fixed just by waiting (e.g. a state machine is busy, can't arm because have not got GPS lock, etc.). Retrying later should work.
            break;
        case 2:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_DENIED (2)"; // Command is invalid; it is supported but one or more parameter values are invalid (i.e. parameter reserved, value allowed by spec but not supported by flight stack, and so on). Retrying the same command and parameters will not work.
            break;
        case 3:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_UNSUPPORTED (3)"; // Command is not supported (unknown).
            break;
        case 4:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_FAILED (4)"; // Command is valid, but execution has failed. This is used to indicate any non-temporary or unexpected problem, i.e. any problem that must be fixed before the command can succeed/be retried. For example, attempting to write a file when out of memory, attempting to arm when sensors are not calibrated, etc.
            break;
        case 5:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_IN_PROGRESS (5)"; // Command is valid and is being executed. This will be followed by further progress updates, i.e. the component may send further COMMAND_ACK messages with result MAV_RESULT_IN_PROGRESS (at a rate decided by the implementation), and must terminate by sending a COMMAND_ACK message with final result of the operation. The COMMAND_ACK.progress field can be used to indicate the progress of the operation.
            break;
        case 6:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_CANCELLED (6)"; // Command has been cancelled (as a result of receiving a COMMAND_CANCEL message).
            break;
        case 7:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_COMMAND_LONG_ONLY (7)"; // Command is only accepted when sent as a COMMAND_LONG.
            break;
        case 8:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_COMMAND_INT_ONLY (8)"; // Command is only accepted when sent as a COMMAND_INT.
            break;
        case 9:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_COMMAND_UNSUPPORTED_MAV_FRAME (9)"; // Command is invalid because a frame is required and the specified frame is not supported.
            break;
        case 10:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_NOT_IN_CONTROL (10)"; //  Command has been rejected because source system is not in control of the target system/component.
            break;
        case 11:
            qInfo() << "[DroneController.cpp::onMavlinkMessage] MAV_RESULT_ENUM_END (11)"; //
            break;
        }


        // updateDroneTelem(drone, "last_command", static_cast<int>(ack.command));
        // updateDroneTelem(drone, "last_result",  static_cast<int>(ack.result));
        break;
    }
    default:
        // qDebug() << "[DroneController.cpp::onMavlinkMessage] unexpected message type: " << msg.msgid;
        break;
    }
}


void DroneController::updateDroneTelem(QSharedPointer<DroneClass> drone, const QString& field, const QVariant& value)
{
    // qDebug() << "[DroneController.cpp::updateDroneTelem] Updating drone: " << drone->getName();
    if (field == "connected") {
        drone->setConnected(value.toBool());                 // if you have it
    } else if (field == "battery_v") {
        drone->setBatteryVoltage(value.toDouble());          // or setBatteryLevel if that's what you track
    } else if (field == "battery_pct") {
        drone->setBatteryLevel(value.toInt());               // 0–100
    } else if (field == "lat") {
        drone->setLatitude(value.toDouble());
    } else if (field == "lon") {
        drone->setLongitude(value.toDouble());
    } else if (field == "alt_m") {
        drone->setAltitude(value.toDouble());
    } else if (field == "roll") {
        drone->setRoll(value.toDouble());                    // if you surface attitude
    } else if (field == "pitch") {
        drone->setPitch(value.toDouble());
    } else if (field == "yaw") {
        drone->setYaw(value.toDouble());
    } else if (field == "base_mode" || field == "custom_mode") {
        // qDebug() << "[DroneController.cpp::updateDroneTelem] Base mode:" << value;
        drone->setModeField(field, value);                   // generic hook if you prefer
    }

    emit dronesChanged();
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
// Simple linear interpolation towards a target point
void moveDroneTowards(double &lat, double &lon, double targetLat, double targetLon, double step)
{
    double dLat = targetLat - lat;
    double dLon = targetLon - lon;

    // Calculate distance
    double distance = sqrt(dLat*dLat + dLon*dLon);
    if (distance < 1e-6) return;  // Already there

    // Move by step, but don't overshoot
    double ratio = step / distance;
    if (ratio > 1.0) ratio = 1.0;

    lat += dLat * ratio;
    lon += dLon * ratio;
}

// void DroneController::simulateDroneMovement()
// {
//     double step = 0.00005; // small step toward waypoint

//     for (auto &drone : droneList) {
//         if (!drone) continue;

//         double lat = drone->getLatitude();
//         double lon = drone->getLongitude();

//         // Get the next waypoint for this drone
//         QList<QVariantMap> wps;
//         if (droneWaypoints.contains(drone->getName()) && !droneWaypoints[drone->getName()].isEmpty())
//         {
//             wps = droneWaypoints[drone->getName()];
//         }
//         if (wps.size() < 2)
//             continue; // nothing to move toward
//         double targetLat = wps[1]["lat"].toDouble();
//         double targetLon = wps[1]["lon"].toDouble();

//         // Move towards it
//         moveDroneTowards(lat, lon, targetLat, targetLon, step);

//         // Update drone position
//         drone->setLatitude(lat);
//         drone->setLongitude(lon);
//         emit droneStateChanged(drone.data());
//     }
// }
