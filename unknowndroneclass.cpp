#include "unknowndroneclass.h"


UnknownDroneClass::UnknownDroneClass(QObject *parent) :
    QObject(parent)
{}

UnknownDroneClass::UnknownDroneClass(const QString &uid,
                                     const QString &fc,
                                     const QString &uavType,
                                     int sysID,
                                     int compID,
                                     int senderUDPPort,
                                     bool ignored,
                                     QObject *parent)
    : QObject(parent)
    , m_uid(uid)
    , m_fc(fc)
    , m_uavType(uavType)
    , m_sysID(sysID)
    , m_compID(compID)
    , m_senderUDPPort(senderUDPPort)
    , m_ignored(ignored)
{
}

void UnknownDroneClass::setUid(const QString &uid)
{
    if (m_uid == uid) return;
    m_uid = uid;
    emit uidChanged();
}

void UnknownDroneClass::setFc(const QString &fc)
{
    if (m_fc == fc) return;
    m_fc = fc;
    emit fcChanged();
}

void UnknownDroneClass::setUavType(const QString &uavType)
{
    if (m_uavType == uavType) return;
    m_uavType = uavType;
    emit uavTypeChanged();
}

void UnknownDroneClass::setSysID(int sysID)
{
    if (m_sysID == sysID) return;
    m_sysID = sysID;
    emit sysIDChanged();
}

void UnknownDroneClass::setCompID(int compID)
{
    if (m_compID == compID) return;
    m_compID = compID;
    emit compIDChanged();
}

void UnknownDroneClass::setSenderUDPPort(int senderUDPPort)
{
    if (m_senderUDPPort == senderUDPPort) return;
    m_senderUDPPort = senderUDPPort;
    emit senderUDPPortChanged();
}

void UnknownDroneClass::setIgnored(bool ignored)
{
    if (m_ignored == ignored) return;
    m_ignored = ignored;
    emit ignoredChanged();
}
