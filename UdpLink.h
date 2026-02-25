#pragma once
#include <QObject>
#include <QUdpSocket>
#include <QByteArray>
#include <QHostAddress>

class UdpLink : public QObject {
    Q_OBJECT
public:
    explicit UdpLink(QObject* parent = nullptr);

    /// Bind to @p localPort and direct outgoing datagrams to @p remoteHost:@p remotePort.
    bool   open(quint16 localPort,
                const QHostAddress& remoteHost = QHostAddress::LocalHost,
                quint16 remotePort = 14550);
    void   close();
    bool   isOpen() const { return socket_.state() == QAbstractSocket::BoundState; }
    qint64 writeBytes(const QByteArray& bytes);

signals:
    void bytesReceived(const QByteArray& bytes);
    void linkError(const QString& msg);

private slots:
    void onReadyRead();

private:
    QUdpSocket  socket_;
    QHostAddress remoteHost_;
    quint16      remotePort_{14550};
};
