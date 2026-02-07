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
        qCritical() << "[dbmanager.cpp] Database connection failed:" << gcs_db_connection.lastError().text();
        // this is lowkey impossible
    } else {
        qDebug() << "[dbmanager.cpp] Database connected at:" << dbPath;
    }
}



// Destructor: Close database connection
DBManager::~DBManager() {
    if (gcs_db_connection.isOpen()) {
        gcs_db_connection.close();
        qDebug() << "[dbmanager.cpp] Database connection closed.";
    }
}



// Initialize Database (Check if DB exists, create if not)
void DBManager::initDB() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open!";
    }

    if (!createDroneTable()) {
        qCritical() << "[dbmanager.cpp] Table creation failed!";
    }

    if (!createInitialDrones()) {
        qWarning() << "[dbmanager.cpp] Failed to create initial drones.";
    }
}



bool DBManager::createDroneTable() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot create table.";
        return false;
    }

    // Create the table if it does not exist
    QSqlQuery query(gcs_db_connection);
    QString createTableQuery = R"(
        CREATE TABLE IF NOT EXISTS drones (
            drone_id INTEGER PRIMARY KEY AUTOINCREMENT,
            drone_name TEXT NOT NULL UNIQUE,
            drone_role TEXT,
            xbee_id TEXT,
            xbee_address TEXT
        );
    )";

    if (!query.exec(createTableQuery)) {
        qCritical() << "[dbmanager.cpp] Failed to create table:" << query.lastError().text();
        return false;
    }

    qDebug() << "[dbmanager.cpp] Drones table created successfully.";
    return true;
}



bool DBManager::isOpen() const {
    return gcs_db_connection.isOpen();
}



// CRUD ME
bool DBManager::createDrone(const QString& droneName, const QString& droneRole,
                            const QString& xbeeID, const QString& xbeeAddress,
                            int* newDroneID) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot add drone.";
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
        qCritical() << "[dbmanager.cpp] Error checking for existing drone:" << checkDupQuery.lastError().text();
        return false;
    }

    checkDupQuery.next();
    if (checkDupQuery.value(0).toInt() > 0) {
        qCritical() << "[dbmanager.cpp] Drone already exists with the same XBee ID or Address.";
        return false;
    }

    // Insert new drone after duplicate checking
    insertQuery.prepare(R"(
        INSERT INTO drones (drone_name, drone_role, xbee_id, xbee_address)
        VALUES (:droneName, :droneRole, :xbeeID, :xbeeAddress);
    )");

    insertQuery.bindValue(":droneName", droneName);
    // this allows empty values to be set as null, meaning empty values can be entered like: ""
    insertQuery.bindValue(":droneRole", droneRole.isEmpty() ? QVariant(QString()) : droneRole);
    insertQuery.bindValue(":xbeeID", xbeeID.isEmpty() ? QVariant(QString()) : xbeeID);
    insertQuery.bindValue(":xbeeAddress", xbeeAddress.isEmpty() ? QVariant(QString()) : xbeeAddress);

    if (!insertQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to add drone:" << insertQuery.lastError().text();
        return false;
    }

    // If the newDroneID pointer is provided, set the last inserted ID
    if (newDroneID != nullptr) {
        *newDroneID = insertQuery.lastInsertId().toInt();
        qDebug() << "[dbmanager.cpp] New drone ID:" << *newDroneID;
    }

    qDebug() << "[dbmanager.cpp] Drone added successfully: " << droneName;
    return true;
}



bool DBManager::deleteDrone(const QString& xbeeIdOrAddress) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot delete drone.";
        return false;
    }

    QSqlQuery deleteQuery;
    deleteQuery.prepare("DELETE FROM drones WHERE xbee_id = :identifier OR xbee_address = :identifier");
    deleteQuery.bindValue(":identifier", xbeeIdOrAddress);

    if (!deleteQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to delete the drone: " << deleteQuery.lastError().text();
        return false;
    }

    qDebug() << "[dbmanager.cpp] DB: Drone deleted successfully: " << xbeeIdOrAddress;
    return deleteQuery.numRowsAffected() > 0; // Return true if any rows were affected
}



bool DBManager::deleteAllDrones() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot delete all drones.";
        return false;
    }

    QSqlQuery deleteAllQuery(gcs_db_connection);
    if (!deleteAllQuery.exec("DELETE FROM drones")) {
        qCritical() << "[dbmanager.cpp] Failed to delete all drones:" << deleteAllQuery.lastError().text();
        return false;
    }

    qDebug() << "[dbmanager.cpp] All drones deleted successfully.";
    return true;
}



bool DBManager::editDrone(int droneID, const QString& droneName, const QString& droneRole,
                          const QString& xbeeID, const QString& xbeeAddress) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot edit drone.";
        return false;
    }

    if (droneID <= 0) {
        qWarning() << "[dbmanager.cpp] Invalid drone ID: " << droneID;
        return false;
    }

    if (!droneName.isEmpty() && checkIfDroneExists(droneName)) {
        qWarning() << "[dbmanager.cpp] Cannot update drone: name already exists:" << droneName;
        return false;
    }

    QString updateQuery = "UPDATE drones SET ";
    QVector<QPair<QString, QVariant>> values;

    if (!droneName.isEmpty()) {
        updateQuery += "drone_name = :droneName, ";
        values.append({"droneName", droneName});
    }
    if (!droneRole.isEmpty()) {
        updateQuery += "drone_role = :droneRole, ";
        values.append({"droneRole", droneRole});
    }

    if (!xbeeID.isEmpty()) {
        updateQuery += "xbee_id = :xbeeID, ";
        values.append({"xbeeID", xbeeID});
    }
    if (!xbeeAddress.isEmpty()) {
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
        qCritical() << "[dbmanager.cpp] Failed to edit drone:" << query.lastError().text();
        return false;
    }

    qDebug() << "[dbmanager.cpp] Drone updated successfully: ID " << droneID;
    return true;
}



// Testing funtion, to print on console
// Shows how to query to fetch all drones, useful for drone list
void DBManager::printDroneList() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot fetch drones.";
    }

    QSqlQuery query("SELECT drone_id, drone_name, drone_role, xbee_id, xbee_address FROM drones", gcs_db_connection);

    qDebug() << "[dbmanager.cpp] ---- Drone List ----";
    bool hasData = false;

    while (query.next()) {
        hasData = true;
        int id = query.value(0).toInt();
        QString name = query.value(1).toString();
        QString role = query.value(2).toString();
        QString xbeeId = query.value(3).toString();
        QString xbeeAddress = query.value(4).toString();

        qDebug() << "[dbmanager.cpp] ID:" << id << "| Name:" << name << "| Role:" << role
                 << "| XBee ID:" << xbeeId << "| XBee Address:" << xbeeAddress;
    }

    if (!hasData) {
        qDebug() << "[dbmanager.cpp] No drones found.";
    }

}



bool DBManager::checkIfDroneExists(const QString& droneName) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot check existence.";
        return false;
    }

    QSqlQuery query(gcs_db_connection);
    query.prepare("SELECT COUNT(*) FROM drones WHERE drone_name = :droneName");
    query.bindValue(":droneName", droneName);

    if (!query.exec()) {
        qCritical() << "[dbmanager.cpp] Error checking for existing drone:" << query.lastError().text();
        return false;
    }

    query.next();
    return query.value(0).toInt() > 0; // Returns true if at least one matching drone exists
}



// Lets use this function to have "default" drones. 
bool DBManager::createInitialDrones() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot insert initial drones.";
        return false;
    }

    // Check if drones already exist to avoid duplicates
    if (checkIfDroneExists("Firehawk") || checkIfDroneExists("Octoquad")) {
        qDebug() << "[dbmanager.cpp] Initial drones not created: table already contains drones.";
        return false;
    }

    // Insert first drone
    QSqlQuery insertQuery(gcs_db_connection);
    insertQuery.prepare(R"(
        INSERT INTO drones (drone_name, drone_role, xbee_id, xbee_address)
        VALUES (:droneName, :droneRole, :xbeeID, :xbeeAddress);
    )");

    insertQuery.bindValue(":droneName", "Firehawk");
    insertQuery.bindValue(":droneRole", "Suppression");
    insertQuery.bindValue(":xbeeID", "A");
    insertQuery.bindValue(":xbeeAddress", "13A20041D365C4");

    if (!insertQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to insert Firehawk:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "[dbmanager.cpp] Firehawk inserted successfully.";
    }


    // Insert second drone
    insertQuery.bindValue(":droneName", "Octoquad");
    insertQuery.bindValue(":droneRole", "Detection");
    insertQuery.bindValue(":xbeeID", "B");
    insertQuery.bindValue(":xbeeAddress", "0013A200422F2FDF");

    if (!insertQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to insert Octoquad:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "[dbmanager.cpp] Octoquad inserted successfully.";
    }

    qDebug() << "[dbmanager.cpp] Both initial drones created successfully.";


    // Insert Third drone
    insertQuery.bindValue(":droneName", "Hexacopter");
    insertQuery.bindValue(":droneRole", "Suppression");
    insertQuery.bindValue(":xbeeID", "C");
    insertQuery.bindValue(":xbeeAddress", "0013A200422F2FD1");

    if (!insertQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to insert Hexacopter:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "[dbmanager.cpp] Hexacopter inserted successfully.";
    }

    // Insert fourth drone
    insertQuery.bindValue(":droneName", "4");
    insertQuery.bindValue(":droneRole", "Suppression");
    insertQuery.bindValue(":xbeeID", "D");
    insertQuery.bindValue(":xbeeAddress", "00134200422F2FD1");

    if (!insertQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to insert 4:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "[dbmanager.cpp] 4 inserted successfully.";
    }

    // Insert fifth drone
    insertQuery.bindValue(":droneName", "5");
    insertQuery.bindValue(":droneRole", "Suppression");
    insertQuery.bindValue(":xbeeID", "E");
    insertQuery.bindValue(":xbeeAddress", "00134200422F2FD1");

    if (!insertQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to insert 5:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "[dbmanager.cpp] 5 inserted successfully.";
    }

    // Insert sixth drone
    insertQuery.bindValue(":droneName", "6");
    insertQuery.bindValue(":droneRole", "Suppression");
    insertQuery.bindValue(":xbeeID", "F");
    insertQuery.bindValue(":xbeeAddress", "00134200422F2FD1");

    if (!insertQuery.exec()) {
        qCritical() << "[dbmanager.cpp] Failed to insert 6:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "[dbmanager.cpp] 6 inserted successfully.";
    }

    qDebug() << "[dbmanager.cpp] All initial drones created successfully.";
    return true;
}





// NEW: Method to fetch all drones from the database for initial startup and helper function
QList<QVariantMap> DBManager::fetchAllDrones() {
    QList<QVariantMap> drones;
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "[dbmanager.cpp] Database is not open! Cannot fetch drones.";
        return drones;
    }

    QSqlQuery query(gcs_db_connection);
    if(query.exec("SELECT drone_id, drone_name, drone_role, xbee_id, xbee_address FROM drones")) {
        while(query.next()) {
            QVariantMap drone;
            drone["drone_id"]    = query.value("drone_id").toInt();
            drone["drone_name"]  = query.value("drone_name").toString();
            drone["drone_role"]  = query.value("drone_role").toString();
            drone["xbee_id"]     = query.value("xbee_id").toString();
            drone["xbee_address"]= query.value("xbee_address").toString();
            drones.append(drone);
        }
    } else {
        qCritical() << "[dbmanager.cpp] Failed to fetch drones:" << query.lastError().text();
    }
    return drones;
}