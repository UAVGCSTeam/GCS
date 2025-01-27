#ifndef VEHICLE_H
#define VEHICLE_H

//#include <QObject> // added this to change signals
#include <string>
// Not using namespace std, just for better C++ mem protection
// Seperating pybind and Vehicle Class for now

// TODO: Check what needs to be constant, so values aren’t changing.
/**
 * @class Vehicle
 * @brief Represents a drone vehicle with properties for identification, 
 *        location, and status tracking.
 */
class Vehicle {
public:
    /**
     * Default constructor.
     * Initializes a Vehicle object with default values.
     */
    Vehicle();

    /**
     * Parameterized constructor.
     * Initializes a Vehicle object with specific values.
     * @param input_id The unique ICAO ID of the vehicle.
     * @param input_name The name assigned to the vehicle.
     * @param input_role The role or purpose of the vehicle.
     * @param input_remoteXbeeAddress The Xbee address for remote connection.
     */
    Vehicle(const std::string &input_id, const std::string &input_name, const std::string &input_role, const std::string &input_remoteXbeeAddress);
    // Moved Vector List for Vehicles to another class, Vehicle Manager...
    /**
     * Destructor.
     * Cleans up any resources used by the Vehicle object.
     */
    ~Vehicle();

    /**
     * Checks if the Xbee module is connected.
     * @return True if connected, false otherwise.
     */
    bool checkIfXbeeConnected();

    // Setters and Getters
    /**
     * Updates the ICAO ID of the vehicle.
     * @param inputId New ID for the vehicle.
     */
    void updateID(const std::string &inputId) { ICAO_ID = inputId; }

    /**
     * Gets the ICAO ID of the vehicle.
     * @return The ICAO ID as a string.
     */
    std::string getID() const { return ICAO_ID; }

    /**
     * Updates the role of the vehicle.
     * @param inputRole New role assigned to the vehicle.
     */
    void updateRole(const std::string &inputRole) { role = inputRole; }

    /**
     * Gets the role of the vehicle.
     * @return The role as a string.
     */
    std::string getRole() const { return role; }

    /**
     * Updates the current status of the vehicle.
     * @param inputStatus New status of the vehicle.
     */
    void updateStatus(const std::string &inputStatus) { status = inputStatus; }

    /**
     * Gets the current status of the vehicle.
     * @return The status as a string.
     */
    std::string getStatus() const { return status; }

    /**
     * Updates the battery level of the vehicle.
     * @param inputBatteryLevel New battery level percentage.
     */
    void updateBatteryLevel(double inputBatteryLevel) { batteryLevel = inputBatteryLevel; }

    /**
     * Gets the current battery level of the vehicle.
     * @return The battery level as a double.
     */
    double getBatteryLevel() const { return batteryLevel; }

    /**
     * Updates the position of the vehicle.
     * @param longitude New longitude position.
     * @param latitude New latitude position.
     * @param altitude New altitude level.
     */
    void updatePosition(float longitude, float latitude, float altitude);

    /**
     * Gets the position of the vehicle.
     * @return A pointer to an array containing longitude, latitude, and altitude.
     */
    const float* getPosition() const { return position; }

    /**
     * Updates the velocity of the vehicle.
     * @param x Velocity along the x-axis.
     * @param y Velocity along the y-axis.
     * @param z Velocity along the z-axis.
     */
    void updateVelocity(float x, float y, float z);

    /**
     * Gets the velocity of the vehicle.
     * @return A pointer to an array containing x, y, and z velocity components.
     */
    const float* getVelocity() const { return velocity; }

    /**
     * Updates the orientation of the vehicle.
     * @param x Orientation along the x-axis.
     * @param y Orientation along the y-axis.
     * @param z Orientation along the z-axis.
     */
    void updateOrientation(float x, float y, float z);

    /**
     * Gets the orientation of the vehicle.
     * @return A pointer to an array containing x, y, and z orientation components.
     */
    const int* getOrientation() const { return orientation; }

    /**
     * Prints all information related to the vehicle for debugging or display.
     */
    void printAllDroneInfo() const;

private:
    std::string ICAO_ID;        /** Unique ID for the vehicle (ICAO ID). */
    std::string name;           /** Name of the vehicle. */
    std::string role;           /** Role or mission type of the vehicle. */
    std::string status;         /** Current status (offline, connected, armed, flying). */
    // TODO: For now I think status as string makes sense, but functionally I'm imagining a switch statement as a number should be shorter byte

    std::string remoteXbeeAddress; /** Address for remote Xbee connectivity. */
    double batteryLevel = -1;   /** Battery level, default -1 indicates no data. */
    float position[3] = {-1, -1, -1}; /** Position array: longitude, latitude, altitude. */
    float velocity[3] = {-1, -1, -1};   /** Velocity array: x, y, z components. */
    int orientation[3] = {-1, -1, -1}; /** Orientation array: x, y, z components. */
};

#endif // VEHICLE_H