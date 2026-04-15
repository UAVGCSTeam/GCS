#include "Logger.h"

//define static variables
QFile*  Logger::logFile = nullptr;
QMutex  Logger::mutex;
QString Logger::logs;
Logger* Logger::s_instance = nullptr;

Logger* Logger::instance() {
    if (!s_instance) s_instance = new Logger();
    return s_instance;
}

Logger::Logger(QObject *parent)
    : QObject(parent)
{
}

void Logger::init()
{
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

}

QString Logger::typeToString(QtMsgType type) {
    switch(type) {
        case QtDebugMsg: return "Debug";
        case QtInfoMsg: return "Info";
        case QtWarningMsg: return "Warning";
        case QtCriticalMsg: return "Critical";
        case QtFatalMsg: return "Fatal";
        default: return "Unknown";
    }
    return "Info";
}

void Logger::newEntry(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    //get message timestamp
    QDateTime time = QDateTime::currentDateTime();

    //ensure thread safety
    QMutexLocker locker(&mutex);

    QString entry;

    //get type of message and add in outptut
    switch(type)
    {
        case QtDebugMsg:    entry += "[Debug] ";    break;
        case QtInfoMsg:     entry += "[Info] ";     break;
        case QtWarningMsg:  entry += "[Warning] ";  break;
        case QtCriticalMsg: entry += "[Critical] "; break;
        case QtFatalMsg:    entry += "[Fatal] ";    break;
    }

    //add time to output
    entry += time.toString(" yyyy.MM.dd hh:mm:ss ");

    //add context to output (line and file)
    entry += QString(" (%1:%2)  ").arg(QFileInfo(QString::fromUtf8(context.file)).fileName()).arg(context.line);

    //add message given by user
    entry += msg;
    entry += "\n";

    //pass entry to log str
    logs += entry;

    Logger* instance = Logger::instance();
    const QString typeStr = typeToString(type);

    QMetaObject::invokeMethod(
        instance,
        "forwardLog",
        Qt::QueuedConnection,
        Q_ARG(QString, typeStr),
        Q_ARG(QString, msg)
    );
}

void Logger::forwardLog(const QString &type, const QString &message) {
    emit logReceived(type, message);
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
