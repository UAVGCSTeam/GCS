#include "heartbeat.h"
#include <QDateTime>

Heartbeat::Heartbeat(QSerialPort* serial, QObject* parent)
    : QObject(parent), serial_(serial)
{
    connect(&hbTimer_, &QTimer::timeout, this, &Heartbeat::sendHeartbeat);
    connect(&wdTimer_, &QTimer::timeout, this, &Heartbeat::checkWatchdog);
    connect(serial_, &QSerialPort::readyRead, this, &Heartbeat::onSerialReadyRead);
    clk_.start();
}

void Heartbeat::start() {
    hb.Timer_.start(hbPeriodMs_);
    wdTimer_.start(100);
}

void Heartbeat::stop() {
    hbTimer_.stop();
    wdTimer_.stop();
}

void Heartbeat::sendHeartbeat() {
    mavlink_message_t msg;
    uint8_t buf[MAVLINK_MAX_PACKET_LEN];

    mavlink_msg_heartbeat_pack(
        gcsSysId_, gcsCompId, &msg,
        MAV_TYPE_GCS,                   // type
        MAV_AUTOPILOT_INVALID,          // autopilot
        0,                              // base_mode
        0,                              // custom_mode
        MAV_STATE_ACTIVE                // system_status
    );
    const uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    serial_->write(reinterpret_cast<const char*>(buf), len);
}

void Heartbeat::onSerialReadyRead() {
    feedParser(serial_->readAll());
}

void Heartbeat::feedParser(const QByteArray &bytes) {
    for (unsigned char c : bytes) {
        if (mavlink_parse_char(MAVLINK_COMM_0, c, &rxMsg_, &rxStatus_)) {
            switch (rxMsg_.msgid) {
                case MAVLINK_MSG_ID_HEARTBEAT: {
                    if (uavSysId_ == 0 || rxMsg_.sysid == uavSysId_) {
                        lastHeardMs_ = clk_.elapsed();
                        if (!linkOk_) { linkOk_ = true; emit linkOkChanged(true); }
                    }
                } break;

                default: break;
            }
        }
    }
}

void Heartbeat::checkWatchdog() {
    const qint64 now = clk_.elapsed();
    const bool timedOut = (lastHeardMs_ < 0) || (now - lastHeardMs_ > lossThresholdMs_);
    if (timedOut && linkOk_) { linkOk_ = false; emit linkOkChanged(false); }
}
