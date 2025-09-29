#include "filehandler.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>

FileHandler::FileHandler(QObject *parent)
    : QObject(parent)
{}

QString FileHandler::readFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Failed to open file:" << filePath;
        return QString();
    }
    QTextStream in(&file);
    return in.readAll();
}
