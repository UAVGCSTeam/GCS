#include "dbmanager.h"

#include <QSqlQuery>
#include <QCoreApplication>
#include <QSqlError>
#include <QDir>

DBManager::DBManager(const QString& path) {
    gcs_db_connection = QSqlDatabase::addDatabase("QSQLITE");
    // Tell Qt to connect to SQL Database, Sqlite
    //gcs_db_connection.setDatabaseName("gcs.db");

    gcs_db_connection.setDatabaseName(QCoreApplication::applicationDirPath() + "/data/gcs.db");

    // Ensure 'data/' directory exists
    QDir dataDir(QCoreApplication::applicationDirPath() + "/data");
    if (!dataDir.exists()) {
        dataDir.mkpath(".");
    }

    QString dbPath = dataDir.filePath("gcs.db");
    gcs_db_connection.setDatabaseName(dbPath);

    if (gcs_db_connection.open()) {
        qDebug() << "Database connected at:" << dbPath;
    } else {
        qCritical() << "Database connection failed:" << gcs_db_connection.lastError().text();
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
    QSqlQuery query;
    query.exec("PRAGMA foreign_keys = ON;");  // Ensure FK constraints are enforced
    // TODO: check this
    return createTable();
}

// Create Table (Ensures Drone Table Exists)
bool DBManager::createTable() {
    if (!gcs_db_connection.isOpen()) {
        qCritical() << "Database is not open! Cannot create table.";
        return false;
    }

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

    qDebug() << "Drones table checked/created successfully.";
    return true;
}


// Add a New Drone Entry
bool DBManager::addDrone(const QString& name) {
    if (!gcs_db_connection.isOpen()) return false;

    QSqlQuery query;
    query.prepare("INSERT INTO drones (name) VALUES (:name)");
    query.bindValue(":name", name);

    if (!query.exec()) {
        qCritical() << "Add drone failed:" << query.lastError().text();
        return false;
    }

    qDebug() << "Drone added successfully:" << name;
    return true;
}

// Delete a Drone Entry
bool DBManager::deleteDrone(const QString& name) {
    if (!gcs_db_connection.isOpen()) return false;

    QSqlQuery query;
    query.prepare("DELETE FROM drones WHERE name = :name");
    query.bindValue(":name", name);

    if (!query.exec()) {
        qCritical() << "Delete drone failed:" << query.lastError().text();
        return false;
    }

    qDebug() << "Drone deleted successfully:" << name;
    return true;
}

// Print All Drones in Database
void DBManager::printDroneList() const {
    if (!gcs_db_connection.isOpen()) return;

    QSqlQuery query("SELECT id, name FROM drones");
    while (query.next()) {
        qDebug() << "ID:" << query.value(0).toInt() << "Name:" << query.value(1).toString();
    }
}
