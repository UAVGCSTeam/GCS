#ifndef DRONECLASS_H
#define DRONECLASS_H

#include <QString>
#include <QVector>
#include <QObject>
#include <qvectornd.h>
#include <cmath>

class DroneClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged FINAL)
    Q_PROPERTY(QString xbeeAddress READ getXbeeAddress WRITE setXbeeAddress NOTIFY xbeeAddressChanged FINAL)
    Q_PROPERTY(double batteryLevel READ getBatteryLevel WRITE setBatteryLevel NOTIFY batteryChanged FINAL)
    Q_PROPERTY(QString role READ getRole WRITE setRole NOTIFY roleChanged FINAL)
    Q_PROPERTY(QVector3D position READ getPosition WRITE setPosition NOTIFY positionChanged FINAL)
    Q_PROPERTY(double lattitude READ getLattitude WRITE setLattitude NOTIFY lattitudeChanged FINAL)
    Q_PROPERTY(double longitude READ getLongitude WRITE setLongitude NOTIFY lattitudeChanged FINAL)
    Q_PROPERTY(QVector3D velocity READ getVelocity WRITE setVelocity NOTIFY velocityChanged FINAL)
    Q_PROPERTY(QVector3D orientation READ getOrientation WRITE setOrientation NOTIFY orientationChanged FINAL)
    Q_PROPERTY(QString selectedName READ getSelectedDroneName WRITE updateSelectedDroneName NOTIFY selectedDroneNameChanged FINAL)

public:
    // When an object is created in Qt, you can define its parent
    // What a parent does is it ties the object existence to a QML Component
    // When that component is killed, so is the object
    // So if you dont explictly define its parent, you have to manage the deletion of that data

    // Directly from https://doc.qt.io/qt-6/qobject.html
    /*
    "QObjects organize themselves in object trees.
    When you create a QObject with another object as parent, the object will automatically add itself to the parent's children() list.
    The parent takes ownership of the object; i.e., it will automatically delete its children in its destructor.
    You can look for an object by name and optionally type using findChild() or findChildren()."
    */
    explicit DroneClass(QObject *parent = nullptr);
    DroneClass(const QString &input_name,
               const QString &input_role,
               const QString &input_xbeeAddress,
               QObject *parent = nullptr
              );

    QString getName() const { return m_name; };
    QString getXbeeAddress() const { return m_xbeeAddress; };
    QString getRole() const {return m_role; };
    double getBatteryLevel() const { return m_batteryLevel; };
    QVector3D getPosition() const { return m_position; };
    double getLattitude() const {return m_lattitude; };
    double getLongitude() const {return m_longitude; };
    QVector3D getVelocity() const { return m_velocity; };
    QVector3D getOrientation() const { return m_orientation; };

    static QString getSelectedDroneName() { return selectedDroneName; };

    // QINVOKEABLE allows functions to be called in QML files
    Q_INVOKABLE void setPosition(float x, float y, float z);
    Q_INVOKABLE void setVelocity(float x, float y, float z);
    Q_INVOKABLE void setOrientation(float x, float y, float z);


signals:
    void nameChanged();
    void xbeeAddressChanged();
    void roleChanged();
    void batteryChanged();
    void positionChanged();
    void lattitudeChanged();
    void longitudeChanged();
    void velocityChanged();
    void orientationChanged();
    void selectedDroneNameChanged();

public slots:
    void setName(const QString &inputName);
    void setXbeeAddress(const QString &inputXbeeAddress);
    void setRole(const QString &inputRole);
    void setBatteryLevel(double batteryLevel);
    void setPosition(const QVector3D &pos);
    void setLattitude(const double &lat);
    void setLongitude(const double &lon);
    void setVelocity(const QVector3D &vel);
    void setOrientation(const QVector3D &ori);
    void updateSelectedDroneName(QString &selectedName);

private:
    QString m_name;
    QString m_xbeeAddress;
    QString m_role;
    double m_batteryLevel;
    QVector3D m_position;
    double m_lattitude;
    double m_longitude;
    QVector3D m_velocity;
    QVector3D m_orientation;

    static QString selectedDroneName;
};

#endif // DroneClass_H
