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

qint64 UDPLink::writeBytes(const QByteArray& b, uint8_t targetSysID) {
    int remotePort = _remotePortsMap.value(targetSysID);
    if (socket_.state() != QAbstractSocket::BoundState) {
        qWarning() << "WriteBytes: socket not bound, state=" << socket_.state();
        return -1;
    }
    if (!_hasPeer) {
        qWarning() << "writeBytes: no remote peer discovered yet; dropping" << b.size() << "bytes";
        return -1;
    }

    const qint64 n = socket_.writeDatagram(b, _remoteAddress, static_cast<quint16>(remotePort));
    if (n == -1) {
        qWarning() << "WriteDatagram failed:" << socket_.errorString()
                   << "to" << _remoteAddress.toString() << ":" << remotePort;
        emit linkError(socket_.errorString());
    } else {
        qDebug() << "Sent" << n << "bytes to" << _remoteAddress.toString() << ":" << remotePort;
    }
    return n;
}

qint64 UDPLink::writeBytes(const QByteArray& b, quint16 remotePort) {
    if (socket_.state() != QAbstractSocket::BoundState) {
        qWarning() << "WriteBytes(port): socket not bound, state=" << socket_.state();
        return -1;
    }
    if (!_hasPeer) {
        qWarning() << "WriteBytes(port): no remote peer discovered yet; dropping" << b.size() << "bytes";
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

bool UDPLink::remotePortExists(int targetPort) {
    uint8_t foundKey = -1;
    bool found = false;
    for (auto it = _remotePortsMap.constBegin(); it != _remotePortsMap.constEnd(); ++it) {
        if (it.value() == targetPort) {
            foundKey = it.key();
            found = true;
            break;
        }
    }
    
    return found;
}

void UDPLink::readPendingDatagrams() {
    while (socket_.hasPendingDatagrams()) {
        QNetworkDatagram datagram = socket_.receiveDatagram();
        if (!datagram.isValid()) {
            continue;
        }

        const QHostAddress senderAddress = datagram.senderAddress();
        const quint16 senderPort = datagram.senderPort();

        if (!remotePortExists(senderPort)) {
            // TODO: This needs to be updated so that the currentID matches the system ID 
            // of the incoming message. Right now it's just hardcoded to iterate through 
            _remoteAddress = senderAddress;
            _remotePortsMap.insert(_currentID, senderPort);
            qInfo() << "New remote peer added:" << _remoteAddress.toString() << ":" << senderPort << ":" << _currentID;
            _currentID++;
            _hasPeer = true;
            QByteArray payload = datagram.data();
            emit newUDPPeer(payload, static_cast<int>(senderPort));
        } else {
            emit bytesReceived(datagram.data());
        }
    }
}
