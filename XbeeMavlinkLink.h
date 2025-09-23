#pragma once
#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QElapsedTimer>
#include "common/mavlink.h"

class XbeeMavlinkLink : public QObject {
    Q_OBJECT
public:
    explicit XbeeMavlinkLink(QSerialPort* port, QObject* parent=nullptr);
    void start();
    void send(const mavlink_message_t& msg);
signals:
    void messageReceived(const mavlink_message_t& msg);
    void linkOkChanged(bool ok);
private slots:
    onReadyRead();
    void checkWatchdog();
private:
    QSerialPort* port_;
    mavlink_message_t rxMsg_{};
    mavlink_status_t rxStatus_{};
    QTimer watchdog_;
    QElapsedTimer clk_;
    qint64 lastHeardMs_= -1;
};
