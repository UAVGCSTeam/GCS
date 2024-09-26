#include "mapcontroller.h"

MapController::MapController(QObject *parent) : QObject(parent)
{
}

void MapController::setCenterPosition(const QVariant &lat, const QVariant &lon)
{
    emit centerPositionChanged(lat, lon);
}

void MapController::setLocationMarking(const QVariant &lat, const QVariant &lon)
{
    emit locationMarked(lat, lon);
}
