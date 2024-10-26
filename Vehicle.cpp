#include <iostream>
#include <string>
#include <vector>
#include <pybind11/pybind11.h>

using namespace std;
namespace py = pybind11;

class Vehicle {
    public:
        static std::vector<Vehicle*> VehicleList;

        string role;
        string status;
        int batteryLevel = -1;
        float position[3] = {-1, -1, -1}; // longitude, lattidue, altitude
        int velocity[3] = {-1, -1, -1}; // x, y, z
        string id;
        int orientation[3] = {-1, -1, -1}; // x, y, z
        // Flight flightLog[]; will implement later when 'Flight' object is also implemented
        string remoteXbeeAddress;

    Vehicle() {
        VehicleList.push_back(this);
    }

    Vehicle(string input_id, string input_role, string input_remoteXbeeAddress, string input_name){
        VehicleList.push_back(this);
        id = id;
        role = role;
        remoteXbeeAddress = remoteXbeeAddress;
        name = name;
    }

    // this is returning a copy of the vehicle that you are looking for
    static Vehicle getVehicle(string inputId) {
        Vehicle temp;
        Vehicle nullVehicle;
        for(Vehicle* vehicle : VehicleList) {
            temp = *vehicle;

            if(temp.id == inputId) {
                return temp;
            }
        } 

        cout << ">   No vehicle with Id: '" << inputId << "' found." << endl;
        cout << "------------------------------" << endl;
        return nullVehicle;
    }

    string getRole() {
        return role;
    }

    void updateRole(string inputRole) {
        role = inputRole;
    }

    string getStatus() {
        return status;
    }

    void updateStatus(string inputStatus) {
        status = inputStatus;
    }

    int getBatteryLevel() {
        return batteryLevel;
    }

    void updateBatteryLevel(int inputBatteryLevel) {
        batteryLevel = inputBatteryLevel;
    }

    float* getPosition() {
        return position;
    }

    void updatePosition(float longitude, float latitude, float altitude) {
        position[0] = longitude;
        position[1] = latitude;
        position[2] = altitude;
    }

    int* getVelocity() {
        return velocity;
    }

    void updateVelocity(int x, int y, int z) {
        velocity[0] = x;
        velocity[1] = y;
        velocity[2] = z;
    }

    string getId() {
        return id;
    }

    void updateId(string inputId) {
        id = inputId;
    }

    int* getOrientation() {
        return orientation;
    }

    void updateOrientation(int x, int y, int z) {
        orientation[0] = x;
        orientation[1] = y;
        orientation[2] = z;
    }

    // bool checkXbeeOpen() {
    //
    // }
    
    void printAllInfo() {
        cout << "Role: " << role << endl;
        cout << "Status: " << status << endl;
        cout << "Battery Level: " << batteryLevel << endl;
        cout << "Position-Longitude: " << position[0] << endl;
        cout << "Position-Latitude: " << position[1] << endl;
        cout << "Position-Altitude: " << position[2] << endl;
        cout << "Velocity-x: " << velocity[0] << endl;
        cout << "Velocity-y: " << velocity[1] << endl;
        cout << "Velocity-z: " << velocity[2] << endl;
        cout << "Id: " << id << endl;
        cout << "Orientation-x: " << orientation[0] << endl;
        cout << "Orientation-y: " << orientation[1] << endl;
        cout << "Orientation-z: " << orientation[2] << endl;
        cout << "Remote XBee Address: " << remoteXbeeAddress << endl;
        cout << "------------------------------" << endl;
    }
};

std::vector<Vehicle*> Vehicle::VehicleList;

PYBIND11_MODULE(vehicle, m) {
    py::class_<Vehicle>(m, "Vehicle")
        .def(py::init<>())
        .def_static("getVehicle", &Vehicle::getVehicle)
        .def("getRole", &Vehicle::getRole)
        .def("updateRole", &Vehicle::updateRole)
        .def("getStatus", &Vehicle::getStatus)
        .def("updateStatus", &Vehicle::updateStatus)
        .def("getBatteryLevel", &Vehicle::getBatteryLevel)
        .def("updateBatteryLevel", &Vehicle::updateBatteryLevel)
        .def("getPosition", [](Vehicle& v) {
            return py::make_tuple(v.position[0], v.position[1], v.position[2]);
        })
        .def("updatePosition", &Vehicle::updatePosition)
        .def("getVelocity", [](Vehicle& v) {
            return py::make_tuple(v.velocity[0], v.velocity[1], v.velocity[2]);
        })
        .def("updateVelocity", &Vehicle::updateVelocity)
        .def("getId", &Vehicle::getId)
        .def("updateId", &Vehicle::updateId)
        .def("getOrientation", [](Vehicle& v) {
            return py::make_tuple(v.orientation[0], v.orientation[1], v.orientation[2]);
        })
        .def("updateOrientation", &Vehicle::updateOrientation)
        .def("printAllInfo", &Vehicle::printAllInfo);
}

// std::vector<Vehicle*> Vehicle::VehicleList;

// int main() {
//     cout << "------------------------------" << endl;
//     Vehicle v1;
//     v1.updateId("001");
//     v1.updateRole("arona");
//     v1.updateStatus("sleeping");
//     v1.printAllInfo();

//     Vehicle v2;
//     v2.updateId("002");
//     v2.updateRole("plana");
//     v1.updateStatus("on");
//     v2.printAllInfo();

//     Vehicle v3 = Vehicle::getVehicle("001");
//     v3.printAllInfo();

//     v3.updateRole("shiroko");

//     v1.printAllInfo();
//     v3.printAllInfo();

//     Vehicle v4 = Vehicle::getVehicle("003");

//     v1.updatePosition(25, 25, 5);
//     v1.printAllInfo();

//     v1.updateVelocity(5, -1, 0);
//     v1.printAllInfo();

//     v1.updateOrientation(90, 90, 0);
//     v1.printAllInfo();

//     // v1.updatePosition(25, 25, 5);
//     // float* tempPosition = v1.getPosition();
//     // for(int i = 0; i < 3; i++) {
//     //     cout << tempPosition[i] << endl;
//     // }

//     // v1.updateVelocity(5, -1, 0);
//     // int* tempVelocity = v1.getVelocity();
//     // for(int i = 0; i < 3; i++) {
//     //     cout << tempVelocity[i] << endl;
//     // }

//     // v1.updateOrientation(90, 90, 0);
//     // int* tempOrientation = v1.getOrientation();
//     // for(int i = 0; i < 3; i++) {
//     //     cout << tempOrientation[i] << endl;
//     // }

//     return 0;
// };