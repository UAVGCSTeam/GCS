#include "MAVLinkSender.h"






MAVLinkSender::MAVLinkSender(UARTLink* link, QObject* p) : QObject(p), UARTLink_(link) {}
MAVLinkSender::MAVLinkSender(UDPLink*  link, QObject* p) : QObject(p), UDPLink_(link) {}

bool MAVLinkSender::sendTelemRequest(uint8_t targetSysID, uint8_t targetCompID, int command, int udpPort) const {
    if(!isLinkOpen()) return false;
    qDebug() << "[MAVLinkSender.cpp::sendTelemRequest] requesting from targetSysID" << targetSysID << "targetCompID" << targetCompID;
    QByteArray bytes = packCommandLong(
        targetSysID,
        targetCompID,
        MAV_CMD_SET_MESSAGE_INTERVAL,        // 511
        command,                             // param1 = message ID
        500000,                              // param2 = interval in µs (500000 µs = 2 Hz = 500 ms)
        0, 0, 0, 0, 0                        // params 3–7 unused
    );
    return writeToLink(bytes, targetSysID, udpPort) > 0;
}

bool MAVLinkSender::sendCommand(uint8_t targetSysID, uint8_t targetCompID,
                                uint16_t command, float p1,
                                float p2,float p3,float p4,
                                float p5,float p6,float p7, int udpPort) const {
    if(!isLinkOpen()) return false;
    QByteArray bytes = packCommandLong(
        targetSysID,
        targetCompID,
        command,
        p1, p2, p3, p4, p5, p6, p7
    );
    return writeToLink(bytes, targetSysID, udpPort) > 0;
}


bool MAVLinkSender::isLinkOpen() const {
    if (UARTLink_) return UARTLink_->isOpen();
    if (UDPLink_)  return UDPLink_->isOpen();
    return false;
}


qint64 MAVLinkSender::writeToLink(const QByteArray& bytes, uint8_t targetSysID, int udpPort) const {
    if (UARTLink_) return UARTLink_->writeBytes(bytes);
    if (UDPLink_) {
        if (udpPort >= 0)
            return UDPLink_->writeBytes(bytes, static_cast<quint16>(udpPort));
        return UDPLink_->writeBytes(bytes, targetSysID);
    }
    return -1;
}


QByteArray MAVLinkSender::packCommandLong(uint8_t targetSysID, uint8_t targetCompID,
                                          uint16_t command, float p1,
                                          float p2,float p3,float p4,
                                          float p5,float p6,float p7) const {
    mavlink_message_t msg;
    mavlink_command_long_t cmd{};
    cmd.target_system = targetSysID;
    cmd.target_component = targetCompID;
    cmd.command = command;
    cmd.confirmation = 0;
    cmd.param1=p1; cmd.param2=p2; cmd.param3=p3; cmd.param4=p4;
    cmd.param5=p5; cmd.param6=p6; cmd.param7=p7;

    // Encode with GCS system/component IDs
    mavlink_msg_command_long_encode(/*sysid*/255, /*compid*/190, &msg, &cmd);
    uint8_t buf[MAVLINK_MAX_PACKET_LEN];
    const uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    return QByteArray(reinterpret_cast<char*>(buf), len);
}


bool MAVLinkSender::sendSetPositionTargetGlobalInt(uint8_t targetSysID, uint8_t targetCompID,
                                                   double lat_deg, double lon_deg,
                                                   float alt_m, int udpPort) const {
    if (!isLinkOpen()) return false;

    mavlink_message_t msg{};

    // ArduPilot expects lat/lon scaled by 1e7 in GLOBAL_INT frames
    const int32_t lat_int = static_cast<int32_t>(lat_deg * 1e7);
    const int32_t lon_int = static_cast<int32_t>(lon_deg * 1e7);

    // Use only position (x,y,z); ignore velocity, acceleration, yaw, yaw_rate
    const uint16_t typeMask =
        (1 << 3) | (1 << 4) | (1 << 5) |  // ignore velocity
        (1 << 6) | (1 << 7) | (1 << 8) |  // ignore acceleration
        (1 << 9) | (1 << 10);             // ignore yaw, yaw rate

    // time_boot_ms can be 0 for simple GCS implementations
    const uint32_t time_boot_ms = 0;

    mavlink_msg_set_position_target_global_int_pack(
        /*sysid (GCS)*/ 255,
        /*compid*/       190,
        &msg,
        time_boot_ms,
        targetSysID,
        targetCompID,
        MAV_FRAME_GLOBAL_RELATIVE_ALT_INT,
        typeMask,
        lat_int,
        lon_int,
        alt_m,
        0.0f, 0.0f, 0.0f,   // vx, vy, vz (ignored)
        0.0f, 0.0f, 0.0f,   // ax, ay, az (ignored)
        0.0f, 0.0f          // yaw, yaw_rate (ignored)
    );

    uint8_t buf[MAVLINK_MAX_PACKET_LEN];
    const uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    return writeToLink(QByteArray(reinterpret_cast<char*>(buf), len), targetSysID, udpPort) > 0;
}




