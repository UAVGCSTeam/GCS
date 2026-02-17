#include "MapController.h"
#include "DroneClass.h"


/*
 * Used to emit signals to our QML functions.
 * Keeps logic in cpp.
 * https://doc.qt.io/qt-6/signalsandslots.html
*/

// Define constructor for MapController class
MapController::MapController(QObject *parent)
    // Defines all variables within our map
    : QObject(parent), m_currentMapType(0), m_supportedMapTypesCount(3)
{

}


void MapController::setCenterPosition(const QVariant &lat, const QVariant &lon)
{
    QPair<double, double> newCenter(lat.toDouble(), lon.toDouble());
    // updateCenter below
    updateCenter(newCenter);
}

    void MapController::setLocationMarking(const QVariant &lat, const QVariant &lon)
    {
        QPair<double, double> position(lat.toDouble(), lon.toDouble());
        // addMarker below
        addMarker(position);
    }


// emit sends the data that our cpp logic did to our QML files
void MapController::changeMapType(int index)
{
    if (index < m_supportedMapTypesCount) {
        m_currentMapType = index;
        emit mapTypeChanged(index);
        qDebug() << "Changed to map type:" << index;
    } else {
        qDebug() << "Unsupported map type index:" << index;
    }
}

void MapController::updateCenter(const QPair<double, double> &center)
{
    // used to not emit the signal if the old center matches the new center
    emit centerPositionChanged(QVariant(center.first), QVariant(center.second));
}

void MapController::addMarker(const QPair<double, double> &position)
{
    // Stores markers on cpp side
    m_markers.append(position);
    emit locationMarked(QVariant(position.first), QVariant(position.second));
}

void MapController::setZoomLevel(double level)
{
    emit zoomLevelChanged(level);
}
