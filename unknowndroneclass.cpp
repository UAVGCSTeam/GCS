#include "unknowndroneclass.h"

#include <QDebug>
#include <QString>
#include <QStringList>
#include <cmath>

UnknownDroneClass::UnknownDroneClass(QObject *parent) :
    DroneClass(parent)
{}

UnknownDroneClass::UnknownDroneClass(const QString &uid,
                                     const QString &fc,
                                     const QString &uavType,
                                     int sysID,
                                     int compID,
                                     QObject *parent)
    : DroneClass(parent)
    , m_uid(uid)
    , m_fc(fc)
    , m_uavType(uavType)
    , m_sysID(sysID)
    , m_compID(compID)
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
