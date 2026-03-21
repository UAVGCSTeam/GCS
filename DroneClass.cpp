#include "DroneClass.h"



DroneClass::DroneClass(QObject *parent) :
    QObject(parent)
    , m_name("")
    , m_xbeeAddress("")
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
    , m_udp(-1)
{
    startHeartBeatTimer();
    updateStatus();
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_xbeeAddress;
}


DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const QString &input_xbeeAddress,
                       double input_batteryLevel,
                       double input_latitude,
                       double input_longitude,
                       double input_altitude,
                       QObject *parent)
    : QObject(parent)
    , m_name(input_name)
    , m_xbeeAddress(input_xbeeAddress)
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
    , m_udp(-1)
{
    startHeartBeatTimer();
    updateStatus();
    qDebug() << "Created drone:" << m_name << "with ID:" << m_xbeeID << "and address:" << m_xbeeAddress;
}


DroneClass::DroneClass(const QString &input_name,
                       const QString &input_role,
                       const QString &input_xbeeID,
                       const QString &input_xbeeAddress,
                       const uint8_t &input_sysID,
                       const uint8_t &input_compID, 
                       int input_udpPort,
                       QObject *parent)
    : QObject(parent)
    , m_name(input_name)
    , m_sysID(input_sysID)
    , m_compID(input_compID)
    , m_xbeeAddress(input_xbeeAddress)
    , m_role(input_role)
    , m_xbeeID(input_xbeeID)
    , m_batteryLevel(-1)
    , m_position(QVector3D(-1, -1, -1))
    , m_latitude(-1)
    , m_longitude(-1)
    , m_altitude(-1)
    , m_velocity(QVector3D(-1, -1, -1))
    , m_airspeed(-1)
    , m_orientation(QVector3D(-1, -1, -1))
    , m_udp(input_udpPort)
{
    startHeartBeatTimer();
    updateStatus();

    // If xbeeAddress is not provided, auto-generate a 2-digit value.
    if (m_xbeeAddress == "-1") {
        const int xbeeAddressNum = QRandomGenerator::global()->bounded(10, 100); // [10, 99]
        m_xbeeAddress = QString::number(xbeeAddressNum);
    }

    qDebug() << "Created drone:" 
        << m_name 
        << "with ID:" << m_xbeeID 
        << "and address:" << m_xbeeAddress
        << "and sysID:" << m_sysID
        << "and compID:" << m_compID;
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
    updateStatus();
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

// ----- Heartbeat ------

void DroneClass::checkHeartbeat()
{
    QDateTime curTime = QDateTime::currentDateTime();
    qint64 dTime = m_lastHeartBeat.msecsTo(curTime);

    if(dTime > 1000 && m_connected)
    {
        setConnected(false);
        // qDebug() d<< m_name << " Disconnected";
    }

    // qDebug() << "Connection Status for " << m_name << ": " << m_connected;
}

void DroneClass::startHeartBeatTimer()
{
    //set current time
    m_lastHeartBeat = QDateTime::currentDateTime();

    //connect timer
    connect(&m_heartBeatTimer, &QTimer::timeout, this, &DroneClass::checkHeartbeat);
    m_heartBeatTimer.start(500); // check every half second
}

// ----- Adapters used by DroneController -----

void DroneClass::setConnected(bool v)
{
    if(v)
    {
        QDateTime curTime = QDateTime::currentDateTime();
        m_heartbeatIntervalMs = m_lastHeartBeat.msecsTo(curTime);
        m_lastHeartBeat = curTime;
    }

    if (m_connected == v) return;
    
    m_connected = v;
    emit dataChanged();
    emit connectionStatusChanged(m_connected);
    updateStatus();
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

void DroneClass::updateStatus()
{
    QString newStatus;

    // Basic rule:
    //  - If connected and altitude > 0.2 m  -> "Flying"
    //  - Else if connected                 -> "Connected"
    //  - Else                              -> "Not Connected"
    if (m_connected && m_altitude > 0.2) {
        newStatus = QStringLiteral("Flying");
    } else if (m_connected) {
        newStatus = QStringLiteral("Connected");
    } else {
        newStatus = QStringLiteral("Not Connected");
    }

    if (m_status == newStatus)
        return;

    m_status = newStatus;
    emit statusChanged();
    emit dataChanged();
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
