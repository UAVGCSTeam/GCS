#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QtWidgets>
#include <QtQuick>
#include <QVariant>
#include <QQuickWidget>

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;

signals:
    // QVariant is a datatype that translates typical C types <-> Q types
    void setCenterPosition(const QVariant &x, const QVariant &y);
    void setLocationMarking(const QVariant &x, const QVariant &y);
};
#endif // MAINWINDOW_H
