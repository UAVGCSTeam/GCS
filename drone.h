#ifndef DRONE_H
#define DRONE_H

#include <string>
// Not using namespace std, just for better C++ mem protection
// Seperating pybind and drone Class for now

// TODO: Check what needs to be constant, so values aren’t changing.
/**
 * @class drone
 * @brief Represents a drone drone with properties for identification,
 *        location, and status tracking.
 */
class drone {
public:
    /**
     * Default constructor.
     * Initializes a drone object with default values.
     */
    drone();

    /**
     * Parameterized constructor.
     * Initializes a drone object with specific values.
     * @param input_id The unique ICAO ID of the drone.
     * @param input_name The name assigned to the drone.
     * @param input_role The role or purpose of the drone.
     * @param input_remoteXbeeAddress The Xbee address for remote connection.
     */
    drone(const std::string &input_id, const std::string &input_name, const std::string &input_role, const std::string &input_remoteXbeeAddress);
    // Moved Vector List for drones to another class, drone Manager...
    /**
     * Destructor.
     * Cleans up any resources used by the drone object.
     */
    ~drone();

    /**
     * Checks if the Xbee module is connected.
     * @return True if connected, false otherwise.
     */
    bool checkIfXbeeConnected();

    // Setters and Getters
    /**
     * Updates the ICAO ID of the drone.
     * @param inputId New ID for the drone.
     */
    void updateID(const std::string &inputId) { ICAO_ID = inputId; }

    /**
     * Gets the ICAO ID of the drone.
     * @return The ICAO ID as a string.
     */
    std::string getID() const { return ICAO_ID; }

    /**
     * Updates the role of the drone.
     * @param inputRole New role assigned to the drone.
     */
    void updateRole(const std::string &inputRole) { role = inputRole; }

    /**
     * Gets the role of the drone.
     * @return The role as a string.
     */
    std::string getRole() const { return role; }

    /**
     * Updates the current status of the drone.
     * @param inputStatus New status of the drone.
     */
    void updateStatus(const std::string &inputStatus) { status = inputStatus; }

    /**
     * Gets the current status of the drone.
     * @return The status as a string.
     */
    std::string getStatus() const { return status; }

    /**
     * Updates the battery level of the drone.
     * @param inputBatteryLevel New battery level percentage.
     */
    void updateBatteryLevel(double inputBatteryLevel) { batteryLevel = inputBatteryLevel; }

    /**
     * Gets the current battery level of the drone.
     * @return The battery level as a double.
     */
    double getBatteryLevel() const { return batteryLevel; }

    /**
     * Updates the position of the drone.
     * @param longitude New longitude position.
     * @param latitude New latitude position.
     * @param altitude New altitude level.
     */
    void updatePosition(float longitude, float latitude, float altitude);

    /**
     * Gets the position of the drone.
     * @return A pointer to an array containing longitude, latitude, and altitude.
     */
    const float* getPosition() const { return position; }

    /**
     * Updates the velocity of the drone.
     * @param x Velocity along the x-axis.
     * @param y Velocity along the y-axis.
     * @param z Velocity along the z-axis.
     */
    void updateVelocity(float x, float y, float z);

    /**
     * Gets the velocity of the drone.
     * @return A pointer to an array containing x, y, and z velocity components.
     */
    const float* getVelocity() const { return velocity; }

    /**
     * Updates the orientation of the drone.
     * @param x Orientation along the x-axis.
     * @param y Orientation along the y-axis.
     * @param z Orientation along the z-axis.
     */
    void updateOrientation(float x, float y, float z);

    /**
     * Gets the orientation of the drone.
     * @return A pointer to an array containing x, y, and z orientation components.
     */
    const int* getOrientation() const { return orientation; }

    /**
     * Prints all information related to the drone for debugging or display.
     */
    void printAllDroneInfo();

private:
    std::string ICAO_ID;        /** Unique ID for the drone (ICAO ID). */
    std::string name;           /** Name of the drone. */
    std::string role;           /** Role or mission type of the drone. */
    std::string status;         /** Current status (offline, connected, armed, flying). */
    // TODO: For now I think status as string makes sense, but functionally I'm imagining a switch statement as a number should be shorter byte

    std::string remoteXbeeAddress; /** Address for remote Xbee connectivity. */
    double batteryLevel = -1;   /** Battery level, default -1 indicates no data. */
    float position[3] = {-1, -1, -1}; /** Position array: longitude, latitude, altitude. */
    float velocity[3] = {-1, -1, -1};   /** Velocity array: x, y, z components. */
    int orientation[3] = {-1, -1, -1}; /** Orientation array: x, y, z components. */
};

#endif // drone_H
