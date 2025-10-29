#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QTimer>
#include <QDir>
#include <QtQuickControls2/QQuickStyle>
#include "mapcontroller.h"
#include "filehandler.h"
#include "backend/dbmanager.h"
#include "dronecontroller.h"
#include "ErrorHandler.h"

// Function to start the Python XBee script
QProcess* startXbeeProcess() {
    QProcess* pythonProcess = new QProcess();

    // Connect signals to handle process output and errors
    QObject::connect(pythonProcess, &QProcess::readyReadStandardOutput, [pythonProcess]() {
        QByteArray output = pythonProcess->readAllStandardOutput();
        qDebug() << "Python output:" << output;
    });

    QObject::connect(pythonProcess, &QProcess::readyReadStandardError, [pythonProcess]() {
        QByteArray error = pythonProcess->readAllStandardError();
        qWarning() << "Python error:" << error;
    });

    // Find the bootstrap script
    QStringList possiblePaths = {
        QDir::currentPath() + "/setup_and_run_xbee.py",
        QCoreApplication::applicationDirPath() + "/setup_and_run_xbee.py",
        QDir(QCoreApplication::applicationDirPath()).absoluteFilePath("../setup_and_run_xbee.py"),
        QDir(QCoreApplication::applicationDirPath()).absoluteFilePath("../../GCS/setup_and_run_xbee.py"),
        // Your actual source directory
        // PLEASE UPDATE
        // The top paths are in the BUILD directory
        // For testing purposes, just put your direct path
        // HERE
        "/GCS_Codes/qtGCS/GCS/GCS/setup_and_run_xbee.py"
        // HERE
    };

    // Debug: Print all paths being checked
    qDebug() << "Searching for bootstrap script in the following locations:";
    for (const QString &path : possiblePaths) {
        qDebug() << "  " << path << (QFileInfo::exists(path) ? " (exists)" : " (not found)");
    }

    QString scriptPath;
    for (const QString &path : possiblePaths) {
        QFileInfo fileInfo(path);
        if (fileInfo.exists() && fileInfo.isReadable()) {
            scriptPath = path;
            break;
        }
    }

    if (scriptPath.isEmpty()) {
        qWarning() << "Bootstrap script not found";
        delete pythonProcess;
        return nullptr;
    }

    qDebug() << "Found bootstrap script at:" << scriptPath;

    // Set the working directory to where the script is located
    QFileInfo fileInfo(scriptPath);
    pythonProcess->setWorkingDirectory(fileInfo.dir().absolutePath());

    // Start the bootstrap script with the system Python
#ifdef Q_OS_WIN
    pythonProcess->start("python", QStringList() << scriptPath);
#else
    pythonProcess->start("python3", QStringList() << scriptPath);
#endif

    // Wait for it to start
    if (!pythonProcess->waitForStarted(5000)) {
        qWarning() << "Failed to start Python process:" << pythonProcess->errorString();
        delete pythonProcess;
        return nullptr;
    }

    return pythonProcess;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    // Force a non-native style so customization is supported
    QQuickStyle::setStyle("Basic");

    /*
     * We want to use QQmlApplicationEngine as it provides more resources for our use case
     * https://doc.qt.io/qt-6/qqmlapplicationengine.html
    */

    // Start the Python XBee script
    QProcess* pythonProcess = startXbeeProcess();
    if (pythonProcess) {
        qDebug() << "XBee Python script started successfully";

        // Clean up when the application exits
        QObject::connect(&app, &QCoreApplication::aboutToQuit, [pythonProcess]() {
            if (pythonProcess->state() == QProcess::Running) {
                pythonProcess->terminate();
                if (!pythonProcess->waitForFinished(3000)) {
                    pythonProcess->kill();
                }
            }
            delete pythonProcess;
        });
    } else {
        qWarning() << "Failed to start XBee Python script";
    }

    // If the database doesn't exist, it will create the database. The following code intializes the drones Table.
    DBManager gcs_db_manager;
    gcs_db_manager.initDB();
    qDebug() << "Database started successfully.";

    // TODO: Intialize and make UI button click reach database

    QQmlApplicationEngine engine;

    // Expose ErrorHandler as a singleton
    qmlRegisterSingletonType<ErrorHandler>("ErrorHandler", 1, 0, "ErrorHandler", 
        [](QQmlEngine*, QJSEngine*) -> QObject* {
        return new ErrorHandler();
    });
    // ErrorHandler errorHandler;
    // engine.rootContext()->setContextProperty("ErrorHandler", &errorHandler);

    // Create and register MapController as an object that the cpp can use
    MapController mapController;
    engine.rootContext()->setContextProperty("mapController", &mapController);

    // Register the FileHandler class so that it can be used in QML
    qmlRegisterType<FileHandler>("com.gcs.filehandler", 1, 0, "FileHandler");

    // Register droneclass to QML
    qmlRegisterUncreatableType<DroneClass>(
        "com.gcs.dronecontroller", 1, 0, "DroneClass",
        "DroneClass cannot be created from QML");

    // Expose dronecontroller to QML
    qmlRegisterType<DroneController>("com.gcs.dronecontroller", 1, 0, "DroneController");
    DroneController droneController(gcs_db_manager);
    // Expose to QML
    engine.rootContext()->setContextProperty("droneController", &droneController);

    // Start XBee monitoring after Python script has started
    if (pythonProcess) {
        QTimer::singleShot(1000, &droneController, &DroneController::startXbeeMonitoring);
    }

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    /*
     * main.qml is our entry point for all of our UI/GUI resources.
     * It calls all of our QML files needed to create and display our GUI
     * As such, it allows for us to create very modular UI displays
    */

    // Creates the root object, which is the engine that runs the program
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
