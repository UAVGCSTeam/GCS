#include "mainwindow.h"
#include <QDebug>
#include "./ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    ui->quickWidget_MapView->setSource(QUrl(QStringLiteral("qrc:/main.qml")));

    // Reference to the rootObject of quickWidget_MapView which is our map
    auto Obje = ui->quickWidget_MapView->rootObject();

    // When setCenterPosition is emitted from the current object, the setCenterPosition method in Obje will be called with the same parameters
    connect(this,
            SIGNAL(setCenterPosition(QVariant, QVariant)),
            Obje,
            SLOT(setCenterPosition(QVariant, QVariant)));
    connect(this,
            SIGNAL(setLocationMarking(QVariant, QVariant)),
            Obje,
            SLOT(setLocationMarking(QVariant, QVariant)));
}

MainWindow::~MainWindow()
{
    delete ui;
}