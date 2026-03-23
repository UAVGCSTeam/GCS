#include "MAVLinkReceiver.h"



struct MAVLinkReceiver::Impl {
    mavlink_status_t status{};
};

MAVLinkReceiver::MAVLinkReceiver(QObject* parent)
    : QObject(parent), d_(std::make_unique<Impl>()) {}

MAVLinkReceiver::~MAVLinkReceiver() = default;   // ← now Impl is complete

void MAVLinkReceiver::onBytes(const QByteArray& data) {
    RxMavlinkMsg out = getMAVLinkFromBytes(data);
    emit messageReceived(out);
}

RxMavlinkMsg MAVLinkReceiver::getMAVLinkFromBytes(const QByteArray& data) {
    mavlink_message_t msg;
    const uint8_t* p = reinterpret_cast<const uint8_t*>(data.constData());
    const int n = data.size();
    for (int i = 0; i < n; ++i) {
        if (mavlink_parse_char(MAVLINK_COMM_0, p[i], &msg, &d_->status)) {
            RxMavlinkMsg out{ msg.sysid, msg.compid, msg.msgid,
                             QByteArray(reinterpret_cast<const char*>(_MAV_PAYLOAD(&msg)),
                                        static_cast<int>(msg.len)) };
            return out;
        }
    }
    return RxMavlinkMsg{0, 0, 0, QByteArray()};
}

RxMavlinkMsg MAVLinkReceiver::getMAVLinkFromBytesWithFreshState(const QByteArray& data) {
    mavlink_message_t msg;
    mavlink_status_t fresh{};
    const uint8_t* p = reinterpret_cast<const uint8_t*>(data.constData());
    const int n = data.size();
    for (int i = 0; i < n; ++i) {
        if (mavlink_parse_char(MAVLINK_COMM_0, p[i], &msg, &fresh)) {
            RxMavlinkMsg out{ msg.sysid, msg.compid, msg.msgid,
                             QByteArray(reinterpret_cast<const char*>(_MAV_PAYLOAD(&msg)),
                                        static_cast<int>(msg.len)) };
            return out;
        }
    }
    return RxMavlinkMsg{0, 0, 0, QByteArray()};
}