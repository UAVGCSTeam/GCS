#include "dronecontroller.h"
#include "droneclass.h"
#include <QDebug>
// #include "drone.h"

QList<QSharedPointer<DroneClass>> DroneController::droneList;  // Define the static variable

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db) {
    // function loads all drones from the database on startup
    QList<QVariantMap> droneRecords = dbManager.fetchAllDrones();
    for (const QVariantMap &record : droneRecords) {
        QString name = record["drone_name"].toString();
        QString type = record["drone_type"].toString();
        QString xbeeAddress = record["xbee_address"].toString();
        // Should? work with other fields like xbee_id or drone_id if needed
        // existing table can have added columns for the lati and longi stuff and input here
        droneList.push_back(QSharedPointer<DroneClass>::create(name, type, xbeeAddress));
    }
    qDebug() << "Loaded" << droneList.size() << "drones from the database.";
}

// method so QML can retrieve the drone list.
QVariantList DroneController::getDroneList() const {
    QVariantList list;
    for (const QSharedPointer<DroneClass> &drone : droneList) {
        QVariantMap droneMap;
        // these method calls have to match our DroneClass interface
        droneMap["name"] = drone->getName();
        droneMap["type"] = drone->getRole(); // <-- we been using "drone type" in UI and everything but its called drone role in droneclass.h lul
        droneMap["xbeeAddress"] = drone->getXbeeAddress();
        // Adds placeholder values for status and battery and leave other fields blank
        droneMap["status"] = "Not Connected"; // or "Pending" or another placeholder
        droneMap["battery"] = "NA"; // static placeholder battery percent

        // uncomment to leave blank (not needed)
        /*droneMap["lattitude"] = ""; // leave as blank or add a default value
        droneMap["longitude"] = "";
        droneMap["altitude"] = "";
        droneMap["airspeed"] = "";*/

        list.append(droneMap);
    }
    return list;
}

// Steps in saving a drone.
/* User Clicks button to save drone information
 * Saving Drone
 * 1. Added To Database
 * 2. Added as Drone Object ?
 * 3. Added to a List of Drones from DroneManager
 * 4. Automatically view
 *
 * Viewable Drone
 */
void DroneController::saveDrone(const QString &input_name, const QString &input_type, const QString &input_xbeeID, const QString &input_xbeeAddress) {
    if (input_name.isEmpty()) {
        qWarning() << "Missing required name field!";
        return;
    }

    // Add Drone to Database
    if (dbManager.createDrone(input_name, input_type, input_type, input_xbeeAddress)) {
        qDebug() << "Drone created on DB successfully!";
    } else {
        qWarning() << "Failed to save drone.";
    }

    // Now we are going to create a shared pointer across qt for the drone class object with inputs of name, type, and xbee address
    droneList.push_back(QSharedPointer<DroneClass>::create(input_name, input_type, input_xbeeAddress));

    // This is an example of how we would access the last drone object of the list as a pointer to memory
    // QSharedPointer<DroneClass> tempPtr = droneList.last();

    // this is an example of using the list plus the object above use the methods and get information
    // qDebug() << "HIPEFULLY SOMETHIGBN :D" << droneList.data();
    // qDebug() << "HIPEFULLY A NAME :D" << tempPtr->getName();
    // QString tempName = "CHANGED NAME PLS";
    // tempPtr->setName(tempName);
    // qDebug() << "HIPEFULLY A CHANGED NAME :D" << tempPtr->getName();

    /*
    // Prepare the database
    droneClass.setName(input_name);
    droneClass.setRole(input_type);
    */
}

void DroneController::deleteDrone(const QString &input_name) {
    if (input_name.isEmpty()) {
        qWarning() << "Drone Controller: Name not passed by UI.";
    }
    if (dbManager.deleteDrone(input_name)) {
        qDebug() << "Drone deleted successfully!";
    }

}

// if we're being honest the slots being called by any function is in my head and i cant figure out if i need something rn
void DroneController::deleteALlDrones_UI() {
    if (dbManager.deleteAllDrones()) {
        droneList.clear(); // also delete drones in C++ memory

        qDebug() << "droneController: All drones deleted successfully!";

        //emit droneDeleted();
    } else {
        qWarning() << "Failed to delete all drones.";
    }
}
// DroneClass DroneController::getDroneByName(const QString &input_name){

// }

