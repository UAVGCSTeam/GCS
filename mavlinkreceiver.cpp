#include "mavlinkreceiver.h"
#include <QDebug>

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

MavlinkReceiver::MavlinkReceiver(QObject *p) : QObject(p) {}

void MavlinkReceiver::unpackMessage(QByteArray& data) {
    const auto* p = reinterpret_cast<const uint8_t*>(data.constData());
    const int n = data.size();

    for (int i = 0; i < n; ++i) {
        // Feed one byte at a time; parser handles partial frames automatically
        if (mavlink_parse_char(MAVLINK_COMM_0, p[i], &msg_, &status_)) {
            // A complete, CRC-valid MAVLink message is ready in msg_
            decodeType(msg_);
        }
    }

}

void MavlinkReceiver::decodeType(const mavlink_message_t& msg) {
    switch (msg.msgid) {
        case MAVLINK_MSG_ID_HEARTBEAT: {
            mavlink_heartbeat_t hb{};
            mavlink_msg_heartbeat_decode(&msg, &hb);
            qDebug() << "This is the system status" << hb.system_status;
            // emit heartbeatReceived(
            //     msg.sysid, msg.compid,
            //     hb.type, hb.autopilot, hb.base_mode,
            //     hb.system_status, hb.custom_mode
            //     );
            break;
        }
    }
}
