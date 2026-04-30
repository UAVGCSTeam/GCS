#ifndef LOGGER_H
#define LOGGER_H

#include <QtLogging>
#include <QCoreApplication>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QMutex>
#include <QDir>

class Logger : public QObject
{
    Q_OBJECT
    public:
        explicit Logger(QObject *parent = nullptr);
        static Logger* instance();
        
        static void init();
        static void close();

        static void newEntry(QtMsgType type, const QMessageLogContext &context, const QString &msg);

    signals:
        void logReceived(const QString &type, const QString &message);

    private slots:
        void forwardLog(const QString &type, const QString &message);

    private:
        static QMutex mutex;
        static QFile* logFile;
        static QString logs;
        static QtMessageHandler previousHandler;
        static Logger* s_instance;

        static QString devBuildRoot();
        static QString typeToString(QtMsgType type);
};

#endif // LOGGER_H
