#include "pybind11/pybind11.h"

#include "dronecontroller.h"
#include "droneclass.h"
#include <QDebug>
// #include "
// #include "Python.h"
// #include "drone.h"

namespace py = pybind11;

QList<QSharedPointer<DroneClass>> DroneController::droneList;  // Define the static variable

DroneController::DroneController(DBManager &db, QObject *parent)
    : QObject(parent), dbManager(db) {
    // try {
    //     xbeeModule = QSharedPointer<pybind11::module>::create(pybind11::module::import("xbeeFunctions"));  // Import Python script
    // } catch (const pybind11::error_already_set &e) {
    //     qDebug() << "Python Import Error: " << e.what();
    // }
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

    // Add Drone to Databae
    if (dbManager.createDrone(input_name, input_type, input_type, input_xbeeAddress)) {
        qDebug() << "Drone created on DB successfully!";
    } else {
        qWarning() << "Failed to save drone.";
    }

    // Now we are going to create a shared pointer across qt for the drone class object with inputs of name, type, and xbee address
    droneList.push_back(QSharedPointer<DroneClass>::create(input_name, input_type, input_xbeeAddress));
    // try {
    //     xbeeModule = QSharedPointer<pybind11::module>::create(pybind11::module::import("xbeeFunctions"));  // Import Python script
    // } catch (const pybind11::error_already_set &e) {
    //     qDebug() << "Python Import Error: " << e.what();
    // }
    py::module sys = py::module::import("sys");
    sys.attr("path").attr("append")("C:/GCS_Codes/qtGCS/GCS/GCS");
    py::module xbeeModule = py::module::import("xbeeFunctions");

    qDebug() << "Maybe we will get something: " << xbeeModule.attr("getMessage")().cast<std::string>();
    // py::module sys = py::module::import("sys");

    // py::print("python being used and called from dronecontroller :D", py::arg("flush") = true);
    // sys.attr("stdout").attr("flush")();

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

void DroneController::updateDronePosition(std::string droneID, float x, float y, float z){
    QSharedPointer<DroneClass> tempPtr = droneList.last();
    QVector3D tempPosition(x, y, z);
    tempPtr->setPosition(tempPosition);
}

void DroneController::testing(){
    qDebug() << "ITS HAPPENIGN";
}


// PYBIND11_MODULE(DroneController, m) {
//     py::class_<DroneController>(m, "DroneController")
//         .def(py::init<>())
//         .def("updateDrone", &DroneController::updateDrone);
// }
PYBIND11_MODULE(DroneController, m) {
    pybind11::class_<DroneController, QObject>(m, "DroneController")
    // Constructor for DroneController
    .def(pybind11::init<DBManager&, QObject*>(), pybind11::arg("gcsdb_in"), pybind11::arg("parent") = nullptr)
        // Slots
        .def("saveDrone", &DroneController::saveDrone,
             pybind11::arg("name"), pybind11::arg("type"), pybind11::arg("xbeeId"), pybind11::arg("xbeeAddress"))
        // Expose member functions
        .def("updateDrone", &DroneController::updateDronePosition,
             pybind11::arg("droneID"), pybind11::arg("x"), pybind11::arg("y"), pybind11::arg("z"));
}

// DroneClass DroneController::getDroneByName(const QString &input_name){

// }

