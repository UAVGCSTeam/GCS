#include "MavlinkSender.h"
#include "XbeeLink.h"

// include mavlink (common dialect), handle both folder layouts
#if __has_include(<mavlink/common/mavlink.h>)
extern "C"
{
#include <mavlink/common/mavlink.h>
}
#elif __has_include(<common/mavlink.h>)
extern "C"
{
#include <common/mavlink.h>
}
#else
#error "Cannot find MAVLink headers. Check CMake include dirs and submodule path."
#endif

MavlinkSender::MavlinkSender(XbeeLink *link, QObject *p) : QObject(p), link_(link) {}

QByteArray MavlinkSender::packCommandLong(uint8_t sys, uint8_t comp,
                                          uint16_t command, float p1,
                                          float p2, float p3, float p4,
                                          float p5, float p6, float p7)
{
    mavlink_message_t msg;
    mavlink_command_long_t cmd{};
    cmd.target_system = sys;
    cmd.target_component = comp;
    cmd.command = command;
    cmd.confirmation = 0;
    cmd.param1 = p1;
    cmd.param2 = p2;
    cmd.param3 = p3;
    cmd.param4 = p4;
    cmd.param5 = p5;
    cmd.param6 = p6;
    cmd.param7 = p7;

    mavlink_msg_command_long_encode(/*sysid*/ 255, /*compid*/ 190, &msg, &cmd);
    uint8_t buf[MAVLINK_MAX_PACKET_LEN];
    const uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    return QByteArray(reinterpret_cast<char *>(buf), len);
}

bool MavlinkSender::sendArm(uint8_t sys, uint8_t comp, bool arm)
{
    if (!link_ || !link_->isOpen())
        return false;
    auto bytes = packCommandLong(sys, comp,
                                 MAV_CMD_COMPONENT_ARM_DISARM, arm ? 1.0f : 0.0f);
    return link_->writeBytes(bytes);
}
