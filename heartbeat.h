#pragama once
#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QElapsedTimer>
#include "common/mavlink.h"     // from extern/mavlink


class Heartbeat : public QObject {
    Q_OBJECT
public:
    explicit Heartbeat(QSerialPort* serial, QObject* parent=nullptr);

    void setPeriodMs(int ms) { hbPeriodMs_ = ms; }

signals:
    void linkOKChanged(bool ok);

public slots:
    void start();
    void stop();
    void onSerialReadyRead();   // connect to serial->readyRead()

private:
    void sendHeartbeat();
    void feedParser(const QByteArray& bytes);
    void checkWatchdog();

    QSerialPort* serial_;
    QTimer hbTimer_;
    QTimer wdTimer_;
    QElapsedTimer clk_;

    // IDs
    uint8_t gcsSysId_ = 255; //GCS
    uint8_t gcsCompId_ = MAV_COMP_ID_MISSIONPLANNER;
    uint8_t uavSysId_ = 1;  // set to vehicle sysid
    uint8_t uavCompId_ = MAV_COMP_ID_AUTOPILOT1;

    // State
    bool linkOk_ = false;
    qint64 lastHeardMs_ = -1;

    //Parser state
    mavlink_message_t rxMsg_{};
    mavlink_status_t rxStatus_{};

    // Config
    int hbPeriodMs_ = 1000;
    int lossThresholdMs_ = 3 * 1000;
};
