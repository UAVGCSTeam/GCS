#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "mapcontroller.h"
#include "backend/dbmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    /*
     * We want to use QQmlApplicationEngine as it provides more resources for our use case
     * https://doc.qt.io/qt-6/qqmlapplicationengine.html
    */

    // TODO: Intialize Database

    // 1. Create a connection to the Database. If there's exisiting database, connect to it
    DBManager gcs_DBManager("gcs.db");

    // Since SQLite actually will always open a new db if it can't connect to it, this code is redudant.
    if (!gcs_DBManager.isOpen()) {
        qCritical() << "Error: Could not open database.";
        return -1;
    }

    // If the database doesn't exist, it will create the database. The following code intializes the drones Table.
    gcs_DBManager.initDB();
    qDebug() << "Database initialized successfully.";


    QQmlApplicationEngine engine;

    // Create and register MapController as an object that the cpp can use
    MapController mapController;
    engine.rootContext()->setContextProperty("mapController", &mapController);

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
