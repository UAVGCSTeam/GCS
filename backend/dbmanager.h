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
    /* Informal Comment, not usual format for comments
     * Input: database file name
     * DBManager recieves DB file name and determines
     * where to store the file, explicitly being a data file.
     *
     * Issuses: data is stored in the whatever build Qt runs the application on. [Currently on debug]
     */
    explicit DBManager(const QString& dbname);

    // Destructor
    ~DBManager();

    // Set Booleans as SQL operations should signify sucess or failure in it's access.

    bool initDB();
    bool isOpen() const;
    bool createDroneTable();
    bool addDrone(const QString& name);
    bool deleteDrone(const QString& name);
    void printDroneList() const;

private:
    QSqlDatabase gcs_db_connection;
};

#endif // DBMANAGER_H
