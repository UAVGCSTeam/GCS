#include "dbmanager.h"

#include <QSqlQuery>
#include <QCoreApplication>
#include <QSqlError>
#include <QDir>

DBManager::DBManager(const QString& path) {
    gcs_db_connection = QSqlDatabase::addDatabase("QSQLITE");

    // Ensure 'data/' directory exists
    QDir dataDir(QCoreApplication::applicationDirPath() + "/data");
    if (!dataDir.exists()) {
        dataDir.mkpath(".");
    }

    // Set database file path
    QString dbPath = dataDir.filePath("gcs.db");
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

    QSqlQuery query;
    if (!query.exec("PRAGMA foreign_keys = ON;")) {
        qCritical() << "Failed to enable foreign key constraints:" << query.lastError().text();
        return false;
    }

    if (!createTable()) {
        qCritical() << "Table creation failed!";
        return false;
    }

    return true;
}


bool DBManager::createTable() {
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
            xbee_id TEXT UNIQUE NOT NULL,
            xbee_address TEXT UNIQUE NOT NULL
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


