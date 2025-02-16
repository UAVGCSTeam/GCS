#include "dbmanager.h"

#include <QSqlQuery> // wow queueries yay!!!
#include <QCoreApplication>
#include <QSqlError>
#include <QDir>

// Singleton Pattern: Ensures only one instance of DBManager
DBManager& DBManager::getInstance() {
    static DBManager instance;  // Only created once
    return instance;
}

// Private Constructor: Sets up the database connection
DBManager::DBManager() {
    if (QSqlDatabase::contains("qt_sql_default_connection")) {
        gcs_db_connection = QSqlDatabase::database("qt_sql_default_connection");
    } else {
        gcs_db_connection = QSqlDatabase::addDatabase("QSQLITE", "qt_sql_default_connection");
    }

    // Set database file path
    QString dbName = "gcs.db";
    QDir dataDir(QCoreApplication::applicationDirPath() + "/data");
    if (!dataDir.exists()) {
        dataDir.mkpath(".");
    }
    QString dbPath = dataDir.filePath(dbName);

    gcs_db_connection.setDatabaseName(dbPath);

    if (!gcs_db_connection.open()) {
        qCritical() << "Database connection failed:" << gcs_db_connection.lastError().text();
    } else {
        qDebug() << "Database connected at:" << dbPath;
    }
}

// Destructor: Keeps the connection open unless the app exits
DBManager::~DBManager() {
    if (gcs_db_connection.isOpen()) {
        qDebug() << "Database remains open. Will close on application exit.";
    }
}

// Check if the database is open
bool DBManager::isOpen() const {
    return gcs_db_connection.isOpen();
}

// Initialize database and create table
bool DBManager::initDB() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open!";
        return false;
    }
    return createDroneTable();
}

// Create the drones table if it doesn't exist
bool DBManager::createDroneTable() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot create table.";
        return false;
    }

    // Check if the table exists
    QSqlQuery checkTableQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='drones';", gcs_db_connection);
    if (checkTableQuery.next()) {
        qDebug() << "Drones table already exists.";
        return true;
    }

    // Create the table
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

// Insert a new drone into the database
bool DBManager::addDrone(const QString& name, const QString& type, const QString& xbeeId, const QString& xbeeAddress) {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot add drone.";
        return false;
    }

    QSqlQuery query(gcs_db_connection);
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



