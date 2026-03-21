#pragma once
#include <QObject>
#include <QUdpSocket>
#include <QByteArray>
#include <QHostAddress>
#include <QDebug>
#include <QNetworkDatagram>

class UDPLink : public QObject {
    Q_OBJECT
public:
    explicit UDPLink(QObject* parent = nullptr);

    /**
     * function open()
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

    /**
     * function isOpen()
     * @brief Opens the UDP link in dynamic peer mode and binds to a local port.
     *
     * This function initializes the UDP socket for inbound communication only.
     * Unlike the fixed-peer variant, the provided @p remoteHost and @p remotePort
     * parameters are intentionally ignored. The remote endpoint is determined
     * dynamically from the first received datagram.
     *
     * The function performs the following steps:
     * - Closes the socket if it is already in a bound state.
     * - Clears any previously stored peer information.
     * - Binds the socket to the specified local port on all IPv4 interfaces
     *   (QHostAddress::AnyIPv4).
     *
     * If binding fails, a warning is logged, the linkError() signal is emitted,
     * and the function returns false.
     *
     * @param localPort   Local UDP port to bind to for receiving datagrams.
     * @param remoteHost  Unused. Present for API compatibility.
     * @param remotePort  Unused. Present for API compatibility.
     *
     * @return true if the socket was successfully bound; false otherwise.
     *
     * @note The socket binds to 0.0.0.0 (all IPv4 interfaces).
     * @note The remote peer is not known at open time and will be set upon
     *       receiving the first valid datagram.
     *
     * @warning Only IPv4 is used (AnyIPv4). IPv6 is not supported by this bind call.
     */
    bool   isOpen() const { return socket_.state() == QAbstractSocket::BoundState; }
    // Send to a specific remote port
    qint64 writeBytes(const QByteArray& bytes, quint16 remotePort);

private:

signals:
    void bytesReceived(const QByteArray& bytes, quint16 senderPort);
    void linkError(const QString& msg);

private slots:
    void onReadyRead();

private:

    /**
     * function readPendingDatagrams()
     * @brief Reads and processes all pending UDP datagrams from the socket.
     *
     * This function continuously retrieves incoming UDP datagrams from the internal
     * socket while data is available. For each valid datagram, it updates the stored
     * remote peer address (if it has changed), emits the received payload via the
     * bytesReceived signal, and marks that a peer has been detected.
     *
     * @details
     * - Iterates through all pending datagrams using a loop.
     * - Discards invalid datagrams.
     * - Tracks the most recent sender address as the active remote peer.
     * - Emits the raw datagram payload along with the sender's port.
     * - Sets the internal _hasPeer flag to true once at least one datagram is received.
     */
    void readPendingDatagrams();

    QUdpSocket  socket_;
    QHostAddress _remoteAddress; // The remote address (127.0.0.1 for example) will
                                 // be the same for all incoming connections 
    bool         _hasPeer{false};
};
