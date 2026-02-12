#include "FileHandler.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

FileHandler::FileHandler(QObject *parent) : QObject(parent) {}

QString FileHandler::readFile(const QString &filePath) {
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "[FileHandler.cpp] Failed to open file:" << filePath;
        return QString();
    }
    QTextStream in(&file);
    return in.readAll();
}

