#pragma once
#include <QObject>
#include <QByteArray>
#include "UARTLink.h"
#include "UdpLink.h"



extern "C" {
#if __has_include(<mavlink/common/mavlink.h>)
#include <mavlink/common/mavlink.h>
#else
#include <common/mavlink.h>
#endif
}



// include mavlink (common dialect), handle both folder layouts
#if __has_include(<mavlink/common/mavlink.h>)
extern "C" {
#include <mavlink/common/mavlink.h>
}
#elif __has_include(<common/mavlink.h>)
extern "C" {
#include <common/mavlink.h>
}
#else
#error "Cannot find MAVLink headers. Check CMake include dirs and submodule path."
#endif





class UARTLink;
class UdpLink;
class MAVLinkSender : public QObject {
    Q_OBJECT
public:
    explicit MAVLinkSender(UARTLink* link, QObject* parent=nullptr);
    explicit MAVLinkSender(UdpLink*  link, QObject* parent=nullptr);
    bool linkOpen() const;
    bool sendTelemRequest(uint8_t sys, uint8_t comp, int command) const;
    bool sendCommand(uint8_t sysID, uint8_t compID, int command, bool p1) const;

private:
    qint64 writeToLink(const QByteArray& bytes) const;
    UARTLink* UARTLink_;
    UdpLink*  UDPLink_;
    QByteArray packCommandLong(uint8_t sys, uint8_t comp,
                               uint16_t command, float p1,
                               float p2=0,float p3=0,float p4=0,
                               float p5=0,float p6=0,float p7=0) const;
};
