#ifndef DRONECLASS_H
#define DRONECLASS_H

#include <QObject>
#include <QString>
#include <QVector3D>
#include <QVector>
#include <cmath>
#include <QVariant>


class DroneClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString   name        READ getName        WRITE setName        NOTIFY nameChanged        FINAL)
    Q_PROPERTY(QString   xbeeAddress READ getXbeeAddress WRITE setXbeeAddress NOTIFY xbeeAddressChanged FINAL)
    Q_PROPERTY(double    batteryLevel READ getBatteryLevel WRITE setBatteryLevel NOTIFY batteryChanged  FINAL)
    Q_PROPERTY(QString   role        READ getRole        WRITE setRole        NOTIFY roleChanged        FINAL)
    Q_PROPERTY(QString   xbeeID      READ getXbeeID      WRITE setXbeeID      NOTIFY xbeeIDChanged      FINAL)
    Q_PROPERTY(int       sysID       READ getSysID       WRITE setSysID       NOTIFY sysIDChanged       FINAL)
    Q_PROPERTY(int       compID      READ getCompID      WRITE setCompID      NOTIFY compIDChanged      FINAL)
    Q_PROPERTY(QVector3D position    READ getPosition    WRITE setPosition    NOTIFY positionChanged    FINAL)
    Q_PROPERTY(double    latitude    READ getLatitude    WRITE setLatitude    NOTIFY latitudeChanged    FINAL)  // temporary
    Q_PROPERTY(double    longitude   READ getLongitude   WRITE setLongitude   NOTIFY longitudeChanged   FINAL)  // temporary
    Q_PROPERTY(double    altitude    READ getAltitude    WRITE setAltitude    NOTIFY altitudeChanged    FINAL)  // temporary
    Q_PROPERTY(QVector3D velocity    READ getVelocity    WRITE setVelocity    NOTIFY velocityChanged    FINAL)
    Q_PROPERTY(double    airspeed    READ getAirspeed    WRITE setAirspeed    NOTIFY airspeedChanged    FINAL)  // temporary
    Q_PROPERTY(QVector3D orientation READ getOrientation WRITE setOrientation NOTIFY orientationChanged FINAL)

public:
    explicit DroneClass(QObject *parent = nullptr);

    DroneClass(const QString &input_name,
               const QString &input_role,
               const QString &input_xbeeAddress,
               QObject *parent = nullptr);

    // overload function to create with XBee-ID && sys and comp id
    DroneClass(const QString &input_name,
               const QString &input_role,
               const QString &input_xbeeID,
               const int &input_sysID,
               const int &input_compID,
               const QString &input_xbeeAddress,
               QObject *parent = nullptr);

    // overload function to create with XBee-ID
    DroneClass(const QString &input_name,
               const QString &input_role,
               const QString &input_xbeeID,
               const QString &input_xbeeAddress,
               QObject *parent = nullptr);

    // For handling the shared memory communication between the python and each INDIVIDUAL drone
    void processXbeeMessage(const QString &message);

    // Getters/Setters used by Q_PROPERTY
    QString   getName()        const { return m_name; }
    void      setName(const QString &inputName);

    QString   getXbeeAddress() const { return m_xbeeAddress; }
    void      setXbeeAddress(const QString &inputXbeeAddress);

    QString   getRole()        const { return m_role; }
    void      setRole(const QString &inputRole);

    QString   getXbeeID()      const { return m_xbeeID; }
    void      setXbeeID(const QString &inputXbeeID);

    int   getSysID()      const { return m_sysID; }
    void      setSysID(const int &inputSysID);

    int   getCompID()      const { return m_compID; }
    void      setCompID(const int &inputCompID);

    double    getBatteryLevel() const { return m_batteryLevel; }
    void      setBatteryLevel(double batteryLevel);

    QVector3D getPosition()    const { return m_position; }
    void      setPosition(const QVector3D &pos);

    QVector3D getVelocity()    const { return m_velocity; }
    void      setVelocity(const QVector3D &vel);

    QVector3D getOrientation() const { return m_orientation; }
    void      setOrientation(const QVector3D &ori);

    double    getLatitude()    const { return m_latitude; }   // temporary
    void      setLatitude(double latitude);                   // temporary

    double    getLongitude()   const { return m_longitude; }  // temporary
    void      setLongitude(double longitude);                 // temporary

    double    getAltitude()    const { return m_altitude; }   // temporary
    void      setAltitude(double altitude);                   // temporary

    double    getAirspeed()    const { return m_airspeed; }   // temporary
    void      setAirspeed(double airspeed);                   // temporary

    // Adapters expected by DroneController (to unblock compile)
    void setConnected(bool v);
    void setBatteryVoltage(int millivolts);   // MAVLink SYS_STATUS delivers mV
    void setRoll(double r);
    void setPitch(double p);
    void setYaw(double y);
    void setModeField(const QString& m);      // flight mode text
    void setModeField(const QString& field, const QVariant& value);


    // Q_INVOKABLE helpers for QML
    Q_INVOKABLE void setPosition(float x, float y, float z);
    Q_INVOKABLE void setVelocity(float x, float y, float z);
    Q_INVOKABLE void setOrientation(float x, float y, float z);

signals:
    void nameChanged();
    void xbeeAddressChanged();
    void roleChanged();
    void xbeeIDChanged();
    void sysIDChanged();
    void compIDChanged();
    void batteryChanged();
    void positionChanged();
    void latitudeChanged();    // temporary
    void longitudeChanged();   // temporary
    void altitudeChanged();    // temporary
    void velocityChanged();
    void airspeedChanged();    // temporary
    void orientationChanged();
    void dataChanged();

private:
    QString   m_name;
    QString   m_xbeeAddress;
    QString   m_role;
    QString   m_xbeeID;
    int   m_sysID;
    int   m_compID;
    double    m_batteryLevel;
    QVector3D m_position;
    double    m_latitude;      // temporary
    double    m_longitude;     // temporary
    double    m_altitude;      // temporary
    QVector3D m_velocity;
    double    m_airspeed;      // temporary
    QVector3D m_orientation;

    // Newly added backing fields for adapters
    bool      m_connected = false;
    QString   m_mode;
};

#endif // DRONECLASS_H
