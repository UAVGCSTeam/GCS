#pragma once
#include <QObject>
#include <QSerialPort>

class XbeeLink : public QObject {
    Q_OBJECT
public:
    explicit XbeeLink(QObject* parent=nullptr);
    bool open(const QString& portName, int baud=57600);
    void close();
    bool isOpen() const { return serial_.isOpen(); }
    bool writeBytes(const QByteArray& bytes);  // raw pass-through
signals:
    void bytesReceived(QByteArray bytes);
    void linkError(QString msg);
private:
    QSerialPort serial_;
private slots:
    void onReadyRead();
};
