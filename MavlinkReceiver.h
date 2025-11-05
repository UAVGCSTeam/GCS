#pragma once
#include <QObject>
#include <QByteArray>
#include <memory>

struct RxMavlinkMsg {
    quint8 sysid, compid;
    quint32 msgid;
    QByteArray payload;
};
Q_DECLARE_METATYPE(RxMavlinkMsg)

class MavlinkReceiver : public QObject {
    Q_OBJECT
public:
    explicit MavlinkReceiver(QObject* parent=nullptr);
    ~MavlinkReceiver();                 // ← add this (no inline definition)

public slots:
    void onBytes(const QByteArray& data);

signals:
    void messageReceived(const RxMavlinkMsg& m);

private:
    struct Impl;                        // forward-declared
    std::unique_ptr<Impl> d_;           // OK with out-of-line dtor
};
