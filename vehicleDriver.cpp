#include "vehicle.h"
#include <vector>
#include <iostream>
/**
 * This is me explaining that this is just how vehicle will managed and how main takes it
 *
 */

/**
 * Okay had a brain jam over this but because I don't NEED Vehicle1 to care about Vehicle2, theres no need for the Vehicle class to hold it.
*/
// Optional so the rest of the program keeps going
/**
 *  returns
 */
std::optional<Vehicle> getVehicle(const std::vector<Vehicle>& vehicleList, std::string searchID) {
    // Search VehicleList for matching Vehicle
    for (const auto& vehicle : vehicleList) {
        if (vehicle.getID() == searchID) { return vehicle; }
    }
    // i dont remember the debug
    std::cout << "Could not find the Vehicle with id" << searchID << std::endl;
    return std::nullopt; // Return empty optional
}

void runSimpleVehicleTest()
{

    std::cout << "------------------------------" << std::endl;
    // Create default  Vehicle and use update to do it.
    Vehicle v1;
    v1.updateId("001");
    v1.updateRole("arona");
    v1.updateStatus("sleeping");
    v1.printAllDroneInfo();

    Vehicle v2;
    v2.updateId("002");
    v2.updateRole("plana");
    v1.updateStatus("on");
    v2.printAllDroneInfo();

    std::cout << "End Test" << std::endl;
    std::cout << "------------------------------" << std::endl;
}

void runWeirdVehicleTest() {
    std::vector<Vehicle> vehicleList;

    // Some freak stuff, clone a vehicle with another Vehicles oject
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
}
