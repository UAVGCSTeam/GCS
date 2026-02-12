#pragma once
#include <QObject>
#include <QByteArray>



class UARTLink;
class MavlinkSender : public QObject {
    Q_OBJECT
public:
    explicit MavlinkSender(UARTLink* link, QObject* parent=nullptr);
    // sys/comp are target IDs on the drone
    bool sendArm(uint8_t sys, uint8_t comp, bool arm);

private:
    UARTLink* link_;
    QByteArray packCommandLong(uint8_t sys, uint8_t comp,
                               uint16_t command, float p1,
                               float p2=0,float p3=0,float p4=0,
                               float p5=0,float p6=0,float p7=0);
};
