#include "dronecontroller.h"
#include "droneclass.h"
#include <QDebug>
// #include "drone.h"

QVector<DroneClass*> DroneController::droneList;  // Define the static variable to store all drone objects

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db) {

    // Populate with 6 dummy drone instances of DroneClass objects for testing icon markers using setLattitude and setLongitude
    DroneClass* drone1 = new DroneClass(this);
    drone1->setName("Drone 1");
    drone1->setLattitude(34.05917);
    drone1->setLongitude(-117.82051);
    addDrone(drone1);

    DroneClass* drone2 = new DroneClass(this);
    drone2->setName("Drone 2");
    drone2->setLattitude(34.0600);
    drone2->setLongitude(-117.8210);
    addDrone(drone2);

    DroneClass* drone3 = new DroneClass(this);
    drone3->setName("Drone 3");
    drone3->setLattitude(34.0615);
    drone3->setLongitude(-117.8225);
    addDrone(drone3);

    DroneClass* drone4 = new DroneClass(this);
    drone4->setName("Drone 4");
    drone4->setLattitude(37.7749);
    drone4->setLongitude(-122.4194);
    addDrone(drone4);

    DroneClass* drone5 = new DroneClass(this);
    drone5->setName("Drone 5");
    drone5->setLattitude(34.0119);
    drone5->setLongitude(-118.4916);
    addDrone(drone5);

    DroneClass* drone6 = new DroneClass(this);
    drone6->setName("Drone 6");
    drone6->setLattitude(32.7157);
    drone6->setLongitude(-117.1611);
    addDrone(drone6);
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

// Saves a drone to the database
void DroneController::saveDrone(const QString &input_name, const QString &input_type, const QString &input_xbeeID, const QString &input_xbeeAddress) {
    if (input_name.isEmpty()) {
        qWarning() << "Missing required name field!";
        return;
    }

    // Attempts to save the drone to the database
    if (dbManager.createDrone(input_name, input_type, input_type, input_xbeeAddress)) {
        qDebug() << "Drone created on DB successfully!";
    } else {
        qWarning() << "Failed to save drone.";
    }
}

// Adds a drone to the list and emits a signal to the UI
void DroneController::addDrone(DroneClass* drone) {
    if (drone) {
        droneList.append(drone);
    }
    emit droneAdded();
}

// Retrieves all drones
QVariantList DroneController::getAllDrones() const {
    QVariantList droneListData;
    for (const DroneClass* drone : droneList) {
        QVariantMap droneData;
        droneData["name"] = drone->getName();
        droneData["latitude"] = drone->getLattitude();
        droneData["longitude"] = drone->getLongitude();
        droneListData.append(droneData);
    }
    debugPrintDrones(); // Log drone data for debugging
    return droneListData;
}

// Creates a new drone with default values and adds it to the system
void DroneController::createDrone(const QString &input_name) {
    DroneClass* temp = new DroneClass(this);
    temp->setName(input_name);
    temp->setLattitude(34.06152);
    temp->setLongitude(-117.82254);
    addDrone(temp);

    // saveDrone(input_name, "DefaultType", "DefaultXbeeID", "DefaultXbeeAddress"); #Update saveDrone in the future to accept droneClass objects intead
}

// Prints all Dummy Drone Objects'?;'
void DroneController::debugPrintDrones() const {
    qDebug() << "------ Drone Objects ------";
    for (const DroneClass* drone : droneList) {
        qDebug() << "Drone Name:" << drone->getName()
        << ", Latitude:" << drone->getLattitude()
        << ", Longitude:" << drone->getLongitude();
    }
    qDebug() << "---------------------------";
}
// DroneClass DroneController::getDroneByName(const QString &input_name){

// }

