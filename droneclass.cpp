#include "droneclass.h"

#include <QDebug>
#include <QString>
#include <QStringList>
#include <cmath>



DroneClass::DroneClass(QObject *parent) :
    QObject(parent)
    , m_name("")
    , m_hardwareUid("")
    , m_role("")
    , m_xbeeID("")
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(-1)    // temporary
    , m_longitude(-1)   // temporary
    , m_altitude(-1)    // temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)    // temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_hardwareUid;
}


DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const QString &input_hardwareUid,
                       double input_batteryLevel,
                       double input_latitude,
                       double input_longitude,
                       double input_altitude,
                       QObject *parent)
    : QObject(parent)
    , m_name(input_name)
    , m_hardwareUid(input_hardwareUid)
    , m_role(input_role)
    , m_xbeeID(input_xbeeID)
    , m_batteryLevel(input_batteryLevel)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(input_latitude)
    , m_longitude(input_longitude)
    , m_altitude(input_altitude)
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)    // temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_hardwareUid;
}


DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const QString &input_hardwareUid,
                       QObject *parent)
    : QObject(parent)
    , m_name(input_name)
    , m_hardwareUid(input_hardwareUid)
    , m_role(input_role)
    , m_xbeeID(input_xbeeID)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(-1)
    , m_longitude(-1)
    , m_altitude(-1)
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)    // temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_hardwareUid;
}


void DroneClass::setName(const QString &inputName){
    if (m_name != inputName){
        m_name = inputName;
        emit nameChanged();
    }
}

void DroneClass::sethardwareUid(const QString &inputhardwareUid){
    if (m_hardwareUid != inputhardwareUid){
        m_hardwareUid = inputhardwareUid;
        emit hardwareUidChanged();
    }
}

void DroneClass::setRole(const QString &inputRole)
{
    if (m_role == inputRole) return;
    m_role = inputRole;
    emit roleChanged();
}

void DroneClass::setXbeeID(const QString &inputXbeeID)
{
    if (m_xbeeID == inputXbeeID) return;
    m_xbeeID = inputXbeeID;
    emit xbeeIDChanged();
}

void DroneClass::setBatteryLevel(double inputBatteryLevel)
{
    if (m_batteryLevel == inputBatteryLevel) return;
    m_batteryLevel = inputBatteryLevel;
    emit batteryChanged();
}

void DroneClass::setPosition(const QVector3D &pos)
{
    if (m_position == pos) return;
    m_position = pos;
    emit positionChanged();
}

void DroneClass::setLatitude(double lat)
{
    if (m_latitude == lat) return;
    m_latitude = lat;
    emit latitudeChanged();
}

void DroneClass::setLongitude(double longitude)
{
    if (m_longitude == longitude) return;
    m_longitude = longitude;
    emit longitudeChanged();
}

void DroneClass::setAltitude(double alt)
{
    if (m_altitude == alt) return;
    m_altitude = alt;
    emit altitudeChanged();
}

void DroneClass::setVelocity(const QVector3D &vel)
{
    if (m_velocity == vel) return;
    m_velocity = vel;
    emit velocityChanged();
}

void DroneClass::setAirspeed(double air)
{
    if (m_airspeed == air) return;
    m_airspeed = air;
    emit airspeedChanged();
}

void DroneClass::setOrientation(const QVector3D &ori)
{
    if (m_orientation == ori) return;
    m_orientation = ori;
    emit orientationChanged();
}

// ----- Adapters used by DroneController -----

void DroneClass::setConnected(bool v)
{
    if (m_connected == v) return;
    m_connected = v;
    emit dataChanged();
}

void DroneClass::setBatteryVoltage(int millivolts)
{
    // store as volts in existing batteryLevel to avoid UI changes
    setBatteryLevel(millivolts / 1000.0);
}

void DroneClass::setRoll(double r)
{
    if (std::abs(m_orientation.x() - r) < 1e-6) return;
    m_orientation.setX(r);
    emit orientationChanged();
    emit dataChanged();
}

void DroneClass::setPitch(double p)
{
    if (std::abs(m_orientation.y() - p) < 1e-6) return;
    m_orientation.setY(p);
    emit orientationChanged();
    emit dataChanged();
}

void DroneClass::setYaw(double y)
{
    if (std::abs(m_orientation.z() - y) < 1e-6) return;
    m_orientation.setZ(y);
    emit orientationChanged();
    emit dataChanged();
}

void DroneClass::setModeField(const QString& m)
{
    if (m_mode == m) return;
    m_mode = m;
    emit dataChanged();
}

void DroneClass::setModeField(const QString& field, const QVariant& value) {
    Q_UNUSED(field);          // keep for future field-specific handling
    setModeField(value.toString());
}


// ----- QML helpers -----

void DroneClass::setPosition(float x, float y, float z)
{
    setPosition(QVector3D(x, y, z));
}
void DroneClass::setVelocity(float x, float y, float z)
{
    setVelocity(QVector3D(x, y, z));
}
void DroneClass::setOrientation(float x, float y, float z)
{
    setOrientation(QVector3D(x, y, z));
}
