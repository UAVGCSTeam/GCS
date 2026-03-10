#pragma once
#include <QObject>
#include <QByteArray>
#include <memory>


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
    ~MAVLinkReceiver();                 // ← add this (no inline definition)

public slots:
    void onBytes(const QByteArray& data);

signals:
    void messageReceived(const RxMavlinkMsg& m);

private:
    struct Impl;                        // forward-declared
    std::unique_ptr<Impl> d_;           // OK with out-of-line dtor
};
