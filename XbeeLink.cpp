#include "XbeeLink.h"
#include <QDebug>


// include mavlink (common dialect), handle both folder layouts
#if __has_include(<mavlink/common/mavlink.h>)
extern "C" {
#include <mavlink/common/mavlink.h>
}
#elif __has_include(<common/mavlink.h>)
extern "C" {
#include <common/mavlink.h>
}
#else
#error "Cannot find MAVLink headers. Check CMake include dirs and submodule path."
#endif



XbeeLink::XbeeLink(QObject* p):QObject(p){
    connect(&serial_, &QSerialPort::readyRead, this, &XbeeLink::onReadyRead);
}
bool XbeeLink::open(const QString& port, int baud){
    if (serial_.isOpen()) serial_.close();
    serial_.setPortName(port);
    serial_.setBaudRate(baud);
    serial_.setDataBits(QSerialPort::Data8);
    serial_.setParity(QSerialPort::NoParity);
    serial_.setStopBits(QSerialPort::OneStop);
    serial_.setFlowControl(QSerialPort::NoFlowControl);
    if(!serial_.open(QIODevice::ReadWrite)){
        emit linkError(QString("Open failed: %1").arg(serial_.errorString()));
        return false;
    }
    return true;
}
void XbeeLink::close(){ serial_.close(); }
bool XbeeLink::writeBytes(const QByteArray& b){
    if(!serial_.isOpen()) return false;
    auto n = serial_.write(b);  
    return n == b.size();
}
// void XbeeLink::onReadyRead()
// {
//     auto data = serial_.readAll();
//     emit bytesReceived(serial_.readAll());
//     qDebug() << "This is the data recieved:" << data;
// }


void XbeeLink::onReadyRead()
{
    QByteArray data = serial_.readAll();
    static mavlink_message_t msg;
    static mavlink_status_t status;

    for (uint8_t byte : data) {
        if (mavlink_parse_char(MAVLINK_COMM_0, byte, &msg, &status)) {
            // A complete MAVLink message was received
            qDebug() << "Received MAVLink msgid:" << msg.msgid;

            switch (msg.msgid) {
            case MAVLINK_MSG_ID_HEARTBEAT: {
                mavlink_heartbeat_t hb;
                mavlink_msg_heartbeat_decode(&msg, &hb);
                qDebug() << "Heartbeat from system" << msg.sysid
                         << "component" << msg.compid
                         << "type:" << hb.type
                         << "autopilot:" << hb.autopilot;
                break;
            }
            case MAVLINK_MSG_ID_SYS_STATUS: {
                mavlink_sys_status_t status_msg;
                mavlink_msg_sys_status_decode(&msg, &status_msg);
                qDebug() << "Battery:" << status_msg.voltage_battery / 1000.0 << "V";
                break;
            }
            // Add more cases as needed
            default:
                break;
            }
        }
    }
}
