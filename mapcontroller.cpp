#include "mapcontroller.h"
#include "droneclass.h"


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

    // Populate with dummy drone objects for testing icon markers using setLattitude and setLongitude
    DroneClass* drone1 = new DroneClass(this);
    drone1->setName("Drone 1");
    drone1->setLatitude(34.059174611493965);
    drone1->setLongitude(-117.82051240067321);
    addDrone(drone1);

    DroneClass* drone2 = new DroneClass(this);
    drone2->setName("Drone 2");
    drone2->setLatitude(34.0600);
    drone2->setLongitude(-117.8210);
    addDrone(drone2);

    DroneClass* drone3 = new DroneClass(this);
    drone3->setName("Drone 3");
    drone3->setLatitude(34.0615);
    drone3->setLongitude(-117.8225);
    addDrone(drone3);

    DroneClass* drone4 = new DroneClass(this);
    drone4->setName("Drone 4");
    drone4->setLatitude(37.7749);
    drone4->setLongitude(-122.4194);
    addDrone(drone4);

    DroneClass* drone5 = new DroneClass(this);
    drone5->setName("Drone 5");
    drone5->setLatitude(34.0119);
    drone5->setLongitude(-118.4916);
    addDrone(drone5);
}

void MapController::addDrone(DroneClass* drone)
{
    if (drone) {
        m_drones.append(drone);
    }
}

QVariantList MapController::getAllDrones() const
{
    QVariantList droneList;
    for (const DroneClass* drone : m_drones) {
        QVariantMap droneData;
        droneData["name"] = drone->getName();
        droneData["latitude"] = drone->getLatitude();
        droneData["longitude"] = drone->getLongitude();
        droneList.append(droneData);
    }
    return droneList;
}

void MapController::createDrone(const QString &input_name){
    DroneClass* temp = new DroneClass(this);
    temp->setName(input_name);
    temp->setLatitude(34.06152);
    temp->setLongitude(-117.82254);
    addDrone(temp);
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
