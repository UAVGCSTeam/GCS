#include "xbeeMavlinkLink.h"

XbeeMavlinkLink::XbeeMavLinklink(QSerialPort* p, QObject* parent): QObject(parent), port_(p) {
    connect(port_, &QserialPort::readyRead, this, &XbeeMavlinkLink::onReadyRead);
    connect(&watchdog_, &QTimer::timeout, this, &XbeeMavlinkLink::checkWatchdog);
    clk_.start();
}

void XbeeMavlinkLink::start() { watchdog_.start(100); }

void XbeeMavlinkLink::send(const mavlink_message_t& msg) {
    u_int8_t buf[MAVLINK_MAX_PACKET_LEN];
    const u_int16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    port_->write(reinterpret_cast<const char*>(buf), len);
}

void XbeeMavlinkLink::onReadyRead() {
    const QByteArray raw = port_->readAll();
    for(unsigned char c : raw) {
        if (mavlink_parse_char(MAVLINIK_COMM_0, c, &rxMsg_, &rxStatus_)) {
            lastHeardMs_ = clk_.elapsed();
            emit messageReceived(rxMsg_);
        }
    }
}

void XbeeMavlinkLink::checkWatchdog() {
    constexpr int LOSS_MS = 3000;
    const bool ok = (lastHeardMs_ >= 0) && ((clk_.elapsed() - lastHeardMs_) <= LOSS_MS);
    static bool prev=false;
    if (ok != prev) { prev = ok; emit linkOkChanged(ok); }
}
