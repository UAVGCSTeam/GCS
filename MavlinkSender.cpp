#include "MavlinkSender.h"
#include "XbeeLink.h"
#include "UdpLink.h"
#include <QDebug>
#include <chrono>


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


MavlinkSender::MavlinkSender(XbeeLink* link, QObject* p) : QObject(p), xbeeLink_(link) {}
MavlinkSender::MavlinkSender(UdpLink*  link, QObject* p) : QObject(p), udpLink_(link)  {}

bool MavlinkSender::sendTelemRequest(uint8_t sysID, uint8_t compID, int command) const {
    if(!linkOpen()) return false;
    QByteArray bytes = packCommandLong(
        sysID,
        compID,
        MAV_CMD_SET_MESSAGE_INTERVAL,        // 511
        // 0,                                   // confirmation = 0
        command,                             // param1 = message ID
        500000,                              // param2 = interval in µs (500000 µs = 2 Hz)
        0, 0, 0, 0, 0                        // params 3–7 unused
    );
    return writeToLink(bytes) > 0;
}


bool MavlinkSender::sendCommand(uint8_t sysID, uint8_t compID, int command, bool p1) const {
    /**
     * TODO: (SIM) TEST THIS WITH SIMULATION BEFORE PUTTING ON MAIN BRANCH
     */
    if(!linkOpen()) return false;
    QByteArray bytes = packCommandLong(
        sysID,
        compID,
        command,
        p1
    );
    return writeToLink(bytes) > 0;
}


bool MavlinkSender::linkOpen() const {
    if (xbeeLink_) return xbeeLink_->isOpen();
    if (udpLink_)  return udpLink_->isOpen();
    return false;
}

qint64 MavlinkSender::writeToLink(const QByteArray& bytes) const {
    if (xbeeLink_) return xbeeLink_->writeBytes(bytes);
    if (udpLink_)  return udpLink_->writeBytes(bytes);
    return -1;
}


QByteArray MavlinkSender::packCommandLong(uint8_t sys, uint8_t comp,
                                          uint16_t command, float p1,
                                          float p2,float p3,float p4,
                                          float p5,float p6,float p7) const {
    mavlink_message_t msg;
    mavlink_command_long_t cmd{};
    cmd.target_system = sys;
    cmd.target_component = comp;
    cmd.command = command;
    cmd.confirmation = 0;
    cmd.param1=p1; cmd.param2=p2; cmd.param3=p3; cmd.param4=p4;
    cmd.param5=p5; cmd.param6=p6; cmd.param7=p7;

    mavlink_msg_command_long_encode(/*sysid*/255, /*compid*/190, &msg, &cmd);
    uint8_t buf[MAVLINK_MAX_PACKET_LEN];
    const uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    return QByteArray(reinterpret_cast<char*>(buf), len);
}


