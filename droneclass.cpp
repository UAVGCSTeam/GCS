#include "droneclass.h"

#include <QString>
#include <cmath>

DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeAddress,
                       QObject *parent) :
    QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
    , m_role(input_role)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_lattitude(-1) //temporary
    , m_longitude(-1) //temporary
    , m_altitude(-1)  //temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)  //temporary
    , m_orientation(QVector3D(-1, -1, -1))
{

}
void DroneClass::setName(const QString &inputName){
    if (m_name != inputName){
        m_name = inputName;
        emit nameChanged();
    }
}
void DroneClass::setXbeeAddress(const QString &inputXbeeAddress){
    if (m_xbeeAddress != inputXbeeAddress){
        m_xbeeAddress = inputXbeeAddress;
        emit xbeeAddressChanged();
    }
}
void DroneClass::setRole(const QString &inputRole){
    if (m_role != inputRole){
        m_role = inputRole;
        emit roleChanged();
    }
}
void DroneClass::setBatteryLevel(double inputBatteryLevel){
    if (m_batteryLevel != inputBatteryLevel){
        m_batteryLevel = inputBatteryLevel;
        emit batteryChanged();
    }
}
void DroneClass::setPosition(const QVector3D &pos){
    if (m_position != pos){
        m_position = pos;
        emit positionChanged();
    }
}
//temporary
void DroneClass::setLattitude(const double lat) {
    if (m_lattitude != lat) {
        m_lattitude = lat;
        emit lattitudeChanged();
    }
}
//temporary
void DroneClass::setLongitude(const double longitude) {
    if (m_longitude != longitude) {
        m_lattitude = longitude;
        emit longitudeChanged();
    }
}
//temporary
void DroneClass::setAltitude(const double alt) {
    if (m_altitude != alt) {
        m_altitude = alt;
        emit altitudeChanged();
    }
}
void DroneClass::setVelocity(const QVector3D &vel){
    if (m_velocity != vel){
        m_velocity = vel;
        emit velocityChanged();
    }
}
//temporary
void DroneClass::setAirspeed(const double air) {
    if (m_airspeed != air) {
        m_airspeed = air;
        emit airspeedChanged();
    }
}
void DroneClass::setOrientation(const QVector3D &ori){
    if (m_orientation != ori){
        m_orientation = ori;
        emit orientationChanged();
    }
}

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

