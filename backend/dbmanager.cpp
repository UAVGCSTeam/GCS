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

    if (!createInitialDrones()) {
        qWarning() << "Failed to create initial drones.";
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
            drone_name TEXT NOT NULL UNIQUE,
            drone_role TEXT,
            xbee_id TEXT,
            xbee_address TEXT
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

bool DBManager::createDrone(const QString& droneName, const QString& droneRole, const QString& xbeeID, const QString& xbeeAddress) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot add drone.";
        return false;
    }
    QSqlQuery insertQuery;


    // Step 1: Check if a drone with the same name exists
    if (checkIfDroneExists(droneName)) {
        qCritical() << "A drone with the name " << droneName << " already exists!";
        return false; // if drone returns true, throw false
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
        qCritical() << "Failed to add drone:" << insertQuery.lastError().text();
        return false;
    }

    qDebug() << "Drone added successfully: " << droneName;
    return true;
}


bool DBManager::deleteDrone(const QString& droneName) {
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

bool DBManager::editDrone(int droneID, const QString& droneName, const QString& droneRole,
                          const QString& xbeeID, const QString& xbeeAddress) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot edit drone.";
        return false;
    }

    if (droneID <= 0) {
        qWarning() << "Invalid drone ID: " << droneID;
        return false;
    }

    if (!droneName.isEmpty() && checkIfDroneExists(droneName)) {
        qWarning() << "Cannot update drone: name already exists:" << droneName;
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

    QSqlQuery query("SELECT drone_id, drone_name, drone_Role, xbee_id, xbee_address FROM drones", gcs_db_connection);

    qDebug() << "---- Drone List ----";
    bool hasData = false;

    while (query.next()) {
        hasData = true;
        int id = query.value(0).toInt();
        QString name = query.value(1).toString();
        QString role = query.value(2).toString();
        QString xbeeId = query.value(3).toString();
        QString xbeeAddress = query.value(4).toString();

        qDebug() << "ID:" << id << "| Name:" << name << "| Role:" << role
                 << "| XBee ID:" << xbeeId << "| XBee Address:" << xbeeAddress;
    }

    if (!hasData) {
        qDebug() << "No drones found.";
    }

}

bool DBManager::checkIfDroneExists(const QString& droneName) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot check existence.";
        return false;
    }

    QSqlQuery query(gcs_db_connection);
    query.prepare("SELECT COUNT(*) FROM drones WHERE drone_name = :droneName");
    query.bindValue(":droneName", droneName);

    if (!query.exec()) {
        qCritical() << "Error checking for existing drone:" << query.lastError().text();
        return false;
    }

    query.next();
    return query.value(0).toInt() > 0; // Returns true if at least one matching drone exists
}

bool DBManager::createInitialDrones() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot insert initial drones.";
        return false;
    }

    // Check if drones already exist to avoid duplicates
    if (checkIfDroneExists("Firehawk") || checkIfDroneExists("Octoquad")) {
        qDebug() << "Initial drones not created: table already contains drones.";
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
        qCritical() << "Failed to insert Firehawk:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "Firehawk inserted successfully.";
    }

    // Insert second drone
    insertQuery.bindValue(":droneName", "Octoquad");
    insertQuery.bindValue(":droneRole", "Detection");
    insertQuery.bindValue(":xbeeID", "C");
    insertQuery.bindValue(":xbeeAddress", "0013A200422F2FDF");

    if (!insertQuery.exec()) {
        qCritical() << "Failed to insert Octoquad:" << insertQuery.lastError().text();
        return false;
    } else {
        qDebug() << "Octoquad inserted successfully.";
    }

    qDebug() << "Both initial drones created successfully.";
    return true;
}

// NEW: Method to fetch all drones from the database
QList<QVariantMap> DBManager::fetchAllDrones() {
    QList<QVariantMap> drones;
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot fetch drones.";
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
        qCritical() << "Failed to fetch drones:" << query.lastError().text();
    }
    return drones;
}
