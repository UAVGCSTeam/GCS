#include "dronecontroller.h"
#include "droneclass.h"
#include <QDebug>

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
#define DEFAULT_DATA_FILE_PATH "C:/tmp/xbee_data.json"  // Windows path
#else
#define DEFAULT_DATA_FILE_PATH "/tmp/xbee_data.json"  // Unix/Mac path
#endif

QList<QSharedPointer<DroneClass>> DroneController::droneList;  // Define the static variable

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db) {
<<<<<<< HEAD
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
=======
>>>>>>> 24d6d9c (PLEASE GOD HELP ME)

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
    connect(&reconnectTimer, &QTimer::timeout, this, &DroneController::tryConnectToDataFile);
}

DroneController::~DroneController() {
    // Cleanup code if needed
    if (xbeeDataTimer.isActive()) {
        xbeeDataTimer.stop();
    }
    if (reconnectTimer.isActive()) {
        reconnectTimer.stop();
    }
}

// Get the correct file path to check
QString DroneController::getDataFilePath() {
    // Try standard temp path first (more reliable across systems)
    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString tempFilePath = tempPath + "/xbee_tmp/xbee_data.json";

    QFile tempFile(tempFilePath);
    if (tempFile.exists()) {
        qDebug() << "Using temp path:" << tempFilePath;
        return tempFilePath;
    }

    // Fall back to default paths
    QFile file(DEFAULT_DATA_FILE_PATH);
    if (file.exists()) {
        return DEFAULT_DATA_FILE_PATH;
    }

#ifdef _WIN32
    // Additional Windows fallback
    QString fallbackPath = tempPath + "/xbee_data.json";
    QFile fallbackFile(fallbackPath);
    if (fallbackFile.exists()) {
        qDebug() << "Using fallback path:" << fallbackPath;
        return fallbackPath;
    }
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
<<<<<<< HEAD
void DroneController::saveDrone(const QString &input_name, const QString &input_role, const QString &input_xbeeID, const QString &input_xbeeAddress) {
=======
// Save a drone to the database and add it to the in-memory list
void DroneController::saveDrone(const QString &input_name, const QString &input_type, const QString &input_xbeeID, const QString &input_xbeeAddress) {
>>>>>>> 24d6d9c (PLEASE GOD HELP ME)
    if (input_name.isEmpty()) {
        qWarning() << "Missing required name field!";
        return;
    }

    // Add Drone to Database
<<<<<<< HEAD
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
=======
    int newDroneId = -1;
    if (dbManager.createDrone(input_name, input_type, input_xbeeID, input_xbeeAddress, &newDroneId)) {
        qDebug() << "Drone created in DB successfully with ID:" << newDroneId;

        // Add to the in-memory list
        droneList.push_back(QSharedPointer<DroneClass>::create(input_name, input_type, input_xbeeAddress));

        qDebug() << "About to emit dronesChanged signal after adding drone";
        emit dronesChanged();
        qDebug() << "dronesChanged signal emitted";
    } else {
        qWarning() << "Failed to save drone.";
    }
}

bool DroneController::updateDrone(const QString& oldXbeeId, const QString& name, const QString& type, const QString& xbeeId, const QString& xbeeAddress) {
    // Find the drone in droneList by oldXbeeId
    for (int i = 0; i < droneList.size(); ++i) {
        if (droneList[i]->getXbeeAddress() == oldXbeeId) {
            // Update the drone in memory
            droneList[i]->setName(name);
            droneList[i]->setRole(type);  // Note: DroneClass uses setRole not setType
            droneList[i]->setXbeeAddress(xbeeAddress);

            // Update in database
            // This is a simplified version - you might need to adapt based on your actual DB schema
            QSqlQuery query;
            query.prepare("SELECT drone_id FROM drones WHERE xbee_address = :xbeeAddress");
            query.bindValue(":xbeeAddress", oldXbeeId);

            if (query.exec() && query.next()) {
                int droneId = query.value(0).toInt();
                bool success = dbManager.editDrone(droneId, name, type, xbeeId, xbeeAddress);
                if (success) {
                    emit dronesChanged();
                    return true;
                }
            }
            return false;
        }
    }
    return false;
}

bool DroneController::isSimulationMode() const {
    QString configPath = getConfigFilePath();
    QFile configFile(configPath);

    if (configFile.exists() && configFile.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(configFile.readAll());
        QJsonObject obj = doc.object();
        bool simMode = obj["simulation_mode"].toBool();
        configFile.close();
        qDebug() << "Reading simulation mode from config:" << simMode;
        return simMode;
    }

    qDebug() << "Could not find config file at:" << configPath;
    qDebug() << "Defaulting to simulation mode";

    // Default to simulation mode if can't read config
    return true;
}

QString DroneController::getConfigFilePath() const {
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
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    configPath += "/xbee_config.json";
    qDebug() << "Config file path:" << configPath;
    return configPath;
}

bool DroneController::deleteDrone(const QString& xbeeId) {
    // Find the drone in droneList by xbeeId
    for (int i = 0; i < droneList.size(); ++i) {
        if (droneList[i]->getXbeeAddress() == xbeeId) {
            // Find the drone ID in the database
            QSqlQuery query;
            query.prepare("SELECT drone_id FROM drones WHERE xbee_address = :xbeeAddress");
            query.bindValue(":xbeeAddress", xbeeId);

            if (query.exec() && query.next()) {
                int droneId = query.value(0).toInt();

                // Remove from database
                if (dbManager.deleteDrone(droneId)) {
                    // Remove from list
                    droneList.removeAt(i);
                    emit dronesChanged();
                    return true;
                }
            }
            return false;
        }
    }
    return false;
}

// If want to query by name
>>>>>>> 24d6d9c (PLEASE GOD HELP ME)
QSharedPointer<DroneClass> DroneController::getDroneByName(const QString &name) {
    for (const auto &drone : droneList) {
        if (drone->getName() == name) {
            return drone;
        }
    }
    return QSharedPointer<DroneClass>();  // Return null pointer if not found

}

// If want to query by address
QSharedPointer<DroneClass> DroneController::getDroneByXbeeAddress(const QString &address) {
    for (const auto &drone : droneList) {
        if (drone->getXbeeAddress() == address) {
            return drone;
        }
    }
    return QSharedPointer<DroneClass>();  // Return null pointer if not found
}

// Check if the data file exists
bool DroneController::checkDataFileExists() {
    QString filePath = getDataFilePath();
    QFile file(filePath);
    if (file.exists()) {
        qDebug() << "Found XBee data file at:" << filePath;
        return true;
    } else {
        qDebug() << "XBee data file not found at:" << filePath;
        return false;
    }
}

// Try to connect to the data file
void DroneController::tryConnectToDataFile() {
    if (checkDataFileExists()) {
        qDebug() << "Successfully found XBee data file";
        reconnectTimer.stop();  // Stop trying to reconnect

        // Start timer to check for XBee data
        xbeeDataTimer.start(50);  // Check every 50ms
        emit xbeeConnectionChanged(true);
    }
}

QString DroneController::getLatestXbeeData() {
    QString result;
    QString filePath = getDataFilePath();
    QFile file(filePath);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        result = QString::fromUtf8(file.readAll());
        file.close();
    } else {
        qWarning() << "Failed to open XBee data file:" << file.errorString();
    }

    return result;
}

QVariantList DroneController::getDrones() const { // DOUBLE CHECK THIS BRANDON
    QVariantList result;

    // Ensure the database is open
    if (!dbManager.isOpen()) {
        qWarning() << "Database is not open!";
        return result;
    }

    // Execute a simple SELECT query
    QSqlQuery query("SELECT drone_id, drone_name, drone_type, xbee_id, xbee_address FROM drones");

    if (query.exec()) {
        while (query.next()) {
            QVariantMap drone;
            drone["id"] = query.value(0).toInt();
            drone["name"] = query.value(1).toString();
            drone["type"] = query.value(2).toString();
            drone["xbeeId"] = query.value(3).toString();
            drone["xbeeAddress"] = query.value(4).toString();
            result.append(drone);
        }
        qDebug() << "Found" << result.size() << "drones in database";
        // Initialize droneList with database contents
        droneList.clear();
        for (const QVariant& droneVar : result) {
            QVariantMap droneMap = droneVar.toMap();
            droneList.push_back(QSharedPointer<DroneClass>::create(
                droneMap["name"].toString(),
                droneMap["type"].toString(),
                droneMap["xbeeAddress"].toString()
                ));
        }
    } else {
        qWarning() << "Failed to fetch drones from database:" << query.lastError().text();
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

// Start monitoring for XBee data
void DroneController::startXbeeMonitoring() {
    // Try to connect immediately
    if (checkDataFileExists()) {
        qDebug() << "Successfully found XBee data file";
        xbeeDataTimer.start(1000);  // Check every 1000ms
        emit xbeeConnectionChanged(true);
    } else {
        qDebug() << "Waiting for XBee data file to be created...";
        emit xbeeConnectionChanged(false);

        // Start reconnect timer
        reconnectTimer.start(1000);  // Try every second
    }
}

