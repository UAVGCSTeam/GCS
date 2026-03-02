#include "UdpLink.h"

UdpLink::UdpLink(QObject* p) : QObject(p) {
    connect(&socket_, &QUdpSocket::readyRead, this, &UdpLink::onReadyRead);
}

bool UdpLink::open(quint16 localPort,
                   const QHostAddress& remoteHost,
                   quint16 remotePort) {
    Q_UNUSED(remoteHost);
    Q_UNUSED(remotePort);

    if (socket_.state() == QAbstractSocket::BoundState) {
        socket_.close();
    }

    _hasPeer = false;
    _remoteAddress = QHostAddress();
    _remotePort = 0;

    if (!socket_.bind(QHostAddress::AnyIPv4, localPort)) {
        qWarning() << "[UdpLink::open] Bind failed on port" << localPort << ":" << socket_.errorString();
        emit linkError(QString("Bind failed: %1").arg(socket_.errorString()));
        return false;
    }
    qInfo() << "[UdpLink::open] Bound to 0.0.0.0:" << localPort
            << "(dynamic peer; waiting for first datagram)";
    return true;
}

bool UdpLink::listen(quint16 port) {
    if (socket_.state() == QAbstractSocket::BoundState) socket_.close();
    if (!socket_.bind(QHostAddress::AnyIPv4, port)) {
        qWarning() << "[UdpLink::listen] Listen bind failed on port" << port << ":" << socket_.errorString();
        emit linkError(QString("Bind failed: %1").arg(socket_.errorString()));
        return false;
    }
    qInfo() << "[UdpLink::listen] Listening on port" << port << "(0.0.0.0:" << port << ")";
    return true;
}

void UdpLink::close() { socket_.close(); }

qint64 UdpLink::writeBytes(const QByteArray& b) {
    if (socket_.state() != QAbstractSocket::BoundState) {
        qWarning() << "[UdpLink::writeBytes] writeBytes: socket not bound, state=" << socket_.state();
        return -1;
    }
    if (!_hasPeer) {
        qWarning() << "[UdpLink::writeBytes] writeBytes: no remote peer discovered yet; dropping" << b.size() << "bytes";
        return -1;
    }

    const qint64 n = socket_.writeDatagram(b, _remoteAddress, _remotePort);
    if (n == -1) {
        qWarning() << "[UdpLink::writeBytes] writeDatagram failed:" << socket_.errorString()
                   << "to" << _remoteAddress.toString() << ":" << _remotePort;
        emit linkError(socket_.errorString());
    } else {
        qDebug() << "[UdpLink::writeBytes] sent" << n << "bytes to" << _remoteAddress.toString() << ":" << _remotePort;
    }
    return n;
}

void UdpLink::onReadyRead() {
    readPendingDatagrams();
}

void UdpLink::readPendingDatagrams() {
    while (socket_.hasPendingDatagrams()) {
        QNetworkDatagram datagram = socket_.receiveDatagram();
        if (!datagram.isValid()) {
            continue;
        }

        const QHostAddress senderAddress = datagram.senderAddress();
        const quint16 senderPort = datagram.senderPort();

        if (!_hasPeer || senderAddress != _remoteAddress || senderPort != _remotePort) {
            _remoteAddress = senderAddress;
            _remotePort = senderPort;
            _hasPeer = true;
            qInfo() << "[UdpLink::readPendingDatagrams] Remote peer set to" << _remoteAddress.toString() << ":" << _remotePort;
        }

        emit bytesReceived(datagram.data());
    }
}
