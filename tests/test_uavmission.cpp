// test_uavmission.cpp

#include <QtTest/QtTest>
#include <QObject>
#include "../uavmission.h"
#include "../DroneClass.h"

class TestUAVMission : public QObject
{
    Q_OBJECT

private slots:
    void constructor_initializesFields();
    void getUAV_and_getUAVID_withValidDrone();
    void getUAVID_returnsEmptyString_whenDroneIsNull();
    void addWaypoint_increasesCount_andPreservesOrder();
    void removeFirst_removesOldestWaypoint();
    void removeFirst_onEmptyMission_doesNothing();
    void clearWaypoints_emptiesMission_andResetsCount();
    void getWaypoints_returnsCopy_notReference();
    void runtime_isNonNegative_andIncreasesOverTime();
};

void TestUAVMission::constructor_initializesFields()
{
    DroneClass drone("TestDrone",
                     "Scout",
                     "XBEE01",
                     "ADDR01",
                     95.0,
                     34.0,
                     -117.0,
                     1000.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::Waypoint);

    QCOMPARE(mission.getUAV(), &drone);
    QCOMPARE(mission.getUAVID(), QString("ADDR01"));
    QCOMPARE(mission.getMissionType(), MissionType::Waypoint);
    QCOMPARE(mission.getNumWaypoints(), 0);
    QVERIFY(mission.getWaypoints().isEmpty());

    // Runtime should never start negative.
    QVERIFY(mission.getRuntime() >= 0.0f);
}

void TestUAVMission::getUAV_and_getUAVID_withValidDrone()
{
    DroneClass drone("Alpha",
                     "Leader",
                     "XBEE99",
                     "DRONE_ADDR_99",
                     80.0,
                     33.5,
                     -117.8,
                     1200.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::ReturnHome);

    QCOMPARE(mission.getUAV(), &drone);
    QCOMPARE(mission.getUAVID(), QString("DRONE_ADDR_99"));
    QCOMPARE(mission.getMissionType(), MissionType::ReturnHome);
}

void TestUAVMission::getUAVID_returnsEmptyString_whenDroneIsNull()
{
    UAVMission mission(nullptr, MissionType::None);

    QCOMPARE(mission.getUAV(), nullptr);
    QVERIFY(mission.getUAVID().isEmpty());
    QCOMPARE(mission.getMissionType(), MissionType::None);
    QCOMPARE(mission.getNumWaypoints(), 0);
}

void TestUAVMission::addWaypoint_increasesCount_andPreservesOrder()
{
    DroneClass drone("Bravo",
                     "Support",
                     "XBEE02",
                     "ADDR02",
                     75.0,
                     35.0,
                     -118.0,
                     900.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::Waypoint);

    Waypoint wp1(34.1001, -117.2001);
    Waypoint wp2(34.1002, -117.2002);
    Waypoint wp3(34.1003, -117.2003);

    mission.addWaypoint(wp1);
    mission.addWaypoint(wp2);
    mission.addWaypoint(wp3);

    QCOMPARE(mission.getNumWaypoints(), 3);

    const QList<Waypoint> waypoints = mission.getWaypoints();
    QCOMPARE(waypoints.size(), 3);

    QCOMPARE(waypoints[0].latitude,  wp1.latitude);
    QCOMPARE(waypoints[0].longitude, wp1.longitude);
    QCOMPARE(waypoints[1].latitude,  wp2.latitude);
    QCOMPARE(waypoints[1].longitude, wp2.longitude);
    QCOMPARE(waypoints[2].latitude,  wp3.latitude);
    QCOMPARE(waypoints[2].longitude, wp3.longitude);
}

void TestUAVMission::removeFirst_removesOldestWaypoint()
{
    DroneClass drone("Charlie",
                     "Wingman",
                     "XBEE03",
                     "ADDR03",
                     70.0,
                     36.0,
                     -119.0,
                     800.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::Waypoint);

    Waypoint wp1(1.0, 2.0);
    Waypoint wp2(3.0, 4.0);
    Waypoint wp3(5.0, 6.0);

    mission.addWaypoint(wp1);
    mission.addWaypoint(wp2);
    mission.addWaypoint(wp3);

    mission.removeFirst();

    QCOMPARE(mission.getNumWaypoints(), 2);

    const QList<Waypoint> waypoints = mission.getWaypoints();
    QCOMPARE(waypoints.size(), 2);

    // Old first waypoint should be gone.
    QCOMPARE(waypoints[0].latitude,  wp2.latitude);
    QCOMPARE(waypoints[0].longitude, wp2.longitude);
    QCOMPARE(waypoints[1].latitude,  wp3.latitude);
    QCOMPARE(waypoints[1].longitude, wp3.longitude);
}

void TestUAVMission::removeFirst_onEmptyMission_doesNothing()
{
    DroneClass drone("Delta",
                     "Scout",
                     "XBEE04",
                     "ADDR04",
                     65.0,
                     37.0,
                     -120.0,
                     700.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::Waypoint);

    mission.removeFirst();

    QCOMPARE(mission.getNumWaypoints(), 0);
    QVERIFY(mission.getWaypoints().isEmpty());
}

void TestUAVMission::clearWaypoints_emptiesMission_andResetsCount()
{
    DroneClass drone("Echo",
                     "Relay",
                     "XBEE05",
                     "ADDR05",
                     60.0,
                     38.0,
                     -121.0,
                     600.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::Waypoint);

    mission.addWaypoint(Waypoint(10.0, 20.0));
    mission.addWaypoint(Waypoint(30.0, 40.0));

    QCOMPARE(mission.getNumWaypoints(), 2);
    QVERIFY(!mission.getWaypoints().isEmpty());

    mission.clearWaypoints();

    QCOMPARE(mission.getNumWaypoints(), 0);
    QVERIFY(mission.getWaypoints().isEmpty());
}

void TestUAVMission::getWaypoints_returnsCopy_notReference()
{
    DroneClass drone("Foxtrot",
                     "Observer",
                     "XBEE06",
                     "ADDR06",
                     55.0,
                     39.0,
                     -122.0,
                     500.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::Waypoint);
    mission.addWaypoint(Waypoint(11.0, 22.0));

    QList<Waypoint> localCopy = mission.getWaypoints();
    QCOMPARE(localCopy.size(), 1);

    // Modify the local copy only.
    localCopy[0].latitude = 999.0;
    localCopy[0].longitude = 888.0;
    localCopy.append(Waypoint(77.0, 66.0));

    // Internal mission state should remain unchanged.
    const QList<Waypoint> missionWaypoints = mission.getWaypoints();
    QCOMPARE(mission.getNumWaypoints(), 1);
    QCOMPARE(missionWaypoints.size(), 1);
    QCOMPARE(missionWaypoints[0].latitude, 11.0);
    QCOMPARE(missionWaypoints[0].longitude, 22.0);
}

void TestUAVMission::runtime_isNonNegative_andIncreasesOverTime()
{
    DroneClass drone("Golf",
                     "Tracker",
                     "XBEE07",
                     "ADDR07",
                     50.0,
                     40.0,
                     -123.0,
                     400.0,
                     nullptr);

    UAVMission mission(&drone, MissionType::Waypoint);

    const float t1 = mission.getRuntime();
    QVERIFY(t1 >= 0.0f);

    QTest::qSleep(50);

    const float t2 = mission.getRuntime();
    QVERIFY(t2 >= t1);
    QVERIFY(t2 > 0.0f);
}

QTEST_MAIN(TestUAVMission)
#include "test_uavmission.moc"
