#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QtWidgets>
#include <QtQuick>
#include <QVariant>
#include <QQuickWidget>
#include <QProcess>

/*
 * Provides the functions and constructors for our mainwindow object
*/

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    // This references mainwindow.ui, which is where we can create our specific UI elements, making all elements accessible
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;
    QProcess *pythonProcess;
    QLabel *xbeeStatusLabel;

signals:
    // QVariant is a datatype that translates typical C types <-> Q types
    void setCenterPosition(const QVariant &x, const QVariant &y);
    void setLocationMarking(const QVariant &x, const QVariant &y);
};
#endif // MAINWINDOW_H
