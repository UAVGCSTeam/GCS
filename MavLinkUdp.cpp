#include "MavlinkUdp.h"
#include <QByteArray>
#include <QDateTime>

MavlinkUdp::MavlinkUdp(QString dstIp, quint16 dstPort, quint16 localPort, QObject* parent)
    : QObject(parent), dest(QHostAddress(dstIp)), dport(dstPort) {
    socket.bind(QHostAddress::AnyIPv4, localPort);
    connect(&socket, &QUdpSocket::readyRead, this, &MavlinkUdp::onReadyRead);
    connect(&hbTimer, &QTimer::timeout, this, &MavlinkUdp::sendHeartbeat);
    hbTimer.start(1000);
}

void MavlinkUdp::sendHeartbeat() {
    mavlink_message_t msg;
    uint8_t buf[MAVLINK_MAX_PACKET_LEN];
    mavlink_msg_heartbeat_pack(sysid, compid, &msg,
                               MAV_TYPE_GCS, MAV_AUTOPILOT_INVALID, 0, 0, MAV_STATE_ACTIVE);
    uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    socket.writeDatagram(reinterpret_cast<const char*>(buf), len, dest, dport);
}

void MavlinkUdp::onReadyRead() {
    while (socket.hasPendingDatagrams()) {
        QByteArray d; d.resize(int(socket.pendingDatagramSize()));
        socket.readDatagram(d.data(), d.size());
        for (auto ch : d) {
            if (mavlink_parse_char(MAVLINK_COMM_0, static_cast<uint8_t>(ch), &rxMsg, &rxStatus)) {
                if (rxMsg.msgid == MAVLINK_MSG_ID_HEARTBEAT) {
                    emit heartbeatReceived(rxMsg.sysid, rxMsg.compid);
                }
            }
        }
    }
}
