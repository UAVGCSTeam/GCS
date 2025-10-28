#ifndef MAVLINKRECEIVER_H
#define MAVLINKRECEIVER_H

#include <QObject>

// include mavlink (common dialect), handle both folder layouts
#if __has_include(<mavlink/common/mavlink.h>)
extern "C"
{
#include <mavlink/common/mavlink.h>
}
#elif __has_include(<common/mavlink.h>)
extern "C"
{
#include <common/mavlink.h>
}
#else
#error "Cannot find MAVLink headers. Check CMake include dirs and submodule path."
#endif


class MavlinkReceiver : public QObject {
    Q_OBJECT
public:
    MavlinkReceiver(QObject* parent=nullptr);
public slots:
    void unpackMessage(const QByteArray& data);

private:
    void decodeType(const mavlink_message_t& msg);

    mavlink_message_t msg_{};
    mavlink_status_t  status_{}; // keeps parse state across calls
};

#endif // MAVLINKRECEIVER_H
