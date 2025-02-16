#ifndef DRONECLASS_H
#define DRONECLASS_H

#include <QString>
#include <QVector>
#include <QObject>
#include <qvectornd.h>

class DroneClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged FINAL)
    Q_PROPERTY(double batteryLevel READ getBattery WRITE setBattery NOTIFY batteryChanged FINAL)
    Q_PROPERTY(QString role READ getRole WRITE setRole NOTIFY roleChanged FINAL)
    Q_PROPERTY(QVector3D position READ getPosition WRITE setPosition NOTIFY positionChanged FINAL)
    Q_PROPERTY(QVector3D velocity READ getVelocity WRITE setVelocity NOTIFY velocityChanged FINAL)
    Q_PROPERTY(QVector3D orientation READ getOrientation WRITE setOrientation NOTIFY orientationChanged FINAL)

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
              QObject *parent = nullptr
              );

    QString getName() const { return m_name; };
    void setName(const QString &inputName);
    QString getRole() const {return m_role; };
    void setRole(const QString &inputRole);
    double getBatteryLevel() const { return m_batteryLevel; };
    void setBatteryLevel(double batteryLevel);
    QVector3D getPosition() const { return m_position; };
    void setPosition(const QVector3D &pos);
    QVector3D getVelocity() const { return m_velocity; };
    void setVelocity(const QVector3D &vel);
    QVector3D getOrientation() const { return m_orientation; };
    void setOrientation(const QVector3D &ori);

    // QINVOKEABLE allows functions to be called in QML files
    Q_INVOKABLE void setPosition(float x, float y, float z);
    Q_INVOKABLE void setVelocity(float x, float y, float z);
    Q_INVOKABLE void setOrientation(float x, float y, float z);


signals:
    void nameChanged();
    void roleChanged();
    void batteryChanged();
    void positionChanged();
    void velocityChanged();
    void orientationChanged();

private:
    QString m_name;
    QString m_role;
    double m_batteryLevel;
    QVector3D m_position;
    QVector3D m_velocity;
    QVector3D m_orientation;

};

#endif // DroneClass_H
