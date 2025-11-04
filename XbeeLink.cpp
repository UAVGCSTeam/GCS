#include "XbeeLink.h"

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
qint64 XbeeLink::writeBytes(const QByteArray& b){
    if (!serial_.isOpen()) return -1;
    const qint64 n = serial_.write(b);      // QSerialPort::write returns qint64
    if (n == -1) emit linkError(serial_.errorString());
    return n;
}

void XbeeLink::onReadyRead(){
    emit bytesReceived(serial_.readAll());

}
