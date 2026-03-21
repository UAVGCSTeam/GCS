#ifndef UNKNOWNDRONECLASS_H
#define UNKNOWNDRONECLASS_H

#include <QObject>
#include <QString>

class UnknownDroneClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString   uid      READ getUid      NOTIFY uidChanged      FINAL)
    Q_PROPERTY(QString   fc       READ getFc       NOTIFY fcChanged       FINAL)
    Q_PROPERTY(QString   uavType  READ getUavType  NOTIFY uavTypeChanged  FINAL)
    Q_PROPERTY(uint8_t   sysID    READ getSysID    NOTIFY sysIDChanged    FINAL)
    Q_PROPERTY(uint8_t   compID   READ getCompID   NOTIFY compIDChanged   FINAL)
    Q_PROPERTY(uint16_t  UDPPort   READ getUDPPort NOTIFY UDPPortChanged   FINAL)
    Q_PROPERTY(bool      ignored  READ getIgnored  NOTIFY ignoredChanged   FINAL)

public:
    explicit UnknownDroneClass(QObject *parent = nullptr);

    UnknownDroneClass(const QString &uid,
                      const QString &fc,
                      const QString &uavType,
                      const uint8_t sysID,
                      const uint8_t compID,
                      const uint16_t UDPPort,
                      bool ignored,
                      QObject *parent = nullptr);

    // Getters/Setters used by Q_PROPERTY
    QString getUid()      const { return m_uid; }
    void    setUid(const QString &uid);

    QString getFc()       const { return m_fc; }
    void    setFc(const QString &fc);

    QString getUavType()  const { return m_uavType; }
    void    setUavType(const QString &uavType);

    uint8_t getSysID()    const { return m_sysID; }
    void    setSysID(uint8_t sysID);

    uint8_t getCompID()   const { return m_compID; }
    void    setCompID(uint8_t compID);

    uint16_t getUDPPort()   const { return m_udp_port; }
    void    setUDPPort(uint16_t UDPPort);

    bool    getIgnored()  const { return m_ignored; }
    void    setIgnored(bool ignored);

signals:
    void uidChanged();
    void fcChanged();
    void uavTypeChanged();
    void sysIDChanged();
    void compIDChanged();
    void UDPPortChanged();
    void ignoredChanged();

private:
    QString   m_uid;
    QString   m_fc;
    QString   m_uavType;
    uint8_t   m_sysID = -1;
    uint8_t   m_compID = -1;
    uint16_t   m_udp_port = -1;
    bool      m_ignored = false;
};

#endif // UNKNOWNDRONECLASS_H
