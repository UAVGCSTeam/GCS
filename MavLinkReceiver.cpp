#include "MavlinkReceiver.h"
extern "C" {
#if __has_include(<mavlink/common/mavlink.h>)
#include <mavlink/common/mavlink.h>
#else
#include <common/mavlink.h>
#endif
}

struct MavlinkReceiver::Impl {
    mavlink_status_t status{};
};

MavlinkReceiver::MavlinkReceiver(QObject* parent)
    : QObject(parent), d_(std::make_unique<Impl>()) {}

MavlinkReceiver::~MavlinkReceiver() = default;   // ← now Impl is complete

void MavlinkReceiver::onBytes(const QByteArray& data) {
    mavlink_message_t msg;
    for (unsigned char b : data) {
        if (mavlink_parse_char(MAVLINK_COMM_0, b, &msg, &d_->status)) {
            RxMavlinkMsg out{ msg.sysid, msg.compid, msg.msgid,
                             QByteArray(reinterpret_cast<const char*>(_MAV_PAYLOAD(&msg)),
                                        static_cast<int>(msg.len)) };
            emit messageReceived(out);
        }
    }
}
