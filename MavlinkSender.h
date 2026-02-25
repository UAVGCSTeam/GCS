#pragma once
#include <QObject>
#include <QByteArray>



class XbeeLink;
class UdpLink;
class MavlinkSender : public QObject {
    Q_OBJECT
public:
    explicit MavlinkSender(XbeeLink* link, QObject* parent=nullptr);
    explicit MavlinkSender(UdpLink*  link, QObject* parent=nullptr);
    bool linkOpen() const;
    bool sendTelemRequest(uint8_t sys, uint8_t comp, int command) const;
    bool sendCommand(uint8_t sysID, uint8_t compID, int command, bool p1) const;

private:
    qint64 writeToLink(const QByteArray& bytes) const;
    XbeeLink* xbeeLink_{nullptr};
    UdpLink*  udpLink_{nullptr};
    QByteArray packCommandLong(uint8_t sys, uint8_t comp,
                               uint16_t command, float p1,
                               float p2=0,float p3=0,float p4=0,
                               float p5=0,float p6=0,float p7=0) const;
};
