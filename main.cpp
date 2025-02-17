#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "mapcontroller.h"
#include "filehandler.h"
#include "backend/dbmanager.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    /*
     * We want to use QQmlApplicationEngine as it provides more resources for our use case
     * https://doc.qt.io/qt-6/qqmlapplicationengine.html
    */

    // If the database doesn't exist, it will create the database. The following code intializes the drones Table.
    DBManager gcs_db_manager;
    gcs_db_manager.initDB();
    qDebug() << "Database started successfully.";

    // TODO: Intialize and make UI button click reach database

    QQmlApplicationEngine engine;

    // Create and register MapController as an object that the cpp can use
    MapController mapController;
    engine.rootContext()->setContextProperty("mapController", &mapController);

    // Register the FileHandler class so that it can be used in QML
    qmlRegisterType<FileHandler>("com.gcs.filehandler", 1, 0, "FileHandler");
    //DroneController droneController(gcs_db_manager);
    // Expose to QML
    //engine.rootContext()->setContextProperty("droneController", &droneController);

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
