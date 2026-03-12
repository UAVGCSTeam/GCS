#include "DroneController.h"


QList<QSharedPointer<DroneClass>> DroneController::droneList; // Define the static variable
QList<QSharedPointer<UnknownDroneClass>> DroneController::unknownDroneList; // Define the static variable

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db)
{
    int index = 0; 

    // function loads all drones from the database on startup
    qRegisterMetaType<mavlink_message_t>("mavlink_message_t");

    // UNCOMMENT THIS IF YOU WANT TO USE THE HARDCODED DRONES 
    // FROM THE DATABASE AGAIN
    // QList<QVariantMap> droneRecords = dbManager.fetchAllDrones();

    // for (const QVariantMap &record : droneRecords)
    // {
    //     QString name = record["drone_name"].toString();
    //     QString role = record["drone_role"].toString();
    //     QString xbeeID = record["xbee_id"].toString();
    //     int sysID = -1;
    //     int compID = -1;
    //     QString xbeeAddress = record["xbee_address"].toString();
        
    //     // Random battery level (35-92%) for realistic demo variation
    //     int batteryLevel = QRandomGenerator::global()->bounded(35, 93);
    //     droneList.append(QSharedPointer<DroneClass>::create(name, role, xbeeID, xbeeAddress, batteryLevel, 34.059174611493965, -117.82051240067321, 10, nullptr));
        
    //     index++;
    // }
    // // simulated unknown drone list
    // if (unknownDroneList.isEmpty()) {
    // unknownDroneList.append(QSharedPointer<UnknownDroneClass>::create(
    //     "u1", "fc1", "uavtype1", -1, -1, false, nullptr));
    // unknownDroneList.append(QSharedPointer<UnknownDroneClass>::create(
    //     "u2", "fc2", "uavtype2", -1, -1, false, nullptr));
    // unknownDroneList.append(QSharedPointer<UnknownDroneClass>::create(
    //     "u3", "fc3", "uavtype3", -1, -1, false, nullptr));
    // unknownDroneList.append(QSharedPointer<UnknownDroneClass>::create(
    //     "u8", "fc8", "uavtype8", -1, -1, false, nullptr));
    // unknownDroneList.append(QSharedPointer<UnknownDroneClass>::create(
    //     "u9", "fc9", "uavtype9", -1, -1, false, nullptr));
    // }

    rebuildUnknownVariant();
    emit unknownDronesChanged();

    //temporary sim heartbeat
    connect(&heartBeatSimTimer, &QTimer::timeout, this, &DroneController::useSimulatedHeartbeat);
    heartBeatSimTimer.start(250); //four per second

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

        const double altitudeMeters = drone->getAltitude();
        QString status;
        if (altitudeMeters > 0.2) {
            status = QStringLiteral("Flying");
        } else if (drone->getBatteryLevel() > 0) {
            status = QStringLiteral("Connected");
        } else {
            status = QStringLiteral("Not Connected");
        }

        // Adds placeholder values for status and battery and leave other fields blank
        droneMap["status"] = status;
        droneMap["battery"] = drone->getBatteryLevel() > 0 ? QString::number(drone->getBatteryLevel()) + "%" : "Battery not received";

        droneMap["latitude"] = drone->getLatitude();
        droneMap["longitude"] = drone->getLongitude();
        droneMap["altitude"] = altitudeMeters;
        droneMap["airspeed"] = drone->getAirspeed();

        list.append(droneMap);
        // index++;
    }
    return list;
}

DroneController::~DroneController()
{
}

//temporary sim heartbeat
void DroneController::useSimulatedHeartbeat()
{
    if(checkHeartBeat)
        updateDroneTelem(droneList[0], "connected", true);
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

// drone list updaters
void DroneController::loadUnknownDrones()
{
    rebuildUnknownVariant();
    emit unknownDronesChanged();
}
void DroneController::setUnknownDroneIgnored(const QString &uid, bool ignored)
{
    for (const auto &unknownDrone : unknownDroneList) {
        if (unknownDrone && unknownDrone->getUid() == uid) {
            unknownDrone->setIgnored(ignored);
            rebuildUnknownVariant();
            emit unknownDronesChanged();
            return;
        }
    }
}
void DroneController::acceptUnknownDrone(const QString &uid)
{
    // finds drone by uid, if not found, then sends warning and doesn't log to db
    QSharedPointer<UnknownDroneClass> found;
    for (const auto &unknownDrone : unknownDroneList) {
        if (unknownDrone && unknownDrone->getUid() == uid) {
            found = unknownDrone;
            break;
        }
    }

    if (!found) {
        qWarning() << "[DroneController::acceptUnknownDrone]: unknown drone not found for uid: " << uid;
        return;
    }

    // these are just to easily identify the newly added drones since we don't have other identifers
    const QString role = found->getUavType().isEmpty() ? QStringLiteral("Unknown") : found->getUavType();
    const QString name = role + QStringLiteral(" ") + uid;
    // uid as placeholder since we won't know xbeeAddress yet
    const QString xbeeID = uid;
    const QString xbeeAddress = uid;

    // battery, latitutde, longitude, altitude all unknown (-1)
    createDrone(name,role,xbeeID,xbeeAddress,-1,-1,-1,-1,nullptr);
    removeUnknownDrones(uid);

    rebuildVariant();
}
void DroneController::removeUnknownDrones(const QString &uid)
{
    // loops through the list to find the specific drone index with the
    // matching uid the user wants to remove
    for (int i = 0; i < unknownDroneList.size(); ++i) {
        if (unknownDroneList[i] && unknownDroneList[i]->getUid() == uid) {
            unknownDroneList.removeAt(i);
            rebuildUnknownVariant();
            emit unknownDronesChanged();
            return;
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
    qDebug() << "[DroneController.cpp::constructor #1] Creating drone";
    auto drone = QSharedPointer<DroneClass>::create(
        input_name,
        input_role,
        input_xbeeID,
        input_xbeeAddress,
        0,  // sysID
        0,  // compID
        -1, // udpPort (not from UDP)
        nullptr
    );
    drone->setBatteryLevel(input_batteryLevel);
    drone->setLatitude(input_latitude);
    drone->setLongitude(input_longitude);
    drone->setAltitude(input_altitude);
    saveDroneToDB(drone); // call the internal method
}

void DroneController::createAndAddDroneToUI(const QString &input_name,
                                  const uint8_t &input_sysID,
                                  const uint8_t &input_compID,
                                  int senderUDPPort,
                                  const QObject *parent)
{
    qDebug() << "[DroneController.cpp::createAndAddDroneToUI] Creating drone";
    auto drone = QSharedPointer<DroneClass>::create(
        input_name,
        "no role assigned",
        "-1",
        "-1",
        input_sysID,
        input_compID,
        senderUDPPort,
        nullptr
    );
    saveDroneToDB(drone);
    droneList.append(drone);
    rebuildVariant();
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
        qDebug() << "[DroneController.cpp::saveDroneToDB] Drone created in DB successfully with ID:" << newDroneID;

        // Add to the in-memory list
        droneList.push_back(drone);

        emit droneAdded(drone); // right now this is not being used anywhere
        // Adding update to the new QML list
        rebuildVariant();
        qDebug() << "[DroneController.cpp::saveDroneToDB] dronesChanged signal emitted";
        qDebug() << "[DroneController.cpp::saveDroneToDB] Drone saved:" << drone->getName();
    }
    else
    {
        qWarning() << "[DroneController.cpp::saveDroneToDB] Failed to save drone to DB:" << drone->getName();
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
        qWarning() << "[DroneController::deleteDrone] Drone Controller: xbeeID not passed by UI.";
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
            qDebug() << "[DroneController::deleteDrone] Removed drone from memory with ID/address:" << input_xbeeID;
            break;
        }
    }

    // Now delete from database, even if not found in memory
    if (dbManager.deleteDrone(input_xbeeID))
    {
        qDebug() << "[DroneController::deleteDrone] Drone deleted successfully from database:" << input_xbeeID;
        // Adding update to the new QML list
        rebuildVariant();
    }
    else
    {
        qWarning() << "[DroneController::deleteDrone] Failed to delete drone from database:" << input_xbeeID;
        // If we removed from memory but failed to delete from DB, sync
        if (found)
        {
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
    }
    else
    {
        qWarning() << "[DroneController::deleteDrone] Failed to delete all drones.";
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
    qDebug() << "[DroneController::getDroneByXbeeAddress] Looking for drone with address:" << address;

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
        qWarning() << "[DroneController::getDrones] Database is not open!";
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
        qDebug() << "[DroneController.cpp::getDrones] Found" << result.size() << "drones in database";

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
        qWarning() << "[DroneController::getDrones] Failed to fetch drones from database:" << query.lastError().text();
    }

    return result;
}



DroneClass *DroneController::getDrone(int index) const
{
    if (index < 0 || index >= droneList.size())
    {
        qWarning() << "[DroneController::getDrone]: index out of range" << index;
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
        udp_ = std::make_unique<UDPLink>(this);
        // Uncomment the following connection to test basic UDP connection
        // connect(udp_.get(), &UDPLink::bytesReceived,
        //         this,        &DroneController::onUdpBytesReceived);
        // This connections listens for udp packets from previously
        // unknown udp ports
        connect(udp_.get(), &UDPLink::newUDPPeer,
                this,        &DroneController::onNewUDPPeer);
    }
    if (!mavTx_) mavTx_ = std::make_unique<MAVLinkSender>(udp_.get(), this);
    
    if (!mavRx_) {
        mavRx_ = std::make_unique<MAVLinkReceiver>(this);
        connect(udp_.get(), &UDPLink::bytesReceived,
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
    qDebug() << "[DroneController.cpp::onUdpBytesReceived] UDP received" << size << "bytes"
             << (previewLen < size ? QString("(first %1):").arg(previewLen) : ":")
             << hex;
}

void DroneController::onNewUDPPeer(const QByteArray& bytes, const int& senderUDPPort) 
{
    if (!mavRx_) {
        qWarning() << "[DroneController::onNewUDPPeer] mavRx_ is null; cannot parse MAVLink";
        return;
    }
    RxMavlinkMsg m = mavRx_->getMAVLinkFromBytesWithFreshState(bytes);
    if (m.msgid == 0 && m.payload.isEmpty()) {
        // No complete MAVLink message in this packet (e.g. partial or non-MAVLink data)
        const int preview = qMin(bytes.size(), 20);
        qDebug() << "[DroneController::onNewUDPPeer] No MAVLink message in packet from port" << senderUDPPort
        << "size=" << bytes.size() << "first bytes (hex):" << bytes.left(preview).toHex(' ');
        return;
    }
    QString name = "My Drone " + QString::number(senderUDPPort);
    createAndAddDroneToUI(name, m.sysid, m.compid, senderUDPPort, nullptr);
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

    if (!mavTx_ || !mavTx_->isLinkOpen()) {
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
        arm ? 1.0f : 0.0f,
        0.0f, 0.0f, 0.0f, 0.0f, 0.0f,
        drone->getUdpPort());

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
    if (!mavTx_ || !mavTx_->isLinkOpen()) {
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
        5.0f,  // alt meters above home
        drone->getUdpPort());

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
    if (!mavTx_ || !mavTx_->isLinkOpen()) {
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
        5.0f,   // altitude meters above home
        drone->getUdpPort());

    qInfo() << "[DroneController.cpp::sendToCoord] SendToCoord:"
    << drone->getName() << drone->getXbeeAddress()
    << "sent=" << response;
    return response;
}


bool DroneController::sendToCoordByUavID(const QString uavID, float lat, float lon) {
    QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(uavID);
    if (drone.isNull()) {
        qWarning() << "[DroneController.cpp::sendToCoordByUavID] unknown drone with xbeeAddress:" << uavID;
        return false;
    }
    if (!mavTx_ || !mavTx_->isLinkOpen()) {
        qWarning() << "[DroneController.cpp::sendToCoordByUavID] MAVLink sender not ready";
        return false;
    }

    bool response = mavTx_->sendSetPositionTargetGlobalInt(
        drone->getSysID(),
        drone->getCompID(),
        static_cast<double>(lat),
        static_cast<double>(lon),
        5.0f,
        drone->getUdpPort()
    );

    qInfo() << "[DroneController.cpp::sendToCoordByUavID] SendToCoord:"
            << drone->getName() << uavID << "sent=" << response;
    return response;
}

bool DroneController::sendGuidedMode(const QString& droneKeyOrAddr, bool enableGuidedMode) {
    QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(droneKeyOrAddr);
    if (drone.isNull()) {
        qWarning() << "[DroneController.cpp::sendGuidedMode] unknown drone:" << droneKeyOrAddr;
        return false;
    }
    // qDebug() << "[DroneController.cpp::sendGuidedMode] Found drone:" << drone->getName() << "with sysID:" << drone->getSysID() << "and compID:" << drone->getCompID();

    if (!mavTx_ || !mavTx_->isLinkOpen()) {
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
        4.0f,                               // param2 = GUIDED
        0.0f, 0.0f, 0.0f, 0.0f, 0.0f,      // p3..p7
        drone->getUdpPort());

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

    if (!mavTx_ || !mavTx_->isLinkOpen()) {
        qWarning() << "[DroneController.cpp::requestTelem] MAVLink sender not ready; call openUdp() (or openUART()) first";
        return false;
    }

    uint8_t targetSysID = drone->getSysID();
    uint8_t targetCompID = drone->getCompID();
    qInfo() << "[DroneController.cpp::requestTelem] requesting streams for" << drone->getName()
    << "target sysid=" << targetSysID << "compid=" << targetCompID;
    
    bool response = true;
    for (int cmd : requestDataCommands) {
        if (!mavTx_->sendTelemRequest(targetSysID, targetCompID, cmd, drone->getUdpPort())) {
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
 * 
 * @warning: inefficient do to looping 
 */
QSharedPointer<DroneClass> droneForSysIdList(uint8_t sysID, QList<QSharedPointer<DroneClass>>& list)
{
    for (QSharedPointer<DroneClass> drone : list) {
        if (drone->getSysID() == sysID) {
            return drone;
        }
    }
    qDebug() << "[DroneController.cpp::droneForSysIdList] No drone found with sysID" << sysID;
    
    return {};
}

/**
 * Helper: find (or lazily bind) a drone for a sysid.
 * Header must have: QHash<uint32_t, QSharedPointer<DroneClass>> dronesMap_;
 * 
 * // TODO: This function needs to be renamed 😔
 * // TODO: Instead of adding a new drone from the list to the map, this function 
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

    auto drone = droneForSysIdList(sysID, droneList);
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
            // qInfo() << "[DroneController.cpp::onMavlinkMessage] The current mode: stabalize (0)";
            break;
        case 3:
            // qInfo() << "[DroneController.cpp::onMavlinkMessage] The current mode: auto (3)";
            break;
        case 4:
            // qInfo() << "[DroneController.cpp::onMavlinkMessage] The current mode: guided (4)";
            break;
        case 5:
            // qInfo() << "[DroneController.cpp::onMavlinkMessage] The current mode: loiter (5)";
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
        emit droneStateChanged(drone.data());
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
        mavlink_command_ack_t ack;
        mavlink_msg_command_ack_decode(&msg, &ack);
        // qInfo().nospace()
        //     << "[DroneController.cpp::onMavlinkMessage] COMMAND_ACK cmd=" << ack.command
        //     << " result=" << static_cast<int>(ack.result)
        //     << " (sysID=" << static_cast<int>(sysID)
        //     << ", compID=" << static_cast<int>(compID) << ")";

        QString cmdName;
        switch (ack.command) {
            case MAV_CMD_COMPONENT_ARM_DISARM: cmdName = "Arm/Disarm"; break;
            case MAV_CMD_NAV_TAKEOFF:          cmdName = "Takeoff";    break;
            case MAV_CMD_DO_SET_MODE:          cmdName = "Set Mode";   break;
            default: cmdName = QString("Command %1").arg(ack.command); break;
        }

        QString resultMsg;
        bool success = false;
        switch (ack.result) {
            case 0: resultMsg = cmdName + " accepted";             success = true;  break;
            case 1: resultMsg = cmdName + " temporarily rejected"; success = false; break;
            case 2: resultMsg = cmdName + " denied";               success = false; break;
            case 3: resultMsg = cmdName + " unsupported";          success = false; break;
            case 4: resultMsg = cmdName + " failed";               success = false; break;
            case 5: resultMsg = cmdName + " in progress";          success = true;  break;
            case 6: resultMsg = cmdName + " cancelled";            success = false; break;
            default: resultMsg = cmdName + " result: " + QString::number(ack.result); break;
        }

        qInfo() << "[DroneController.cpp::onMavlinkMessage]" << resultMsg;
        emit commandAcknowledged(resultMsg, success);  
        break;
    }
    default:
        // qDebug() << "[DroneController.cpp::onMavlinkMessage] unexpected message type: " << msg.msgid;
        break;
    }
}


void DroneController::updateDroneTelem(QSharedPointer<DroneClass> drone, const QString& field, const QVariant& value)
{
    if (drone.isNull()) return;

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
    emit dronesChanged();
}

// called when the unknownDroneList is updated
void DroneController::rebuildUnknownVariant()
{
    m_unknownDronesVariant.clear();
    m_unknownDronesVariant.reserve(unknownDroneList.size());
    for (const auto &sp : unknownDroneList)
    {
        m_unknownDronesVariant << QVariant::fromValue(static_cast<QObject *>(sp.data()));
    }
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
