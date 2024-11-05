#ifndef VEHICLE_H
#define VEHICLE_H

#include <QObject> // added this to change signals
#include <string>
// Not using namespace std, just for better C++ mem protection
// Seperating pybind and Vehicle Class for now

// TODO: Check what needs to be constant, so values aren't changing
class Vehicle
{
    //Q_OBJECT
public:
    Vehicle(); // Default constructor
    Vehicle(std::string input_id, std::string input_name, std::string input_role, std::string input_remoteXbeeAddress);
    ~Vehicle(); // Deconstructor, delete Drone
    // Moved Vector List for Vehicles to another class, Vehicle Manager...

    bool checkIfXbeeConnected();
    // Setters and Getters
    // got rid of getVehicle
    void updateID(std::string inputId) { ICAO_ID = inputId; }
    std::string getID() const { return ICAO_ID; }

    // I'm having a brain fart on how vehicle goes, I guess if you call Vehicle(A).updateRole, it wouldn't need an ID?
    void updateRole(std::string inputID, std::string inputRole);
    /**
     *  Old role, might need this->?
     */
    void updateRole(std::string inputRole) { role = inputRole; };
    std::string getRole() {return role; }

    void updateStatus(std::string inputStatus) { status = inputStatus; }
    std::string getStatus() { return status; }

    void updateBatteryLevel(double inputBatteryLevel) { batteryLevel = inputBatteryLevel; }
    double getBatteryLevel() { return batteryLevel; }

    void updatePosition(float longitude, float latitude, float altitude);
    float *getPosition() { return position; }

    // changed int to float -- havent checked if ths breaks python stuff
    void updateVelocity(float x, float y, float z);
    int *getVelocity() { return velocity; }

    void updateOrientation(float x, float y, float z);
    int *getOrientation() { return orientation; }

    void printAllDroneInfo();
private:
    std::string ICAO_ID;   // ICAO currently labeled as "A" [Xbee]
    std::string name;      // "Death Hawk"
    std::string role;      // "Supression, Detection" ->
    /**
     * TODO: Move Role as Lead to other classes in future? where parent Drone -> Suppression, Detection.h
     * Hell we can make it so it's only a ID and name with other functions like type of connection -> xbee, etc...
    */
    std::string status;    // Not sure actually
    std::string remoteXbeeAddress;
    // Changed int to Double
    double batteryLevel = -1; // Default as -1, to show it's not actually recieving battery
    // It's an array because Megan wants everything in a tuple...?
    float position[3] = {-1, -1, -1};  // longitude, lattidue, altitude
    int velocity[3] = {-1, -1, -1};    // x, y, z
    int orientation[3] = {-1, -1, -1}; // x, y, z
};

#endif // VEHICLE_H
