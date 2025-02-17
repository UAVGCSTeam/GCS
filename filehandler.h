#ifndef FILEHANDLER_H
#define FILEHANDLER_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDebug>

class FileHandler : public QObject {
    Q_OBJECT
public:
    explicit FileHandler(QObject *parent = nullptr) : QObject(parent) {}

    // QML invokable function to read file content
    Q_INVOKABLE QString readFile(const QString &filePath) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qDebug() << "Failed to open file:" << filePath;
            return QString();
        }
        QTextStream in(&file);
        return in.readAll();
    }
};

#endif // FILEHANDLER_H
