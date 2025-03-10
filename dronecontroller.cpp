#include "dronecontroller.h"
#include "droneclass.h"
#include <QDebug>

#include <QSharedMemory>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
// #include "drone.h"

QList<QSharedPointer<DroneClass>> DroneController::droneList;  // Define the static variable

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db) {
    // function loads all drones from the database on startup
    QList<QVariantMap> droneRecords = dbManager.fetchAllDrones();
    for (const QVariantMap &record : droneRecords) {
        QString name = record["drone_name"].toString();
        QString role = record["drone_role"].toString();
        QString xbeeID = record["xbee_id"].toString();
        QString xbeeAddress = record["xbee_address"].toString();
        // Should? work with other fields like xbee_id or drone_id if needed
        // existing table can have added columns for the lati and longi stuff and input here
        // TODO: Change this, add xbee id?
        droneList.push_back(QSharedPointer<DroneClass>::create(name, role, xbeeID, xbeeAddress));
    }
    qDebug() << "Loaded" << droneList.size() << "drones from the database.";
}

// method so QML can retrieve the drone list.
QVariantList DroneController::getDroneList() const {
    QVariantList list;
    for (const QSharedPointer<DroneClass> &drone : droneList) {
        QVariantMap droneMap;
        // these method calls have to match our DroneClass interface
        droneMap["name"] = drone->getName();
        droneMap["role"] = drone->getRole(); // <-- we been using "drone type" in UI and everything but its called drone role in droneclass.h lul
        droneMap["xbeeId"] = drone->getXbeeID();
        droneMap["xbeeAddress"] = drone->getXbeeAddress();
        // Adds placeholder values for status and battery and leave other fields blank
        droneMap["status"] = "Not Connected"; // or "Pending" or another placeholder
        droneMap["battery"] = "NA"; // static placeholder battery percent

        // uncomment to leave blank (not needed)
        /*droneMap["lattitude"] = ""; // leave as blank or add a default value
        droneMap["longitude"] = "";
        droneMap["altitude"] = "";
        droneMap["airspeed"] = "";*/

        list.append(droneMap);
    }
    return list;
    // Set up timer connections but don't start yet
    connect(&xbeeDataTimer, &QTimer::timeout, this, &DroneController::processXbeeData);
    connect(&reconnectTimer, &QTimer::timeout, this, &DroneController::tryConnectToSharedMemory);
}

DroneController::~DroneController() {
    // Cleans up
    if(xbeeSharedMemory.isAttached()) {
        xbeeSharedMemory.detach();
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
void DroneController::saveDrone(const QString &input_name, const QString &input_role, const QString &input_xbeeID, const QString &input_xbeeAddress) {
    if (input_name.isEmpty()) {
        qWarning() << "Missing required name field!";
        return;
    }

    // Add Drone to Database
    if (dbManager.createDrone(input_name, input_role, input_xbeeID, input_xbeeAddress)) {
        qDebug() << "Drone created on DB successfully!";
    } else {
        qWarning() << "Failed to save drone.";
    }

    // Now we are going to create a shared pointer across qt for the drone class object with inputs of name, type, and xbee address
    droneList.push_back(QSharedPointer<DroneClass>::create(input_name, input_role, input_xbeeID, input_xbeeAddress));

    emit droneAdded();
    // This is an example of how we would access the last drone object of the list as a pointer to memory
    // QSharedPointer<DroneClass> tempPtr = droneList.last();

    // this is an example of using the list plus the object above use the methods and get information
    // qDebug() << "HIPEFULLY SOMETHIGBN :D" << droneList.data();
    // qDebug() << "HIPEFULLY A NAME :D" << tempPtr->getName();
    // QString tempName = "CHANGED NAME PLS";
    // tempPtr->setName(tempName);
    // qDebug() << "HIPEFULLY A CHANGED NAME :D" << tempPtr->getName();

    /*
    // Prepare the database
    droneClass.setName(input_name);
    droneClass.setRole(input_type);
    */
}

void DroneController::updateDrone(const QString &oldXbeeId, const QString &name, const QString &role, const QString &xbeeId, const QString &xbeeAddress) {
    // Find the drone in our list by its xbeeID (im assuming is unique)
    for (int i = 0; i < droneList.size(); i++) {
        if (droneList[i]->getXbeeID() == oldXbeeId) {
            droneList[i]->setName(name);
            droneList[i]->setRole(role);
            droneList[i]->setXbeeID(xbeeId);
            droneList[i]->setXbeeAddress(xbeeAddress);
            qDebug() << "Drone updated in memory:" << name;
            emit droneUpdated();
            break;
        }
    }
}

void DroneController::deleteDrone(const QString &input_xbeeId) {
    if (input_xbeeId.isEmpty()) {
        qWarning() << "Drone Controller: xbeeId not passed by UI.";
    }
    if (dbManager.deleteDrone(input_xbeeId)) {
        for (int i = 0; i < droneList.size(); i++) {
            if (droneList[i]->getXbeeID() == input_xbeeId) {
                droneList.removeAt(i);
                break;
            }
        }
    }
    qDebug() << "Drone deleted successfully!";
    emit droneDeleted();
}

// if we're being honest the slots being called by any function is in my head and i cant figure out if i need something rn
void DroneController::deleteALlDrones_UI() {
    if (dbManager.deleteAllDrones()) {
        droneList.clear(); // also delete drones in C++ memory

        qDebug() << "droneController: All drones deleted successfully!";

        //emit droneDeleted();
    } else {
        qWarning() << "Failed to delete all drones.";
    }
}
QSharedPointer<DroneClass> DroneController::getDroneByName(const QString &name) {
    for (const auto &drone : droneList) {
        if (drone->getName() == name) {
            return drone;
        }
    }
    return QSharedPointer<DroneClass>();  // Return null pointer if not found

}

bool DroneController::initXbeeSharedMemory() {
#ifdef Q_OS_WIN
    // On Windows, use a specific named shared memory
    xbeeSharedMemory.setKey("XbeeSharedMemory");
#else
    // On Unix/macOS, use the key as before
    xbeeSharedMemory.setKey("XbeeSharedMemory");
#endif

    // Try to attach to existing shared memory created by Python
    if (!xbeeSharedMemory.attach()) {
        qWarning() << "Failed to attach to shared memory:" << xbeeSharedMemory.errorString();
        return false;
    }
    return true;
}

void DroneController::tryConnectToSharedMemory() {
    if (initXbeeSharedMemory()) {
        qDebug() << "Successfully connected to XBee shared memory";
        reconnectTimer.stop();  // Stop trying to reconnect

        // Start timer to check for XBee data
        xbeeDataTimer.start(50);  // Check every 50ms

        emit xbeeConnectionChanged(true);
    }
}

QString DroneController::getLatestXbeeData() {
    QString result;
    if (xbeeSharedMemory.lock()) {
        result = QString::fromUtf8(static_cast<char*>(xbeeSharedMemory.data()));
        xbeeSharedMemory.unlock();
    } else {
        qWarning() << "Failed to lock shared memory for reading";
    }
    return result;
}

void DroneController::processXbeeData() {
    QString data = getLatestXbeeData();
    if (data.isEmpty()) return;

    // Try to parse as JSON
    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    if (doc.isNull()) return;

    QJsonObject obj = doc.object();

    // Handle heartbeat messages
    if (obj["type"] == "heartbeat") {
        qDebug() << "Received heartbeat from Python script";
        emit xbeeConnectionChanged(true);
        return;
    }

    // Handle drone data messages
    if (obj["type"] == "xbee_data") {
        QString droneName = obj["drone"].toString();
        QString address = obj["address"].toString();
        QString message = obj["message"].toString();

        // First try to find drone by XBee address
        QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(address);

        if (!drone.isNull()) {
            // Update drone state based on XBee data
            drone->processXbeeMessage(message);

            // Emit signal that drone state has changed
            emit droneStateChanged(drone->getName());
        } else {
            qDebug() << "Received data for unknown drone at address:" << address;
        }
    }
}

void DroneController::startXbeeMonitoring() {
    // Try to connect immediately
    if (initXbeeSharedMemory()) {
        qDebug() << "Successfully connected to XBee shared memory";
        xbeeDataTimer.start(50);  // Check every 50ms
        emit xbeeConnectionChanged(true);
    } else {
        qDebug() << "Waiting for XBee shared memory to be created...";
        emit xbeeConnectionChanged(false);

        // Start reconnect timer
        reconnectTimer.start(1000);  // Try every second
    }
}

QSharedPointer<DroneClass> DroneController::getDroneByXbeeAddress(const QString &address) {
    for (const auto &drone : droneList) {
        if (drone->getXbeeAddress() == address) {
            return drone;
        }
    }
    return QSharedPointer<DroneClass>();  // Return null pointer if not found
}

// DroneClass DroneController::getDroneByName(const QString &input_name){

// }

