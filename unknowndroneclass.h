#ifndef UNKNOWNDRONECLASS_H
#define UNKNOWNDRONECLASS_H

#include <QObject>
#include <QString>
#include <QVector3D>
#include <QVector>
#include <cmath>
#include <QVariant>

class UnknownDroneClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString  uid         READ getUid     NOTIFY uidChanged       FINAL)
    Q_PROPERTY(QString  fc          READ getFc      NOTIFY fcChanged        FINAL)
    Q_PROPERTY(QString  uavType     READ getUavType NOTIFY uavTypeChanged   FINAL)
    Q_PROPERTY(int      sysID       READ getSysID   NOTIFY sysIDChanged     FINAL)
    Q_PROPERTY(int      compID      READ getCompID  NOTIFY compIDChanged    FINAL)
    Q_PROPERTY(bool     ignored     READ getIgnored NOTIFY ignoredChanged   FINAL)

public:
    explicit UnknownDroneClass(QObject *parent = nullptr);

    UnknownDroneClass(const QString &uid,
                      const QString &fc,
                      const QString &uavType,
                      int sysID,
                      int compID,
                      QObject *parent = nullptr);

    // Getters/Setters used by Q_PROPERTY
    QString getUid()        const { return m_uid; }
    void    setUid(const QString &uid);

    QString getFc()         const { return m_fc; }
    void    setFc(const QString &fc);

    QString getUavType()    const { return m_uavType; }
    void    setUavType(const QString &uavType);

    int getSysID()          const { return m_sysID; }
    void    setSysID(int sysID);

    int getCompID()         const { return m_compID; }
    void    setCompID(int compID);

    bool getIgnored()       const { return m_ignored; }
    void    setIgnored(bool ignored);

signals:
    void uidChanged();
    void fcChanged();
    void uavTypeChanged();
    void sysIDChanged();
    void compIDChanged();
    void ignoredChanged();

private:
    QString m_uid;
    QString m_fc;
    QString m_uavType;
    int m_sysID = -1;
    int m_compID = -1;
    bool m_ignored = false;
};

#endif // UNKNOWNDRONECLASS_H
