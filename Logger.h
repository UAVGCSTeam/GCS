#ifndef LOGGER_H
#define LOGGER_H

#include <QtLogging>
#include <QCoreApplication>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QMutex>
#include <QDir>

class Logger
{
    public:
        static void init();
        static void close();

        static void newEntry(QtMsgType type, const QMessageLogContext &context, const QString &msg);

    private:
        static QMutex mutex;

        static QFile* logFile;

        static QString devBuildRoot();
};

#endif // LOGGER_H
