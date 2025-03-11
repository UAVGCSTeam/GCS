#include "dbmanager.h"

#include <QSqlQuery> // wow queueries yay!!!
#include <QCoreApplication>
#include <QSqlError>
#include <QDir>
DBManager::DBManager(QObject *parent) : QObject(parent) {
    gcs_db_connection = QSqlDatabase::addDatabase("QSQLITE"); // Signals for Qt that the DB will be in SQLite

    // Set database file path directly to gcs.db
    QString dbName = "gcs.db";

    // Store in data directory, except it does it under build !!!
    QDir dataDir(QCoreApplication::applicationDirPath() + "/data");
    if (!dataDir.exists()) {
        dataDir.mkpath(".");
    }
    QString dbPath = dataDir.filePath(dbName);

    gcs_db_connection.setDatabaseName(dbPath);

    if (!gcs_db_connection.open()) {
        qCritical() << "Database connection failed:" << gcs_db_connection.lastError().text();
        // this is lowkey impossible
    } else {
        qDebug() << "Database connected at:" << dbPath;
    }
}


// Destructor: Close database connection
DBManager::~DBManager() {
    if (gcs_db_connection.isOpen()) {
        gcs_db_connection.close();
        qDebug() << "Database connection closed.";
    }
}

// Initialize Database (Check if DB exists, create if not)
void DBManager::initDB() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open!";
    }

    if (!createDroneTable()) {
        qCritical() << "Table creation failed!";
    }
}



bool DBManager::createDroneTable() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot create table.";
        return false;
    }

    // Create the table if it does not exist
    QSqlQuery query(gcs_db_connection);
    QString createTableQuery = R"(
        CREATE TABLE IF NOT EXISTS drones (
            drone_id INTEGER PRIMARY KEY AUTOINCREMENT,
            drone_name TEXT NOT NULL,
            drone_type TEXT,
            xbee_id TEXT UNIQUE,
            xbee_address TEXT UNIQUE
        );
    )";

    if (!query.exec(createTableQuery)) {
        qCritical() << "Failed to create table:" << query.lastError().text();
        return false;
    }

    qDebug() << "Drones table created successfully.";
    return true;
}



bool DBManager::isOpen() const {
    return gcs_db_connection.isOpen();
}

// CRUD ME

bool DBManager::createDrone(const QString& droneName, const QString& droneType,
                            const QString& xbeeID, const QString& xbeeAddress,
                            int* newDroneId) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot add drone.";
        return false;
    }
    QSqlQuery checkDupQuery;
    QSqlQuery insertQuery;

    // Step 1: Check if a drone with the same XBee ID or Address already exists
    checkDupQuery.prepare(R"(
        SELECT COUNT(*) FROM drones WHERE xbee_id = :xbeeID OR xbee_address = :xbeeAddress;
    )");

    checkDupQuery.bindValue(":xbeeID", xbeeID);
    checkDupQuery.bindValue(":xbeeAddress", xbeeAddress);

    if (!checkDupQuery.exec()) {
        qCritical() << "Error checking for existing drone:" << checkDupQuery.lastError().text();
        return false;
    }

    checkDupQuery.next();
    if (checkDupQuery.value(0).toInt() > 0) {
        qCritical() << "Drone already exists with the same XBee ID or Address.";
        return false;
    }

    // Insert new drone after duplicate checking
    insertQuery.prepare(R"(
        INSERT INTO drones (drone_name, drone_type, xbee_id, xbee_address)
        VALUES (:droneName, :droneType, :xbeeID, :xbeeAddress);
    )");

    insertQuery.bindValue(":droneName", droneName);
    insertQuery.bindValue(":droneType", droneType.isEmpty() ? QVariant(QString()) : droneType);
    insertQuery.bindValue(":xbeeID", xbeeID.isEmpty() ? QVariant(QString()) : xbeeID);
    insertQuery.bindValue(":xbeeAddress", xbeeAddress.isEmpty() ? QVariant(QString()) : xbeeAddress);

    if (!insertQuery.exec()) {
        qCritical() << "Failed to add drone:" << insertQuery.lastError().text();
        return false;
    }

    // If the newDroneId pointer is provided, set the last inserted ID
    if (newDroneId != nullptr) {
        *newDroneId = insertQuery.lastInsertId().toInt();
        qDebug() << "New drone ID:" << *newDroneId;
    }

    qDebug() << "Drone added successfully: " << droneName;
    return true;
}


bool DBManager::deleteDrone(int id) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot delete drone.";
        return false;
    }

    QSqlQuery query(gcs_db_connection);
    query.prepare("DELETE FROM drones WHERE drone_id = :id");
    query.bindValue(":id", id);

    if (!query.exec()) {
        qCritical() << "Failed to delete drone:" << query.lastError().text();
        return false;
    }

    qDebug() << "Drone deleted successfully: ID " << id;
    return true;
}

bool DBManager::editDrone(int droneID, const QString& droneName, const QString& droneType,
                          const QString& xbeeID, const QString& xbeeAddress) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot edit drone.";
        return false;
    }

    if (droneID <= 0) {
        qWarning() << "Invalid drone ID: " << droneID;
        return false;
    }

    QString updateQuery = "UPDATE drones SET ";
    QVector<QPair<QString, QVariant>> values;

    if (!droneName.isEmpty()) {
        updateQuery += "drone_name = :droneName, ";
        values.append({"droneName", droneName});
    }
    if (!droneType.isEmpty()) {
        updateQuery += "drone_type = :droneType, ";
        values.append({"droneType", droneType});
    }
    if (!xbeeID.isEmpty()) {
        // Check if xbeeID is already assigned to another drone before updating
        QSqlQuery checkQuery(gcs_db_connection);
        checkQuery.prepare("SELECT drone_id FROM drones WHERE xbee_id = :xbeeID AND drone_id != :droneID");
        checkQuery.bindValue(":xbeeID", xbeeID);
        checkQuery.bindValue(":droneID", droneID);

        if (!checkQuery.exec()) {
            qCritical() << "Error checking for duplicate XBee ID:" << checkQuery.lastError().text();
            return false;
        }

        if (checkQuery.next()) {
            qWarning() << "XBee ID already exists for another drone. Cannot update.";
            return false;
        }

        updateQuery += "xbee_id = :xbeeID, ";
        values.append({"xbeeID", xbeeID});
    }
    if (!xbeeAddress.isEmpty()) {
        // Check if xbeeAddress is already assigned to another drone before updating
        QSqlQuery checkQuery(gcs_db_connection);
        checkQuery.prepare("SELECT drone_id FROM drones WHERE xbee_address = :xbeeAddress AND drone_id != :droneID");
        checkQuery.bindValue(":xbeeAddress", xbeeAddress);
        checkQuery.bindValue(":droneID", droneID);

        if (!checkQuery.exec()) {
            qCritical() << "Error checking for duplicate XBee Address:" << checkQuery.lastError().text();
            return false;
        }

        if (checkQuery.next()) {
            qWarning() << "XBee Address already exists for another drone. Cannot update.";
            return false;
        }

        updateQuery += "xbee_address = :xbeeAddress, ";
        values.append({"xbeeAddress", xbeeAddress});
    }

    // If no values to update, return false
    if (values.isEmpty()) {
        qWarning() << "No fields provided for update!";
        return false;
    }

    // Remove last comma and add WHERE clause
    updateQuery.chop(2);  // Removes the trailing comma and space
    updateQuery += " WHERE drone_id = :droneID";

    QSqlQuery query(gcs_db_connection);
    query.prepare(updateQuery);
    query.bindValue(":droneID", droneID);

    for (const auto &pair : values) {
        query.bindValue(":" + pair.first, pair.second);
    }

    if (!query.exec()) {
        qCritical() << "Failed to edit drone:" << query.lastError().text();
        return false;
    }

    qDebug() << "Drone updated successfully: ID " << droneID;
    return true;
}


// Testing funtion, to print on console
// Shows how to query to fetch all drones, useful for drone list
void DBManager::printDroneList() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot fetch drones.";
    }

    QSqlQuery query("SELECT drone_id, drone_name, drone_type, xbee_id, xbee_address FROM drones", gcs_db_connection);

    qDebug() << "---- Drone List ----";
    bool hasData = false;

    while (query.next()) {
        hasData = true;
        int id = query.value(0).toInt();
        QString name = query.value(1).toString();
        QString type = query.value(2).toString();
        QString xbeeId = query.value(3).toString();
        QString xbeeAddress = query.value(4).toString();

        qDebug() << "ID:" << id << "| Name:" << name << "| Type:" << type
                 << "| XBee ID:" << xbeeId << "| XBee Address:" << xbeeAddress;
    }

    if (!hasData) {
        qDebug() << "No drones found.";
    }
}


