#include "MAVLinkReceiver.h"



struct MAVLinkReceiver::Impl {
    mavlink_status_t status{};
};

MAVLinkReceiver::MAVLinkReceiver(QObject* parent)
    : QObject(parent), d_(std::make_unique<Impl>()) {}

MAVLinkReceiver::~MAVLinkReceiver() = default;   // ← now Impl is complete

void MAVLinkReceiver::onBytes(const QByteArray& data) {
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
