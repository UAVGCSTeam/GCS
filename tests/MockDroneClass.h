#pragma once

#include <QString>

class DroneClass {
public:
    explicit DroneClass(const QString& xbeeAddress = {})
        : m_xbeeAddress(xbeeAddress)
    {
    }

    QString getXbeeAddress() const
    {
        return m_xbeeAddress;
    }
private:
    QString m_xbeeAddress;
};
