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

    // Set up timer connections but don't start yet
    connect(&xbeeDataTimer, &QTimer::timeout, this, &DroneController::processXbeeData);
    connect(&reconnectTimer, &QTimer::timeout, this, &DroneController::tryConnectToDataFile);
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
    // On Windows, always check user's TEMP folder first
#ifdef _WIN32
    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString tempFilePath = tempPath + "/xbee_tmp/xbee_data.json";

    QFile tempFile(tempFilePath);
    if (tempFile.exists()) {
        qDebug() << "Using Windows temp path:" << tempFilePath;
        return tempFilePath;
    }

    // Log the paths we're checking to aid debugging
    qDebug() << "Checked for XBee data file at:" << tempFilePath << "(not found)";
#endif

    // Original fallback paths
    QFile file(DEFAULT_DATA_FILE_PATH);
    if (file.exists()) {
        qDebug() << "Using default path:" << DEFAULT_DATA_FILE_PATH;
        return DEFAULT_DATA_FILE_PATH;
    }
    qDebug() << "Checked for XBee data file at:" << DEFAULT_DATA_FILE_PATH << "(not found)";

#ifdef _WIN32
    // Additional Windows fallbacks
    QString fallbackPath = tempPath + "/xbee_data.json";
    QFile fallbackFile(fallbackPath);
    if (fallbackFile.exists()) {
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
void DroneController::saveDrone(const QString &input_name, const QString &input_role, const QString &input_xbeeID, const QString &input_xbeeAddress) {
    // Add debug output to see what's being passed
    qDebug() << "saveDrone called with:" << input_name << input_role << input_xbeeID << input_xbeeAddress;

    if (input_name.isEmpty()) {
        qWarning() << "Missing required name field!";
        return;
    }

    // Check if a drone with this address already exists - avoid duplicates
    bool exists = false;
    for (const auto &drone : droneList) {
        if (drone->getXbeeAddress() == input_xbeeAddress) {
            exists = true;
            qDebug() << "Drone with address" << input_xbeeAddress << "already exists!";
            break;
        }
    }

    if (exists) {
        qDebug() << "Skipping save for existing drone with address:" << input_xbeeAddress;
        return;
    }

    // Add Drone to Database
    int newDroneId = -1;
    if (dbManager.createDrone(input_name, input_role, input_xbeeID, input_xbeeAddress, &newDroneId)) {
        qDebug() << "Drone created in DB successfully with ID:" << newDroneId;

        // Add to the in-memory list
        droneList.push_back(QSharedPointer<DroneClass>::create(input_name, input_role, input_xbeeID, input_xbeeAddress));

        qDebug() << "About to emit dronesChanged signal after adding drone";
        emit dronesChanged();
        qDebug() << "dronesChanged signal emitted";
    } else {
        qWarning() << "Failed to save drone to database!";
    }
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

            // Update in database
            QSqlQuery query;
            query.prepare("SELECT drone_id FROM drones WHERE xbee_id = :xbeeId");
            query.bindValue(":xbeeId", oldXbeeId);

            if (query.exec() && query.next()) {
                int droneId = query.value(0).toInt();
                dbManager.editDrone(droneId, name, role, xbeeId, xbeeAddress);
            }

            emit dronesChanged();
            break;
        }
    }
}

void DroneController::deleteDrone(const QString &input_xbeeId) {
    if (input_xbeeId.isEmpty()) {
        qWarning() << "Drone Controller: xbeeId not passed by UI.";
        return;
    }

    // Try to find and delete the drone from memory first
    bool found = false;
    for (int i = 0; i < droneList.size(); i++) {
        if (droneList[i]->getXbeeID() == input_xbeeId ||
            droneList[i]->getXbeeAddress() == input_xbeeId) {
            droneList.removeAt(i);
            found = true;
            qDebug() << "Removed drone from memory with ID/address:" << input_xbeeId;
            break;
        }
    }

    // Now delete from database, even if not found in memory
    if (dbManager.deleteDrone(input_xbeeId)) {
        qDebug() << "Drone deleted successfully from database:" << input_xbeeId;
        emit dronesChanged();
    } else {
        qWarning() << "Failed to delete drone from database:" << input_xbeeId;
        // If we removed from memory but failed to delete from DB, sync
        if (found) {
            emit dronesChanged();
        }
    }
}

// if we're being honest the slots being called by any function is in my head and i cant figure out if i need something rn
void DroneController::deleteALlDrones_UI() {
    if (dbManager.deleteAllDrones()) {
        droneList.clear(); // also delete drones in C++ memory

        qDebug() << "droneController: All drones deleted successfully!";

        emit dronesChanged();
    } else {
        qWarning() << "Failed to delete all drones.";
    }
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

// If want to query by name
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
    qDebug() << "Looking for drone with address:" << address;

    // First try exact address match
    for (const auto &drone : droneList) {
        if (drone->getXbeeAddress() == address) {
            qDebug() << "Found drone by address:" << drone->getName();
            return drone;
        }
    }

    // If not found, try xbeeId match
    for (const auto &drone : droneList) {
        if (drone->getXbeeID() == address) {
            qDebug() << "Found drone by XBee ID:" << drone->getName();
            return drone;
        }
    }

    // Attempt a more flexible match (case insensitive, partial)
    for (const auto &drone : droneList) {
        if (drone->getXbeeAddress().contains(address, Qt::CaseInsensitive) ||
            address.contains(drone->getXbeeAddress(), Qt::CaseInsensitive)) {
            qDebug() << "Found drone by partial address match:" << drone->getName();
            return drone;
        }
    }

    qDebug() << "No drone found with address:" << address;
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
    QSqlQuery query("SELECT drone_id, drone_name, drone_role, xbee_id, xbee_address FROM drones");

    if (query.exec()) {
        while (query.next()) {
            QVariantMap drone;
            drone["id"] = query.value(0).toInt();
            drone["name"] = query.value(1).toString();
            drone["role"] = query.value(2).toString();  // Changed from "type" to "role"
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
                droneMap["role"].toString(),  // Changed from "type" to "role"
                droneMap["xbeeId"].toString(),
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

    qDebug() << "Raw XBee data:" << data.left(100) << "..."; // Show first 100 chars

    // Try to parse as JSON
    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    if (doc.isNull()) {
        qWarning() << "Failed to parse XBee data as JSON";
        return;
    }

    QJsonObject obj = doc.object();
    QString messageType = obj["type"].toString();

    // Handle heartbeat messages
    if (messageType == "heartbeat") {
        // Handle heartbeat (existing code)
        return;
    }

    // Handle drone data messages
    if (messageType == "xbee_data") {
        QString droneName = obj["drone"].toString();
        QString address = obj["address"].toString();
        QString message = obj["message"].toString();

        qDebug() << "Received XBee data for:" << droneName << "at address:" << address;
        qDebug() << "Message content:" << message;

        // First try to find drone by XBee address
        QSharedPointer<DroneClass> drone = getDroneByXbeeAddress(address);

        if (!drone.isNull()) {
            qDebug() << "Found matching drone:" << drone->getName();
            // Update drone state based on XBee data
            drone->processXbeeMessage(message);

            // Emit signal that drone state has changed
            emit droneStateChanged(drone->getName());
        } else {
            qDebug() << "Received data for unknown drone at address:" << address;
            qDebug() << "Available drones:";
            for (const auto &d : droneList) {
                qDebug() << "  -" << d->getName() << ":" << d->getXbeeID() << "/" << d->getXbeeAddress();
            }
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
