//test drone class

#include <QtTest/QTest>
#include <QObject>

#include "../DroneClass.h"

class TestDroneClass : public QObject
{
    Q_OBJECT
    private slots:
        void constructors();
        void getNameAndSetName();
        void getXbeeAddressAndSetXbeeAddress();
        void getRoleAndSetRole();
        void getXbeeIDAndSetXbeeID();
        void getBatteryLevelAndSetBatteryLevel();
        void getPositionAndSetPosition();
        void getVelocityAndSetVelocity();
        void getOrientationAndSetOrientation();
        void getLatitudeAndSetLatitude();
        void getLongitudeAndSetLongitude();
        void getAltitudeAndSetAltitude();
        void getAirspeedAndSetAirspeed();
        void getConnectionAndSetConnected();
        void getStatusAndSetStatus();
        void getRequestedTelemAndSetRequestedTelem();
        void getSysIDAndSetSysID();
        void getCompIDAndSetCompID();
        void getUdpPortAndSetUdpPort();
};

void TestDroneClass::constructors()
{
    DroneClass drone1("Golf",
                     "Tracker",
                     "XBEE07",
                     "ADDR07",
                     50.0,
                     40.0,
                     -123.0,
                     400.0,
                     nullptr);

    /*
    This constructor is used for creating drones based off information
    that is stored persistently in the database.
    */
    DroneClass drone2("Golf",
                     "Tracker",
                     "XBEE07",
                     "ADDR07");//rest use automatic values

    //names
    const QString name1 = drone1.getName();
    const QString name2 = drone2.getName();
    QVERIFY(name1 == "Golf");
    QVERIFY(name2 == "Golf");

    //roles
    const QString role1 = drone1.getRole();
    const QString role2 = drone2.getRole();
    QVERIFY(role1 == "Tracker");
    QVERIFY(role2 == "Tracker");

    //xbee id
    const QString id1 = drone1.getXbeeID();
    const QString id2 = drone2.getXbeeID();
    QVERIFY(id1 == "XBEE07");
    QVERIFY(id2 == "XBEE07");

    //xbee address
    const QString addr1 = drone1.getXbeeAddress();
    const QString addr2 = drone2.getXbeeAddress();
    QVERIFY(addr1 == "ADDR07");
    QVERIFY(addr2 == "ADDR07");

    //sys id
    QVERIFY(drone1.getSysID() == 0);
    QVERIFY(drone2.getSysID() == 0);

    //comp id
    QVERIFY(drone1.getCompID() == 0);
    QVERIFY(drone2.getCompID() == 0);

    //input port
    QVERIFY(drone1.getUdpPort() == -1);
    QVERIFY(drone2.getUdpPort() == -1);
}

void TestDroneClass::getNameAndSetName()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QString name = "Drone1";
    drone1.setName(name);

    QVERIFY(drone1.getName() == name);

}

void TestDroneClass::getXbeeAddressAndSetXbeeAddress()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QString xbee = "ADDR01";
    drone1.setXbeeAddress(xbee);

    QVERIFY(drone1.getXbeeAddress() == xbee);
}

void TestDroneClass::getXbeeIDAndSetXbeeID()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QString xbee = "XBEE01";
    drone1.setXbeeID(xbee);

    QVERIFY(drone1.getXbeeID() == xbee);
}

void TestDroneClass::getRoleAndSetRole()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QString role = "Drone";
    drone1.setRole(role);

    QVERIFY(drone1.getRole() == role);
}

void TestDroneClass::getBatteryLevelAndSetBatteryLevel()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    double battery = 0.5;
    drone1.setBatteryLevel(battery);

    QVERIFY(drone1.getBatteryLevel() == battery);
}

void TestDroneClass::getPositionAndSetPosition()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QVector3D pos(15.0f, 15.0f, 15.0f);
    drone1.setPosition(pos);

    QVERIFY(drone1.getPosition() == pos);
}

void TestDroneClass::getVelocityAndSetVelocity()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QVector3D velocity(6.0f, 7.0f, 8.0f);
    drone1.setVelocity(velocity);

    QVERIFY(drone1.getVelocity() == velocity);
}

void TestDroneClass::getOrientationAndSetOrientation()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QVector3D orientation(1.0f, 1.0f, 1.0f);
    drone1.setOrientation(orientation);

    QVERIFY(drone1.getOrientation() == orientation);
}

void TestDroneClass::getLatitudeAndSetLatitude()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    double latitude = 1.0f;
    drone1.setLatitude(latitude);

    QVERIFY(drone1.getLatitude() == latitude);
}

void TestDroneClass::getLongitudeAndSetLongitude()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    double longitude = 1.0f;
    drone1.setLongitude(longitude);

    QVERIFY(longitude);
}

void TestDroneClass::getAltitudeAndSetAltitude()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    double altitude = 1.0f;
    drone1.setAltitude(altitude);

    QVERIFY(drone1.getAltitude() == altitude);
}

void TestDroneClass::getAirspeedAndSetAirspeed()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    double airspeed = 1.0f;
    drone1.setAirspeed(airspeed);

    QVERIFY(drone1.getAirspeed() == airspeed);
}

void TestDroneClass::getConnectionAndSetConnected()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    bool connected = false;
    drone1.setConnected(connected);

    QVERIFY(drone1.getConnection() == connected);
}

void TestDroneClass::getStatusAndSetStatus()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    QString status = "Flying";
    drone1.setStatus(status);

    QVERIFY(drone1.getStatus() == status);
}

void TestDroneClass::getRequestedTelemAndSetRequestedTelem()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    bool req = true;
    drone1.setRequestedTelem(req);

    QVERIFY(drone1.getRequestedTelem() == req);
}

void TestDroneClass::getSysIDAndSetSysID()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    int sys = 0;
    drone1.setSysID(sys);

    QVERIFY(drone1.getSysID() == sys);
}

void TestDroneClass::getCompIDAndSetCompID()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    int comp = 0;
    drone1.setCompID(comp);

    QVERIFY(drone1.getCompID() == comp);
}

void TestDroneClass::getUdpPortAndSetUdpPort()
{
    DroneClass drone1("Golf", "Tracker", "XBEE07", "ADDR07", 50.0, 40.0, -123.0, 400.0, nullptr);

    int udp = -1;
    drone1.setUdpPort(udp);

    QVERIFY(drone1.getUdpPort() == udp);
}

QTEST_MAIN(TestDroneClass)
#include "test_droneclass.moc"
