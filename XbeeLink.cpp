#include <QDebug>
#include "XbeeLink.h"

XbeeLink::XbeeLink(QObject *p) : QObject(p)
{
    connect(&serial_, &QSerialPort::readyRead, this, &XbeeLink::onReadyRead);
}
bool XbeeLink::open(const QString &port, int baud)
{
    if (serial_.isOpen())
        serial_.close();
    serial_.setPortName(port);
    serial_.setBaudRate(baud);
    serial_.setDataBits(QSerialPort::Data8);
    serial_.setParity(QSerialPort::NoParity);
    serial_.setStopBits(QSerialPort::OneStop);
    serial_.setFlowControl(QSerialPort::NoFlowControl);
    if (!serial_.open(QIODevice::ReadWrite))
    {
        emit linkError(QString("Open failed: %1").arg(serial_.errorString()));
        return false;
    }
    return true;
}
void XbeeLink::close() { serial_.close(); }
bool XbeeLink::writeBytes(const QByteArray &b)
{
    if (!serial_.isOpen())
        return false;
    auto n = serial_.write(b);
    return n == b.size();
    // const char* myString = "hi";
    // QByteArray bytes(myString);
    // auto n = serial_.write(bytes);
    // return n == bytes.size();
}
void XbeeLink::onReadyRead()
{
    const QByteArray data = serial_.readAll();
    QString string = QString::fromUtf8(data);
    emit bytesReceived(data);
    qDebug() << "This is the data recieved:" << string;
}
