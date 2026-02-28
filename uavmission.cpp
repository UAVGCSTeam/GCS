#include "uavmission.h"
#include "DroneClass.h"

// ── Constructor ──────────────────────────────────────────────────────

UAVMission::UAVMission(DroneClass* uav, MissionType type)
    : m_uav(uav)
    , m_missionType(type)
    , m_numWaypoints(0)
    , m_creationTime(QDateTime::currentDateTime())
{
}

// ── Drone getters ────────────────────────────────────────────────────

DroneClass* UAVMission::getUAV() const
{
    return m_uav;
}

// Returns the xbeeAddress of the associated drone, used as the mission key
QString UAVMission::getUAVID() const
{
    if (!m_uav)
        return QString();
    return m_uav->getXbeeAddress();
}

// ── Mission type ─────────────────────────────────────────────────────

MissionType UAVMission::getMissionType() const
{
    return m_missionType;
}

// ── Waypoint getters ─────────────────────────────────────────────────

int UAVMission::getNumWaypoints() const
{
    return m_numWaypoints;
}

QList<Waypoint> UAVMission::getWaypoints() const
{
    return m_waypoints;
}

// ── Waypoint mutators ────────────────────────────────────────────────

void UAVMission::addWaypoint(const Waypoint& wp) 
{
    m_waypoints.append(wp);
    m_numWaypoints++;
}

void UAVMission::removeFirst()
{
    if (!m_waypoints.isEmpty()) {
        m_waypoints.removeFirst();
        m_numWaypoints--;
    }
}

void UAVMission::clearWaypoints()
{
    m_waypoints.clear();
    m_numWaypoints = 0;
}

// ── Mission timing ───────────────────────────────────────────────────

// Elapsed seconds since mission creation
float UAVMission::getRuntime() const
{
    return m_creationTime.msecsTo(QDateTime::currentDateTime()) / 1000.0f;
}
