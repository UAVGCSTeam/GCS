#ifndef MISSIONMANAGER_H
#define MISSIONMANAGER_H

#include <QObject>
#include <QMap>
#include <QDateTime>
#include <QVariantList>
#include <QStringList>
#include "uavmission.h"

class DroneClass;

/*
 * Central manager for all active drone missions.
 * Registered as a QML context property ("missionManager") so QML can
 * call its Q_INVOKABLE methods. Owns all UAVMission instances and is
 * responsible for their lifetime.
 *
 * Missions are keyed by the drone's xbeeAddress.
 */
class MissionManager : public QObject
{
    Q_OBJECT

public:
    explicit MissionManager(QObject* parent = nullptr);
    ~MissionManager();

    // Mission getters
    Q_INVOKABLE UAVMission* getMissionByUAVID(const QString& uavID) const;
    Q_INVOKABLE int         getNumMissions() const;
    Q_INVOKABLE float       getMissionRuntime(const QString& uavID) const;
    Q_INVOKABLE QStringList getMissionDroneIDs() const;
    Q_INVOKABLE QString     getDroneNameForMission(const QString& uavID) const;

    // Waypoint getters
    Q_INVOKABLE QVariantList getWaypoints(const QString& uavID) const;

    // Waypoint mutators
    Q_INVOKABLE bool        addWaypoint(DroneClass* drone, double lat, double lon);
    Q_INVOKABLE bool        pruneFirstWaypoint(const QString& uavID);
    Q_INVOKABLE bool        removeMission(const QString& uavID);

signals:
    // Emitted whenever waypoints are added, removed, or pruned for a drone
    void waypointsChanged(const QString& uavID);

private:
    QMap<QString, UAVMission*> m_missions;   // xbeeAddress -> active mission
    int                        m_numMissions;

    QDateTime                  m_creationTime;  // when MissionManager was instantiated
};

#endif // MISSIONMANAGER_H
