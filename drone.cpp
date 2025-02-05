#include "drone.h"

#include <iostream>

// Constructor
drone::drone(const std::string &input_id, const std::string &input_name, const std::string &input_role, const std::string &input_remoteXbeeAddress)
{
    ICAO_ID = input_id;
    this->role = role;
    remoteXbeeAddress = input_remoteXbeeAddress;
    this->name = name;
}

// TODO:
bool drone::checkIfXbeeConnected() {
    return true;
}
/**
 * Skipping a lot in-line functions of setters and getters:
 * updateID, getID
 * updateRole, getRole
 * updateStatus, getStatus
 * updateBatteryLevel, getBatteryLevel
*/

void drone::updatePosition(float longitude, float latitude, float altitude)
{
    position[0] = longitude;
    position[1] = latitude;
    position[2] = altitude;
}


void drone::updateVelocity(float x, float y, float z)
{
    velocity[0] = x;
    velocity[1] = y;
    velocity[2] = z;
}

void drone::updateOrientation(float x, float y, float z)
{
    orientation[0] = x;
    orientation[1] = y;
    orientation[2] = z;
}

// I forgot how classes work, is this all suppose to be like getRole?
// Member function to display Drone Info
void drone::printAllDroneInfo()
{
    std::cout << "Role: " << role << std::endl;
    std::cout << "Status: " << status << std::endl;
    std::cout << "Battery Level: " << batteryLevel << std::endl;
    std::cout << "Position-Longitude: " << position[0] << std::endl;
    std::cout << "Position-Latitude: " << position[1] << std::endl;
    std::cout << "Position-Altitude: " << position[2] << std::endl;
    std::cout << "Velocity-x: " << velocity[0] << std::endl;
    std::cout << "Velocity-y: " << velocity[1] << std::endl;
    std::cout << "Velocity-z: " << velocity[2] << std::endl;
    std::cout << "Id: " << ICAO_ID << std::endl;
    std::cout << "Orientation-x: " << orientation[0] << std::endl;
    std::cout << "Orientation-y: " << orientation[1] << std::endl;
    std::cout << "Orientation-z: " << orientation[2] << std::endl;
    std::cout << "Remote XBee Address: " << remoteXbeeAddress << std::endl;
    std::cout << "------------------------------" << std::endl;

    return; // success
}
