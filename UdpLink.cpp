#include "UdpLink.h"

UdpLink::UdpLink(QObject* p) : QObject(p) {
    connect(&socket_, &QUdpSocket::readyRead, this, &UdpLink::onReadyRead);
}

bool UdpLink::open(quint16 localPort,
                   const QHostAddress& remoteHost,
                   quint16 remotePort) {
    if (socket_.state() == QAbstractSocket::BoundState) socket_.close();
    remoteHost_ = remoteHost;
    remotePort_ = remotePort;
    if (!socket_.bind(QHostAddress::AnyIPv4, localPort)) {
        emit linkError(QString("Bind failed: %1").arg(socket_.errorString()));
        return false;
    }
    return true;
}

void UdpLink::close() { socket_.close(); }

qint64 UdpLink::writeBytes(const QByteArray& b) {
    if (socket_.state() != QAbstractSocket::BoundState) return -1;
    const qint64 n = socket_.writeDatagram(b, remoteHost_, remotePort_);
    if (n == -1) emit linkError(socket_.errorString());
    return n;
}

void UdpLink::onReadyRead() {
    while (socket_.hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(socket_.pendingDatagramSize());
        socket_.readDatagram(datagram.data(), datagram.size());
        emit bytesReceived(datagram);
    }
}
