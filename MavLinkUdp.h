#pragma once
#include <QObject>
#include <QUdpSocket>
#include <QTimer>
#include <QHostAddress>
#include <mavlink/common/mavlink.h>

class MavlinkUdp : public QObject {
    Q_OBJECT
public:
    explicit MavlinkUdp(QString dstIp="127.0.0.1", quint16 dstPort=14550, quint16 localPort=14551, QObject* parent=nullptr);
    void sendHeartbeat();

signals:
    void heartbeatReceived(uint8_t sysid, uint8_t compid);

private slots:
    void onReadyRead();

private:
    QUdpSocket socket;
    QTimer hbTimer;
    QHostAddress dest;
    quint16 dport;
    uint8_t sysid = 255;
    uint8_t compid = MAV_COMP_ID_MISSIONPLANNER;
    mavlink_message_t rxMsg{};
    mavlink_status_t rxStatus{};
};
