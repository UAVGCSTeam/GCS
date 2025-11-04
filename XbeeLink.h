#pragma once
#include <QObject>
#include <QSerialPort>
#include <QByteArray>

class XbeeLink : public QObject {
    Q_OBJECT
public:
    explicit XbeeLink(QObject* parent=nullptr);
    bool   open(const QString& portName, int baud=57600);
    void   close();
    bool   isOpen() const { return serial_.isOpen(); }
    qint64 writeBytes(const QByteArray& bytes);

signals:
    void bytesReceived(const QByteArray& bytes);
    void linkError(const QString& msg);
    // optional:
    // void opened();
    // void closed();

private slots:
    void onReadyRead();

private:
    QSerialPort serial_;
};
