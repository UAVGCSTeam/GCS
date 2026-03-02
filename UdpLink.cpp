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
        qWarning() << "[UdpLink] Bind failed on port" << localPort << ":" << socket_.errorString();
        emit linkError(QString("Bind failed: %1").arg(socket_.errorString()));
        return false;
    }
    qInfo() << "[UdpLink] Bound to port" << localPort << "- receiving on 0.0.0.0:" << localPort
            << "(outgoing ->" << remoteHost_.toString() << ":" << remotePort_ << ")";
    return true;
}

bool UdpLink::listen(quint16 port) {
    if (socket_.state() == QAbstractSocket::BoundState) socket_.close();
    if (!socket_.bind(QHostAddress::AnyIPv4, port)) {
        qWarning() << "[UdpLink] Listen bind failed on port" << port << ":" << socket_.errorString();
        emit linkError(QString("Bind failed: %1").arg(socket_.errorString()));
        return false;
    }
    qInfo() << "[UdpLink] Listening on port" << port << "(0.0.0.0:" << port << ")";
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
        const qint64 size = socket_.pendingDatagramSize();
        if (size <= 0) continue;
        QByteArray datagram(static_cast<int>(size), 0);
        socket_.readDatagram(datagram.data(), datagram.size());
        emit bytesReceived(datagram);
    }
}
