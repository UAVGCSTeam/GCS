#include "droneclass.h"

#include <QString>
#include <cmath>

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
void DroneClass::setVelocity(const QVector3D &vel){
    if (m_velocity != vel){
        m_velocity = vel;
        emit velocityChanged();
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

