#ifndef DRONECLASS_H
#define DRONECLASS_H

#include <QObject>
#include <QString>
#include <QVector3D>
#include <QVector>
#include <QVariant>
#include <QStringList>
#include <QDebug>
#include <cmath>


#include "Serialization.h"

class DroneClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString   name        READ getName        NOTIFY nameChanged        FINAL)
    Q_PROPERTY(QString   xbeeAddress READ getXbeeAddress NOTIFY xbeeAddressChanged FINAL)
    Q_PROPERTY(double    batteryLevel READ getBatteryLevel NOTIFY batteryChanged  FINAL)
    Q_PROPERTY(QString   role        READ getRole        NOTIFY roleChanged        FINAL)
    Q_PROPERTY(QString   xbeeID      READ getXbeeID      NOTIFY xbeeIDChanged      FINAL)
    Q_PROPERTY(QVector3D position    READ getPosition    NOTIFY positionChanged    FINAL)
    Q_PROPERTY(double    latitude    READ getLatitude    NOTIFY latitudeChanged    FINAL)
    Q_PROPERTY(double    longitude   READ getLongitude   NOTIFY longitudeChanged   FINAL)
    Q_PROPERTY(double    altitude    READ getAltitude    NOTIFY altitudeChanged    FINAL)
    Q_PROPERTY(QVector3D velocity    READ getVelocity    NOTIFY velocityChanged    FINAL)
    Q_PROPERTY(double    airspeed    READ getAirspeed    NOTIFY airspeedChanged    FINAL)
    Q_PROPERTY(QVector3D orientation READ getOrientation NOTIFY orientationChanged FINAL)

public:
    explicit DroneClass(QObject *parent = nullptr);

    DroneClass(const QString &input_name,
               const QString &input_role,
               const QString &input_xbeeID,
               const QString &input_xbeeAddress,
               double input_batteryLevel,
               double input_latitude,
               double input_longitude,
               double input_altitude,
               QObject *parent);

    /*
    This constructor is used for creating drones based off information
    that is stored persistently in the database.
    */
    DroneClass(const QString &input_name,
               const QString &input_role,
               const QString &input_xbeeID,
               const QString &input_xbeeAddress,
               QObject *parent = nullptr);

    // Getters/Setters used by Q_PROPERTY
    QString   getName()        const { return m_name; }
    void      setName(const QString &inputName);

    QString   getXbeeAddress() const { return m_xbeeAddress; }
    void      setXbeeAddress(const QString &inputXbeeAddress);

    QString   getRole()        const { return m_role; }
    void      setRole(const QString &inputRole);

    QString   getXbeeID()      const { return m_xbeeID; }
    void      setXbeeID(const QString &inputXbeeID);

    double    getBatteryLevel() const { return m_batteryLevel; }
    void      setBatteryLevel(double batteryLevel);

    QVector3D getPosition()    const { return m_position; }
    void      setPosition(const QVector3D &pos);

    QVector3D getVelocity()    const { return m_velocity; }
    void      setVelocity(const QVector3D &vel);

    QVector3D getOrientation() const { return m_orientation; }
    void      setOrientation(const QVector3D &ori);

    double    getLatitude()    const { return m_latitude; }
    void      setLatitude(double latitude);

    double    getLongitude()   const { return m_longitude; }
    void      setLongitude(double longitude);

    double    getAltitude()    const { return m_altitude; }
    void      setAltitude(double altitude);

    double    getAirspeed()    const { return m_airspeed; }
    void      setAirspeed(double airspeed);

    // Adapters expected by DroneController (to unblock compile)
    void setConnected(bool v);
    void setBatteryVoltage(int millivolts);   // MAVLink SYS_STATUS delivers mV
    void setRoll(double r);
    void setPitch(double p);
    void setYaw(double y);
    void setModeField(const QString& m);      // flight mode text
    void setModeField(const QString& field, const QVariant& value);


    // Q_INVOKABLE helpers for QML
    void setPosition(float x, float y, float z);
    void setVelocity(float x, float y, float z);
    void setOrientation(float x, float y, float z);

signals:
    void nameChanged();
    void xbeeAddressChanged();
    void roleChanged();
    void xbeeIDChanged();
    void sysIDChanged();
    void compIDChanged();
    void batteryChanged();
    void positionChanged();
    void latitudeChanged();
    void longitudeChanged();
    void altitudeChanged();
    void velocityChanged();
    void airspeedChanged();
    void orientationChanged();
    void dataChanged();

private:
    QString   m_name;
    QString   m_xbeeAddress;
    QString   m_role;
    QString   m_xbeeID;
    int       m_sysID;
    int       m_compID;
    double    m_batteryLevel;
    QVector3D m_position;
    double    m_latitude;
    double    m_longitude;
    double    m_altitude;
    QVector3D m_velocity;
    double    m_airspeed;
    QVector3D m_orientation;

    // Newly added backing fields for adapters
    bool      m_connected = false;
    QString   m_mode;

    //serialization
    friend class cereal::access;
    template<class Archive>
    void serialize(Archive& archive)
    {
        archive(m_name);
        archive(m_xbeeAddress);
        archive(m_role);
        archive(m_xbeeID);
        archive(m_sysID);
        archive(m_compID);
        archive(m_batteryLevel);
        archive(m_position);
        archive(m_latitude);
        archive(m_longitude);
        archive(m_altitude);
        archive(m_altitude);
        archive(m_velocity);
        archive(m_airspeed);
        archive(m_orientation);
        archive(m_connected);
        archive(m_mode);
    }
};

#endif // DRONECLASS_H
