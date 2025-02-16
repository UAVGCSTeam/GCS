#include "dronecontroller.h"
#include <QDebug>

#include "dronecontroller.h"
#include <QDebug>

DroneController::DroneController(QObject *parent) : QObject(parent) {}

void DroneController::saveDrone(const QString &name, const QString &type, const QString &xbeeId, const QString &xbeeAddress) {
    if (DBManager::getInstance().addDrone(name, type, xbeeId, xbeeAddress)) {
        qDebug() << "Drone saved: " << name;
    } else {
        qCritical() << "Failed to save drone.";
    }
}
