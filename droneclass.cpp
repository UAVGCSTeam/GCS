#include "droneclass.h"

#include <QDebug>
#include <QString>
#include <QStringList>
#include <cmath>



DroneClass::DroneClass(QObject *parent) :
    QObject(parent)
    , m_name("")
    , m_xbeeAddress("")
    , m_role("")
    , m_xbeeID("")
    , m_sysID(-1)
    , m_compID(-1)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(-1)    // temporary
    , m_longitude(-1)   // temporary
    , m_altitude(-1)    // temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)    // temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
}

DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeAddress,
                       QObject *parent)
    : QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
    , m_role(input_role)
    , m_xbeeID("")
    , m_sysID(-1)
    , m_compID(-1)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(-1)
    , m_longitude(-1)
    , m_altitude(-1)
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "addr:" << m_xbeeAddress;
}

DroneClass::DroneClass(const QString &input_name,
    // A: merge this with constructor B at some point
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const int &input_sysID,
                       const int &input_compID,
                       const QString &input_xbeeAddress,
                       QObject *parent)
    : QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
    , m_role(input_role)
    , m_xbeeID(input_xbeeID)
    , m_sysID(input_sysID)
    , m_compID(input_compID)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(34.059333) //temporary
    , m_longitude(-117.820611) //temporary
    , m_altitude(-1)  //temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)    // temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_xbeeAddress;
}


DroneClass::DroneClass(const QString &input_name,
    // B: merge this with constructor A at some point
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const QString &input_xbeeAddress,
                       QObject *parent)
    : QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
    , m_role(input_role)
    , m_xbeeID(input_xbeeID)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(34.059333) //temporary
    , m_longitude(-117.820611) //temporary
    , m_altitude(-1)  //temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)    // temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_xbeeAddress;
}



DroneClass::DroneClass(const QString &input_name,
    // DELETE ---- DEMO
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const int &input_sysID,
                       const int &input_compID,
                       const QString &input_xbeeAddress,
                       QObject *parent,
                       double batteryLevel,
                       double latitude,
                       double longitude,
                       double altitude)
    : QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
    , m_role(input_role)
    , m_xbeeID(input_xbeeID)
    , m_sysID(input_sysID)
    , m_compID(input_compID)
    , m_batteryLevel(batteryLevel)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(latitude) //temporary
    , m_longitude(longitude) //temporary
    , m_altitude(altitude)  //temporary
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)    // temporary
    , m_orientation(QVector3D(-1, -1, -1))
{
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_xbeeAddress;
}



void DroneClass::processXbeeMessage(const QString &message) {
    qDebug() << "Drone" << m_name << "received message:" << message;

    const QStringList lines = message.split('\n');

    for (const QString &lineRaw : lines) {
        const QString line = lineRaw.trimmed();

        if (line.startsWith("ICAO:")) {
            const QString icao = line.mid(5).trimmed();
            qDebug() << "ICAO:" << icao;
        }
        else if (line.startsWith("Latitude:") || line.startsWith("Lattitude:")) {
            const QString valueStr = line.contains("Lattitude:")
            ? line.mid(11).trimmed()   // Lattitude:
            : line.mid(10).trimmed();  // Latitude:
            const double latitude = valueStr.toDouble();
            setLatitude(latitude);
            qDebug() << "Updated latitude:" << latitude;
        }
        else if (line.startsWith("Longitude:")) {
            const double longitude = line.mid(10).trimmed().toDouble();
            setLongitude(longitude);
            qDebug() << "Updated longitude:" << longitude;
        }
        else if (line.startsWith("Altitude:")) {
            const double altitude = line.mid(9).trimmed().toDouble();
            setAltitude(altitude);
            qDebug() << "Updated altitude:" << altitude;
        }
        else if (line.startsWith("Velocity:")) {
            QString velocityStr = line.mid(9).trimmed();
            if (velocityStr.startsWith('[') && velocityStr.endsWith(']')) {
                velocityStr = velocityStr.mid(1, velocityStr.size() - 2);
                const QStringList comps = velocityStr.split(',');
                if (comps.size() >= 3) {
                    const float vx = comps[0].trimmed().toFloat();
                    const float vy = comps[1].trimmed().toFloat();
                    const float vz = comps[2].trimmed().toFloat();
                    setVelocity(vx, vy, vz);
                    qDebug() << "Updated velocity:" << vx << vy << vz;
                }
            }
        }
        else if (line.startsWith("Airspeed:")) {
            const double airspeed = line.mid(9).trimmed().toDouble();
            setAirspeed(airspeed);
            qDebug() << "Updated airspeed:" << airspeed;
        }
        else if (line.startsWith("Battery Level:")) {
            const double batteryLevel = line.mid(14).trimmed().toDouble();
            setBatteryLevel(batteryLevel);
            qDebug() << "Updated battery level:" << batteryLevel;
        }
    }

    // Position vector as (lon, lat, alt) to match your current map usage
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

void DroneClass::setSysID(const int &inputSysID)
{
    if (m_sysID == inputSysID) return;
    m_sysID = inputSysID;
    emit sysIDChanged();
}

void DroneClass::setCompID(const int &inputCompID)
{
    if (m_compID == inputCompID) return;
    m_compID = inputCompID;
    emit compIDChanged();
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
