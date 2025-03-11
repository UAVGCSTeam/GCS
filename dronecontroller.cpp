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

// #include "drone.h"

// DATA PATH
#define DATA_FILE_PATH "/tmp/xbee_data.json"

QList<QSharedPointer<DroneClass>> DroneController::droneList;  // Define the static variable

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db) {

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
// Save a drone to the database and add it to the in-memory list
void DroneController::saveDrone(const QString &input_name, const QString &input_type, const QString &input_xbeeID, const QString &input_xbeeAddress) {
    if (input_name.isEmpty()) {
        qWarning() << "Missing required name field!";
        return;
    }

    // Add Drone to Database
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
    QFile file(DATA_FILE_PATH);
    if (file.exists()) {
        qDebug() << "Found XBee data file at:" << DATA_FILE_PATH;
        return true;
    } else {
        qDebug() << "XBee data file not found at:" << DATA_FILE_PATH;
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
    QFile file(DATA_FILE_PATH);

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

