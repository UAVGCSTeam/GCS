#include "UDPLink.h"

UDPLink::UDPLink(QObject* p) : QObject(p) {
    connect(&socket_, &QUdpSocket::readyRead, this, &UDPLink::onReadyRead);
}

bool UDPLink::open(quint16 localPort,
                   const QHostAddress& remoteHost,
                   quint16 remotePort) {
    Q_UNUSED(remoteHost);
    Q_UNUSED(remotePort);

    if (socket_.state() == QAbstractSocket::BoundState) {
        socket_.close();
    }

    _hasPeer = false;
    _remoteAddress = QHostAddress();

    if (!socket_.bind(QHostAddress::AnyIPv4, localPort)) {
        qWarning() << "Bind failed on port" << localPort << ":" << socket_.errorString();
        emit linkError(QString("Bind failed: %1").arg(socket_.errorString()));
        return false;
    }
    qInfo() << "Bound to 0.0.0.0:" << localPort
            << "(dynamic peer; waiting for first datagram)";
    return true;
}

bool UDPLink::listen(quint16 port) {
    if (socket_.state() == QAbstractSocket::BoundState) socket_.close();
    if (!socket_.bind(QHostAddress::AnyIPv4, port)) {
        qWarning() << "Listen bind failed on port" << port << ":" << socket_.errorString();
        emit linkError(QString("Bind failed: %1").arg(socket_.errorString()));
        return false;
    }
    qInfo() << "Listening on port" << port << "(0.0.0.0:" << port << ")";
    return true;
}

void UDPLink::close() { socket_.close(); }

qint64 UDPLink::writeBytes(const QByteArray& b, quint16 remotePort) {
    if (socket_.state() != QAbstractSocket::BoundState) {
        qWarning() << "WriteBytes(port): socket not bound, state=" << socket_.state();
        return -1;
    }
    if (!_hasPeer) {
        qWarning() << "WriteBytes(port): no remote peer discovered yet; dropping" << b.size() << "bytes";
        return -1;
    }
    if (_remoteAddress == QHostAddress()) {
        qWarning() << "WriteBytes(port): no remote address discovered yet; dropping" << b.size() << "bytes";
        return -1;
    }
    const qint64 n = socket_.writeDatagram(b, _remoteAddress, remotePort);
    if (n == -1) {
        qWarning() << "WriteDatagram failed:" << socket_.errorString()
                   << "to" << _remoteAddress.toString() << ":" << remotePort;
        emit linkError(socket_.errorString());
    } else {
        qDebug() << "Sent" << n << "bytes to" << _remoteAddress.toString() << ":" << remotePort;
    }
    return n;
}

void UDPLink::onReadyRead() {
    readPendingDatagrams();
}

void UDPLink::readPendingDatagrams() {
    while (socket_.hasPendingDatagrams()) {
        QNetworkDatagram datagram = socket_.receiveDatagram();
        if (!datagram.isValid()) { continue; }
        const QHostAddress senderAddress = datagram.senderAddress();
        if (senderAddress != _remoteAddress) { _remoteAddress = senderAddress; }
        emit bytesReceived(datagram.data(), datagram.senderPort());
        _hasPeer = true;
    }
}
