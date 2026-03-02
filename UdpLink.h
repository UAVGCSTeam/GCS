#pragma once
#include <QObject>
#include <QUdpSocket>
#include <QByteArray>
#include <QHostAddress>
#include <QDebug>

class UdpLink : public QObject {
    Q_OBJECT
public:
    explicit UdpLink(QObject* parent = nullptr);

    /**
     * @brief Opens and binds the UDP link to a local port and configures the remote endpoint.
     *
     * This function initializes the UDP socket for communication by:
     * - Closing the socket if it is already in a bound state.
     * - Storing the specified remote host and port for outgoing datagrams.
     * - Binding the socket to the given local port on all IPv4 interfaces
     *   (QHostAddress::AnyIPv4).
     *
     * If binding fails, a warning is logged, the linkError() signal is emitted,
     * and the function returns false.
     *
     * @param localPort   Local UDP port to bind to for receiving datagrams.
     * @param remoteHost  Remote host address for outgoing datagrams.
     * @param remotePort  Remote UDP port for outgoing datagrams.
     *
     * @return true if the socket was successfully bound; false otherwise.
     *
     * @note The socket binds to 0.0.0.0 (all IPv4 interfaces). If the socket is
     *       already bound, it will be closed before attempting to rebind.
     *
     * @warning Only IPv4 is used (AnyIPv4). IPv6 is not supported by this bind call.
     */
    bool   open(quint16 localPort,
                const QHostAddress& remoteHost = QHostAddress::LocalHost,
                quint16 remotePort = 14550);

    /// Bind to @p port and receive any UDP datagrams sent to it (from any host). Use for listen-only.
    bool   listen(quint16 port);
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
