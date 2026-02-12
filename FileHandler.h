#ifndef FILEHANDLER_H
#define FILEHANDLER_H

#include <QObject>

class FileHandler : public QObject {
    Q_OBJECT
public:
    explicit FileHandler(QObject *parent = nullptr);

    // QML invokable function to read file content
    Q_INVOKABLE QString readFile(const QString &filePath);
};

#endif

