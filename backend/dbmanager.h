#ifndef DBMANAGER_H
#define DBMANAGER_H

/**
 * @file This is me testing the database connections away from main.
 * Justfying why I don't want to put it in main, theoritically
 * the other qml files would directly call my functions.
 * @author Gian David Marquez
 */

#include <QString>
#include <QSqlDatabase>

class DBManager
{
public:
    // Constructor
    explicit DBManager(const QString& path);

    // Destructor
    ~DBManager();

    // Set Booleans as SQL operations should signify sucess or failure in it's access.

    bool initDB();
    bool isOpen() const;
    bool createTable();
    bool addDrone(const QString& name);
    bool deleteDrone(const QString& name);
    void printDroneList() const;

private:
    QSqlDatabase gcs_db_connection;
};

#endif // DBMANAGER_H
