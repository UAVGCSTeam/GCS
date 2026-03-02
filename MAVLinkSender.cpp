#include "MAVLinkSender.h"






MAVLinkSender::MAVLinkSender(UARTLink* link, QObject* p) : QObject(p), UARTLink_(link) {}
MAVLinkSender::MAVLinkSender(UdpLink*  link, QObject* p) : QObject(p), UDPLink_(link) {}

bool MAVLinkSender::sendTelemRequest(uint8_t sysID, uint8_t compID, int command) const {
    if(!linkOpen()) return false;
    qDebug() << "[MAVLinkSender.cpp::sendTelemRequest] requesting from sysID" << sysID << "compID" << compID;
    QByteArray bytes = packCommandLong(
        sysID,
        compID,
        MAV_CMD_SET_MESSAGE_INTERVAL,        // 511
        command,                             // param1 = message ID
        500000,                              // param2 = interval in µs (500000 µs = 2 Hz = 500 ms)
        0, 0, 0, 0, 0                        // params 3–7 unused
    );
    return writeToLink(bytes) > 0;
}

bool MAVLinkSender::sendCommand(uint8_t sysID, uint8_t compID,
                                uint16_t command, float p1,
                                float p2,float p3,float p4,
                                float p5,float p6,float p7) const {
    if(!linkOpen()) return false;
    QByteArray bytes = packCommandLong(
        sysID,
        compID,
        command,
        p1, p2, p3, p4, p5, p6, p7
    );
    return writeToLink(bytes) > 0;
}


bool MAVLinkSender::linkOpen() const {
    if (UARTLink_) return UARTLink_->isOpen();
    if (UDPLink_)  return UDPLink_->isOpen();
    return false;
}


qint64 MAVLinkSender::writeToLink(const QByteArray& bytes) const {
    if (UARTLink_) return UARTLink_->writeBytes(bytes);
    if (UDPLink_)  return UDPLink_->writeBytes(bytes);
    return -1;
}


QByteArray MAVLinkSender::packCommandLong(uint8_t targetSys, uint8_t targetComp,
                                          uint16_t command, float p1,
                                          float p2,float p3,float p4,
                                          float p5,float p6,float p7) const {
    mavlink_message_t msg;
    mavlink_command_long_t cmd{};
    cmd.target_system = targetSys;
    cmd.target_component = targetComp;
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




