#ifndef LOGGER_H
#define LOGGER_H

#include <QtLogging>
#include <QCoreApplication>
#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QMutex>
#include <QDir>

class Logger : public QObject
{
    Q_OBJECT

    public:
        static void init();
        static void close();
        static Logger* instance();

        static void newEntry(QtMsgType type, const QMessageLogContext &context, const QString &msg);

    signals:
        void logEntryAdded(const QString &type, const QString &message);

    private:
        explicit Logger(QObject *parent = nullptr);

        static QMutex mutex;
        static QFile* logFile;
        static QString logs;
        static Logger* s_instance;

        static QString devBuildRoot();
};

#endif // LOGGER_H
