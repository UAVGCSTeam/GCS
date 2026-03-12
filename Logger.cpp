#include "Logger.h"
#include <QFileInfo>

//define static variables
QFile*  Logger::logFile = nullptr;
QMutex  Logger::mutex;
QString Logger::logs;
Logger* Logger::s_instance = nullptr;

Logger::Logger(QObject *parent) : QObject(parent) {}

Logger* Logger::instance()
{
    return s_instance;
}

void Logger::init()
{
    s_instance = new Logger();

    //get file name
    QString basePath = devBuildRoot();
    QString logDir = basePath + "/log";

    QDir().mkpath(logDir);

    QDateTime time = QDateTime::currentDateTime();
    QString name = logDir + "/" + QDateTime::currentDateTime().toString("yyyy-MM-dd-hh-mm-ss") + ".log";

    //open file
    logFile = new QFile(name);
    if (!logFile->open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Failed to open file:" << logFile->errorString();
        return;
    }

    qInstallMessageHandler(newEntry);
}

void Logger::close()
{
    QMutexLocker locker(&mutex);

    //pass all logs
    QTextStream out(logFile);
    out << logs << Qt::endl;
    out.flush();

    //clear message handler
    qInstallMessageHandler(0);

    //close file
    logFile->flush();
    logFile->close();

    //cleaner way to do this with Q?
    delete logFile;
    logFile = nullptr;
    // s_instance kept alive until app exit (queued emits may still be pending)
}

void Logger::newEntry(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    //get message timestamp
    QDateTime time = QDateTime::currentDateTime();

    QString typeStr;
    switch (type) {
        case QtDebugMsg:    typeStr = "debug";    break;
        case QtInfoMsg:     typeStr = "info";     break;
        case QtWarningMsg:  typeStr = "warning";  break;
        case QtCriticalMsg: typeStr = "critical"; break;
        case QtFatalMsg:    typeStr = "fatal";    break;
    }

    {
        QMutexLocker locker(&mutex);

        QString entry;
        switch (type) {
            case QtDebugMsg:    entry += "[Debug] ";    break;
            case QtInfoMsg:     entry += "[Info] ";     break;
            case QtWarningMsg:  entry += "[Warning] ";  break;
            case QtCriticalMsg: entry += "[Critical] "; break;
            case QtFatalMsg:    entry += "[Fatal] ";    break;
        }
        entry += time.toString(" yyyy.MM.dd hh:mm:ss ");
        entry += QString(" (%1:%2)  ").arg(QFileInfo(QString::fromUtf8(context.file)).fileName()).arg(context.line);
        entry += msg;
        entry += "\n";
        logs += entry;
    }

    // emit for QML panel: qDebug and qInfo (commands use qInfo)
    if (s_instance && (type == QtDebugMsg || type == QtInfoMsg))
        QMetaObject::invokeMethod(s_instance, [typeStr, msg]() {
            emit s_instance->logEntryAdded(typeStr, msg);
        }, Qt::QueuedConnection);
}

QString Logger::devBuildRoot()
{
    QString exeDir = QCoreApplication::applicationDirPath();
    QDir dir(exeDir);

    #ifdef Q_OS_MAC
        dir = QDir::cleanPath(dir.dirName() + QStringLiteral("/../../../.."));
    #endif

    return dir.absolutePath();
}
