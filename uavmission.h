#ifndef UAVMISSION_H
#define UAVMISSION_H

#include <QList>
#include <QDateTime>

class DroneClass; 

// Identifies what kind of operation a mission represents.
enum class MissionType {
    None,
    Waypoint,
    ReturnHome,
    // Survey,
    // Hover,
};

/*
 * Lightweight data container for a single waypoint coordinate.
 * Defined here so both UAVMission and MissionManager can use it
 * through a single include.
 */
struct Waypoint {
    double latitude = 0.0;
    double longitude = 0.0;

    Waypoint() = default;
    Waypoint(double lat, double lon) : latitude(lat), longitude(lon) {}
};

/*
 * Represents a single drone's active mission.
 * NOT a QObject -- this is a short-lived plain C++ class whose lifetime
 * matches the duration of a mission. Owned and managed by MissionManager.
 */
class UAVMission
{
public:
    explicit UAVMission(DroneClass* uav, MissionType type);

    // Drone getters
    DroneClass* getUAV() const;
    QString     getUAVID() const;

    // Mission type
    MissionType getMissionType() const;

    // Waypoint getters
    int                getNumWaypoints() const;
    QList<Waypoint>    getWaypoints() const;

    // Waypoint mutators
    void               addWaypoint(const Waypoint& wp);
    void               removeFirst();
    void               clearWaypoints();

    // Mission timing
    float       getRuntime() const;

private:
    DroneClass*     m_uav;            // non-owning pointer to the associated drone
    MissionType     m_missionType;    // set once at construction

    int             m_numWaypoints; 
    QList<Waypoint> m_waypoints; 

    QDateTime       m_creationTime;   // snapshot of when the mission was created
};

#endif // UAVMISSION_H
