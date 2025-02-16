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
        initDB();
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
bool DBManager::initDB() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open!";
        return false;
    }

    if (!createDroneTable()) {
        qCritical() << "Table creation failed!";
        return false;
    }
    return true; // Only return true if table creation succeeded
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

bool DBManager::addDrone(const QString& name, const QString& type, const QString& xbeeId, const QString& xbeeAddress) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot add drone.";
        return false;
    }

    QSqlQuery query;
    query.prepare(R"(
        INSERT INTO drones (drone_name, drone_type, xbee_id, xbee_address)
        VALUES (:name, :type, :xbeeId, :xbeeAddress);
    )");

    query.bindValue(":name", name);
    query.bindValue(":type", type.isEmpty() ? QVariant(QString()) : type);
    query.bindValue(":xbeeId", xbeeId.isEmpty() ? QVariant(QString()) : xbeeId);
    query.bindValue(":xbeeAddress", xbeeAddress.isEmpty() ? QVariant(QString()) : xbeeAddress);

    if (!query.exec()) {
        qCritical() << "Failed to add drone:" << query.lastError().text();
        return false;
    }

    qDebug() << "Drone added successfully: " << name;
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


