#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include <QDebug>
#include <QProcess>
#include <QCoreApplication>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , pythonProcess(nullptr)
{
    ui->setupUi(this);
    ui->quickWidget_MapView->setSource(QUrl(QStringLiteral("qrc:/main.qml")));

    // Reference to the rootObject of quickWidget_MapView which is our map
    auto Obje = ui->quickWidget_MapView->rootObject();

    // When setCenterPosition is emitted from the current object, the setCenterPosition method in Obje will be called with the same parameters
    connect(this, SIGNAL(setCenterPosition(QVariant,QVariant)), Obje, SLOT(setCenterPosition(QVariant,QVariant)));
    connect(this, SIGNAL(setLocationMarking(QVariant,QVariant)), Obje, SLOT(setLocationMarking(QVariant,QVariant)));

    // Start the Python Xbee Process
    if (startXbeeProcess()) {
        qDebug() << "XBee Python script started successfully";
    } else {
        qWarning() << "Failed to start XBee Python script";
    }
}

MainWindow::~MainWindow()
{
    // Terminate the Python process
    if (pythonProcess && pythonProcess->state() == QProcess::Running) {
        pythonProcess->terminate();
        if (!pythonProcess->waitForFinished(3000)) {
            pythonProcess->kill();
        }
    }

    delete ui;
}

bool MainWindow::startXbeeProcess()
{
    pythonProcess = new QProcess(this);

    // Connect signals to handle process output and errors
    connect(pythonProcess, &QProcess::readyReadStandardOutput, this, [this]() {
        QByteArray output = pythonProcess->readAllStandardOutput();
        qDebug() << "Python output:" << output;
    });

    connect(pythonProcess, &QProcess::readyReadStandardError, this, [this]() {
        QByteArray error = pythonProcess->readAllStandardError();
        qWarning() << "Python error:" << error;
    });

    connect(pythonProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [](int exitCode, QProcess::ExitStatus exitStatus) {
                qDebug() << "Python process finished with code" << exitCode;
            });

    // Set the working directory to where the script is located
    pythonProcess->setWorkingDirectory(QCoreApplication::applicationDirPath());

    // Start the Python script
    pythonProcess->start("python", QStringList() << "xbeeFunctions.py");

    // Wait for it to start
    if (!pythonProcess->waitForStarted(5000)) {
        qWarning() << "Failed to start Python process:" << pythonProcess->errorString();
        return false;
    }

    return true;
}
