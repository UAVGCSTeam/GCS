#include <QObject>
#include <QDebug>
#include <QGuiApplication>
#include <QVariant>


/***************************************************************
 * Adding this class so that we properly add error checking that 
 * will check for errors beyond us 
 ***************************************************************/



class ErrorHandler : public QObject {
    Q_OBJECT

public:
    explicit ErrorHandler(QObject *parent = nullptr) : QObject(parent) {}
    
    Q_INVOKABLE QVariant requireDefined(const QVariant &value, const QString &name) {
        if (!value.isValid()) {
            qCritical() << "[QML Assertion]" << name << "is undefined!";
            QGuiApplication::quit(); // stops the app
            throw std::runtime_error(QString("[QML Assertion] " + name + " is undefined").toStdString());
        }
        return value;
    }
};
