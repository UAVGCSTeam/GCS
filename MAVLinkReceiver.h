#pragma once
#include <QObject>
#include <QByteArray>
#include <memory>
#include "UARTLink.h"
#include "UDPLink.h"

extern "C" {
#if __has_include(<mavlink/common/mavlink.h>)
#include <mavlink/common/mavlink.h>
#else
#include <common/mavlink.h>
#endif
}



struct RxMavlinkMsg {
    quint8 sysid, compid;
    quint32 msgid;
    QByteArray payload;
};
Q_DECLARE_METATYPE(RxMavlinkMsg)

class MAVLinkReceiver : public QObject {
    Q_OBJECT
public:
    explicit MAVLinkReceiver(QObject* parent=nullptr);
    ~MAVLinkReceiver();
    RxMavlinkMsg getMAVLinkFromBytes(const QByteArray& data);

    /**
     * Parse bytes as MAVLink using a fresh parser state (no shared state with other streams).
     * Use this for the first packet from a new peer so decoding is not corrupted by
     * previous packets from other peers. See getMAVLinkFromBytes for shared-state parsing.
     */
    RxMavlinkMsg getMAVLinkFromBytesWithFreshState(const QByteArray& data);

public slots:
    void onBytes(const QByteArray& data, uint16_t senderPort);
    // void onBytes(const QByteArray& data);

signals:
    void messageReceived(const RxMavlinkMsg& m);

private:
    struct Impl;                        // forward-declared
    std::unique_ptr<Impl> d_;           // OK with out-of-line dtor
};
