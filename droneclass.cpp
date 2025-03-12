#include "droneclass.h"

#include <QString>
#include <cmath>

static QString selectedDroneName;

DroneClass::DroneClass(QObject *parent) :
    QObject(parent)
    , m_name("")
    , m_xbeeAddress("")
    , m_role("")
    , m_batteryLevel(-1)
    , m_position(QVector3D(34, -117, 25)) //temporarily set to readable data
    , m_velocity(QVector3D(4.5, -3.7, 4.1)) //temporarily set to readable data
    , m_orientation(QVector3D(-1, -1, -1))
{

}

DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeAddress,
                       QObject *parent) :
    QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
    , m_role(input_role)
    , m_batteryLevel(-1)
    , m_position(QVector3D(34, -117, 25)) //temporarily set to readable data
    , m_velocity(QVector3D(4.5, -3.7, 4.1)) //temporarily set to readable data
    , m_orientation(QVector3D(-1, -1, -1))
{

}

void DroneClass::setName(const QString &inputName){
    if (m_name != inputName){
        m_name = inputName;
        if (this->getName() == selectedDroneName) {
            emit nameChanged();
        }
    }
}
void DroneClass::setXbeeAddress(const QString &inputXbeeAddress){
    if (m_xbeeAddress != inputXbeeAddress){
        m_xbeeAddress = inputXbeeAddress;
        if (this->getName() == selectedDroneName) {
            emit xbeeAddressChanged();
        }
    }
}
void DroneClass::setRole(const QString &inputRole){
    if (m_role != inputRole){
        m_role = inputRole;
        if (this->getName() == selectedDroneName) {
            emit roleChanged();
        }
    }
}
void DroneClass::setBatteryLevel(double inputBatteryLevel){
    if (m_batteryLevel != inputBatteryLevel){
        m_batteryLevel = inputBatteryLevel;
        if (this->getName() == selectedDroneName) {
            emit batteryChanged();
        }
    }
}
void DroneClass::setPosition(const QVector3D &pos){
    if (m_position != pos){
        m_position = pos;
        if (this->getName() == selectedDroneName) {
            emit positionChanged();
        }
    }
}

//temporary
void DroneClass::setLattitude(const double &lat) {
    if (m_lattitude != lat) {
        m_lattitude = lat;
        if (this->getName() == selectedDroneName) {
            emit lattitudeChanged();
        }
    }
}
//temporary
void DroneClass::setLongitude(const double &lon) {
    if (m_longitude != lon) {
        m_longitude = lon;
        if (this->getName() == selectedDroneName) {
            emit longitudeChanged();
        }
    }
}

void DroneClass::setVelocity(const QVector3D &vel){
    if (m_velocity != vel){
        m_velocity = vel;
        if (this->getName() == selectedDroneName) {
            emit velocityChanged();
        }
    }
}
void DroneClass::setOrientation(const QVector3D &ori){
    if (m_orientation != ori){
        m_orientation = ori;
        if (this->getName() == selectedDroneName) {
            emit orientationChanged();
        }
    }
}

// Static variable to keep track which drone is selected
void updateSelectedDroneName(QString droneName) {
    selectedDroneName = droneName;
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

