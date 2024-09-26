#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include <QDebug>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    ui->quickWidget_MapView->setSource(QUrl(QStringLiteral("qrc:/main.qml")));

    auto Obje = ui->quickWidget_MapView->rootObject();

    connect(this, SIGNAL(setCenterPosition(QVariant,QVariant)), Obje, SLOT(setCenterPosition(QVariant,QVariant)));
    connect(this, SIGNAL(setLocationMarking(QVariant,QVariant)), Obje, SLOT(setLocationMarking(QVariant,QVariant)));
}

MainWindow::~MainWindow()
{
    delete ui;
}
