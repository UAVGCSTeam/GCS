#pragma once
#include <QObject>
#include <QByteArray>

class XbeeLink;
class MavlinkSender : public QObject {
    Q_OBJECT
public:
    explicit MavlinkSender(XbeeLink* link, QObject* parent=nullptr);
    // sys/comp are target IDs on the drone
    bool sendArm(uint8_t sys, uint8_t comp, bool arm);
    bool sendTakeoffCmd(uint8_t target_system, uint8_t target_component);
    bool setGuidedMode(uint8_t target_system, uint8_t target_component);
    bool requestData(uint8_t target_system, uint8_t target_component);

private:
    XbeeLink* link_;
    QByteArray packCommandLong(uint8_t sys, uint8_t comp,
                               uint16_t command, float p1,
                               float p2=0,float p3=0,float p4=0,
                               float p5=0,float p6=0,float p7=0);
};
