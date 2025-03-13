#include "droneclass.h"

#include <QString>
#include <QDebug>
#include <cmath>

DroneClass::DroneClass(QObject *parent) :
    QObject(parent)
    , m_name("")
    , m_xbeeAddress("")
    , m_role("")
    , m_xbeeID("")
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(-1) //temporary
    , m_longitude(-1) //temporary
    , m_altitude(-1)  //temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)  //temporary
    , m_orientation(QVector3D(-1, -1, -1))
{

}

DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const QString &input_xbeeAddress,
                       QObject *parent) :
    QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
    , m_xbeeID(input_xbeeID)
    , m_role(input_role)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(-1) //temporary
    , m_longitude(-1) //temporary
    , m_altitude(-1)  //temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)  //temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_xbeeAddress;
}
void DroneClass::processXbeeMessage(const QString &message) {
    qDebug() << "Drone" << m_name << "received message:" << message;

    // Split the message by newlines to get each data field
    QStringList lines = message.split('\n');

    for (const QString &lineRaw : lines) {
        QString line = lineRaw.trimmed();

        if (line.startsWith("ICAO:")) {
            // Process ICAO identifier if needed
            QString icao = line.mid(5).trimmed();
            qDebug() << "ICAO:" << icao;
        }
        // Bc we have a misspelling somewhere or something idk, just look for both ig
        else if (line.startsWith("Latitude:") || line.startsWith("Lattitude:")) {
            // Handle both spellings
            QString valueStr = line.contains("Lattitude:") ?
                                   line.mid(11).trimmed() : // for Lattitude:
                                   line.mid(10).trimmed();  // for Latitude:
            double latitude = valueStr.toDouble();
            setLatitude(latitude);
            qDebug() << "Updated latitude:" << latitude;
        }
        else if (line.startsWith("Longitude:")) {
            double longitude = line.mid(10).trimmed().toDouble();
            setLongitude(longitude);
            qDebug() << "Updated longitude:" << longitude;
        }
        else if (line.startsWith("Altitude:")) {
            double altitude = line.mid(9).trimmed().toDouble();
            setAltitude(altitude);
            qDebug() << "Updated altitude:" << altitude;
        }
        else if (line.startsWith("Velocity:")) {
            QString velocityStr = line.mid(9).trimmed();

            // Parse the [x, y, z] format
            if (velocityStr.startsWith("[") && velocityStr.endsWith("]")) {
                velocityStr = velocityStr.mid(1, velocityStr.length() - 2);
                QStringList velComponents = velocityStr.split(",");
                if (velComponents.size() >= 3) {
                    float vx = velComponents[0].trimmed().toFloat();
                    float vy = velComponents[1].trimmed().toFloat();
                    float vz = velComponents[2].trimmed().toFloat();
                    setVelocity(vx, vy, vz);
                    qDebug() << "Updated velocity:" << vx << vy << vz;
                }
            }
        }
        else if (line.startsWith("Airspeed:")) {
            double airspeed = line.mid(9).trimmed().toDouble();
            setAirspeed(airspeed);
            qDebug() << "Updated airspeed:" << airspeed;
        }
        else if (line.startsWith("Battery Level:")) {
            double batteryLevel = line.mid(14).trimmed().toDouble();
            setBatteryLevel(batteryLevel);
            qDebug() << "Updated battery level:" << batteryLevel;
        }
    }

    // After updating individual coordinates, also update the position vector
    setPosition(m_longitude, m_latitude, m_altitude);
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
void DroneClass::setXbeeID(const QString &inputXbeeID){
    if (m_xbeeID != inputXbeeID){
        m_xbeeID = inputXbeeID;
        emit xbeeIDChanged();
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
void DroneClass::setLatitude(const double lat) {
    if (m_latitude != lat) {
        m_latitude = lat;
        emit latitudeChanged();
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

