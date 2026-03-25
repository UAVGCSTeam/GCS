//test drone class

#include <QtTest/QTest>
#include <QObject>

#include "../DroneClass.h"

class TestDroneClass : public QObject
{
    Q_OBJECT
    private slots:
        void constructors();
        /*void getNameAndSetName();
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
        void getUdpPortAndSetUdpPort();*/
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
}

QTEST_MAIN(TestDroneClass)
#include "test_droneclass.moc"
