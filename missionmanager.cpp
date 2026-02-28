#include "missionmanager.h"
#include "DroneClass.h"
#include <QDebug>

// ── Constructor / Destructor ─────────────────────────────────────────

MissionManager::MissionManager(QObject* parent)
    : QObject(parent)
    , m_numMissions(0)
    , m_creationTime(QDateTime::currentDateTime())
{
}

MissionManager::~MissionManager()
{
    qDeleteAll(m_missions);   // free every UAVMission* we made in addWaypoint()
    m_missions.clear();       // remove the now-dangling map entries
}

// ── Mission getters ──────────────────────────────────────────────────

UAVMission* MissionManager::getMissionByUAVID(const QString& uavID) const
{
    return m_missions.value(uavID, nullptr);
}

int MissionManager::getNumMissions() const
{
    return m_numMissions;
}

float MissionManager::getMissionRuntime(const QString& uavID) const
{
    UAVMission* mission = m_missions.value(uavID, nullptr);  // find existing mission or null
    if (!mission)
        return -1.0f;
    return mission->getRuntime();
}

QStringList MissionManager::getMissionDroneIDs() const
{
    return m_missions.keys();
}

// Translates xbeeAddress -> drone display name (needed because DroneController
// keys its waypoint hash by drone name, not xbeeAddress)
QString MissionManager::getDroneNameForMission(const QString& uavID) const
{
    UAVMission* mission = m_missions.value(uavID, nullptr);
    if (!mission || !mission->getUAV()) {
        qWarning() << "[MissionManager] getDroneNameForMission: no mission for" << uavID;
        return QString();
    }
    return mission->getUAV()->getName();
}

// ── Waypoint getters ─────────────────────────────────────────────────

// Converts Waypoint structs into QVariantList of {lat, lon} maps for QML
QVariantList MissionManager::getWaypoints(const QString& uavID) const
{
    QVariantList result;
    UAVMission* mission = m_missions.value(uavID, nullptr);  // find existing mission or null
    if (!mission)
        return result;

    for (const Waypoint& wp : mission->getWaypoints()) {
        QVariantMap entry;
        entry["lat"] = wp.latitude;
        entry["lon"] = wp.longitude;
        result.append(entry);
    }
    return result;
}

// ── Waypoint mutators ────────────────────────────────────────────────

/*
 * Adds a waypoint to a drone's mission. If no mission exists yet for this
 * drone, one is created automatically and the drone's current position is
 * inserted as the first waypoint (the "origin") before the clicked waypoint.
 */
bool MissionManager::addWaypoint(DroneClass* drone, double lat, double lon)
{
    if (!drone) {
        qWarning() << "[MissionManager] addWaypoint called with null drone";
        return false;
    }

    QString id = drone->getXbeeAddress();
    UAVMission* mission = m_missions.value(id, nullptr);  // find existing mission or null

    if (!mission) {
        mission = new UAVMission(drone, MissionType::Waypoint);
        m_missions.insert(id, mission);
        m_numMissions++;
        mission->addWaypoint(Waypoint(drone->getLatitude(), drone->getLongitude()));
        qDebug() << "[MissionManager] New mission created:"
                 << drone->getName() << "(xbee:" << id << ")"
                 << "| origin:" << drone->getLatitude() << drone->getLongitude()
                 << "| active missions:" << m_numMissions;
    }

    mission->addWaypoint(Waypoint(lat, lon));
    qDebug() << "[MissionManager] Waypoint added:" << drone->getName()
             << "(xbee:" << id << ")"
             << "| wp(" << lat << "," << lon << ")"
             << "| total waypoints:" << mission->getNumWaypoints();
    emit waypointsChanged(id);
    return true;
}

// Removes the origin waypoint once the drone reaches the next target,
// so the next waypoint naturally becomes the new origin (index 0).
bool MissionManager::pruneFirstWaypoint(const QString& uavID)
{
    UAVMission* mission = m_missions.value(uavID, nullptr);  // find existing mission or null
    if (!mission || mission->getNumWaypoints() < 2)
        return false;

    mission->removeFirst();
    qDebug() << "[MissionManager] Pruned first waypoint:" << getDroneNameForMission(uavID)
             << "(xbee:" << uavID << ")"
             << "| remaining:" << mission->getNumWaypoints();

    if (mission->getNumWaypoints() <= 1) {
        return removeMission(uavID);
    }

    emit waypointsChanged(uavID);
    return true;
}

bool MissionManager::removeMission(const QString& uavID)
{
    UAVMission* mission = m_missions.value(uavID, nullptr);  // find existing mission or null
    if (!mission)
        return false;

    QString name = mission->getUAV() ? mission->getUAV()->getName() : uavID;
    float runtime = mission->getRuntime();
    m_missions.remove(uavID);
    delete mission;
    m_numMissions--;
    qDebug() << "[MissionManager] Mission removed:" << name
             << "(xbee:" << uavID << ")"
             << "| runtime:" << runtime << "s"
             << "| active missions:" << m_numMissions;
    emit waypointsChanged(uavID);
    return true;
}
