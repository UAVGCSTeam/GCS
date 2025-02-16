#include "dbmanager.h"

#include <QSqlQuery> // wow queueries yay!!!
#include <QCoreApplication>
#include <QSqlError>
#include <QDir>

DBManager::DBManager(const QString& dbname) {
    gcs_db_connection = QSqlDatabase::addDatabase("QSQLITE"); // Signals for Qt that the DB will be in SQLite

    // Set database file path
    QString dbPath = dbname;

    // Store dbname in 'data/' directory.
    QDir dataDir(QCoreApplication::applicationDirPath() + "/data");
    if (!dataDir.exists()) {
        dataDir.mkpath(".");
    } // Create "data/" folder if it doesn’t exist
     dbPath = dataDir.filePath(dbname);  // Store inside "data/"

    gcs_db_connection.setDatabaseName(dbPath);

    if (!gcs_db_connection.open()) {
        qCritical() << "Database connection failed:" << gcs_db_connection.lastError().text();
        return;
    }

    qDebug() << "Database connected at:" << dbPath;
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

    return true;
}


bool DBManager::createDroneTable() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot create table.";
        return false;
    }

    // Check if the table already exists
    QSqlQuery checkTableQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='drones';");
    if (checkTableQuery.next()) {
        qDebug() << "Drones table already exists.";
        return true;
    }

    // Create the table if it does not exist
    QSqlQuery query;
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
    QString dbPath = gcs_db_connection.databaseName();
    QFile dbFile(dbPath);

    if (!dbFile.exists()) {
        qCritical() << "Database file does not exist at:" << dbPath;
        return false;
    }

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



