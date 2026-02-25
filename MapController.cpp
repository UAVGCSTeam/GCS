#include "MapController.h"
#include "DroneClass.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QUrl>


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
        qDebug() << "[MapController.cpp] Changed to map type:" << index;
    } else {
        qDebug() << "[MapController.cpp] Unsupported map type index:" << index;
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

QVariantList MapController::noFlyZones() const
{
    return m_noFlyZones;
}

void MapController::clearNoFlyZones()
{
    if (m_noFlyZones.isEmpty()) {
        return;
    }

    m_noFlyZones.clear();
    emit noFlyZonesChanged();
}

QVariantList MapController::buildPointListFromPolygonRing(const QJsonArray &ring) const
{
    QVariantList points;
    for (const QJsonValue &coordinateValue : ring) {
        if (!coordinateValue.isArray()) {
            continue;
        }

        const QJsonArray coordinate = coordinateValue.toArray();
        if (coordinate.size() < 2 || !coordinate[0].isDouble() || !coordinate[1].isDouble()) {
            continue;
        }

        const double longitude = coordinate[0].toDouble();
        const double latitude = coordinate[1].toDouble();

        QVariantMap point;
        point["lat"] = latitude;
        point["lon"] = longitude;
        points.append(point);
    }

    return points;
}

bool MapController::addGeoJsonGeometry(const QString &zoneId, const QJsonObject &geometry, const QJsonObject &properties)
{
    const QString geometryType = geometry.value("type").toString();
    const QJsonArray coordinates = geometry.value("coordinates").toArray();

    if (geometryType == "Polygon") {
        if (coordinates.isEmpty() || !coordinates[0].isArray()) {
            return false;
        }

        const QVariantList points = buildPointListFromPolygonRing(coordinates[0].toArray());
        if (points.size() < 3) {
            return false;
        }

        QVariantMap zone;
        zone["id"] = zoneId;
        zone["type"] = "polygon";
        zone["points"] = points;
        zone["label"] = properties.value("NAME").toString(properties.value("name").toString(zoneId));
        m_noFlyZones.append(zone);
        return true;
    }

    if (geometryType == "MultiPolygon") {
        bool addedAny = false;
        int polygonIndex = 0;

        for (const QJsonValue &polygonValue : coordinates) {
            if (!polygonValue.isArray()) {
                continue;
            }

            const QJsonArray polygon = polygonValue.toArray();
            if (polygon.isEmpty() || !polygon[0].isArray()) {
                continue;
            }

            const QVariantList points = buildPointListFromPolygonRing(polygon[0].toArray());
            if (points.size() < 3) {
                continue;
            }

            QVariantMap zone;
            zone["id"] = QString("%1_%2").arg(zoneId).arg(polygonIndex++);
            zone["type"] = "polygon";
            zone["points"] = points;
            zone["label"] = properties.value("NAME").toString(properties.value("name").toString(zoneId));
            m_noFlyZones.append(zone);
            addedAny = true;
        }

        return addedAny;
    }

    return false;
}

bool MapController::loadNoFlyZones(const QString &geoJsonPath)
{
    QString resolvedPath = geoJsonPath;
    if (resolvedPath.startsWith("qrc:/")) {
        resolvedPath.replace(0, 4, ":");
    } else if (resolvedPath.startsWith("file:/")) {
        const QUrl url(resolvedPath);
        if (url.isLocalFile()) {
            resolvedPath = url.toLocalFile();
        }
    }

    QFile file(resolvedPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[MapController.cpp] Unable to open no-fly GeoJSON:" << geoJsonPath << "resolved as" << resolvedPath;
        return false;
    }

    const QByteArray rawData = file.readAll();
    file.close();

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(rawData, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        qWarning() << "[MapController.cpp] Invalid GeoJSON:" << parseError.errorString();
        return false;
    }

    const QJsonObject root = document.object();
    const QJsonArray features = root.value("features").toArray();

    int idCounter = 0;

    const QVariantList existingZones = m_noFlyZones;
    m_noFlyZones.clear();

    for (const QJsonValue &featureValue : features) {
        if (!featureValue.isObject()) {
            continue;
        }

        const QJsonObject feature = featureValue.toObject();
        const QJsonObject geometry = feature.value("geometry").toObject();
        const QJsonObject properties = feature.value("properties").toObject();
        if (geometry.isEmpty()) {
            continue;
        }

        QString zoneId = properties.value("OBJECTID").toVariant().toString();
        if (zoneId.isEmpty()) {
            zoneId = QString("zone_%1").arg(idCounter++);
        }

        const int beforeCount = m_noFlyZones.size();
        addGeoJsonGeometry(zoneId, geometry, properties);
        if (m_noFlyZones.size() == beforeCount) {
            continue;
        }
    }

    if (m_noFlyZones.isEmpty()) {
        m_noFlyZones = existingZones;
        qWarning() << "[MapController.cpp] No supported no-fly geometries were loaded.";
        return false;
    }

    emit noFlyZonesChanged();
    qDebug() << "[MapController.cpp] Loaded no-fly zones:" << m_noFlyZones.size();
    return !m_noFlyZones.isEmpty();
}
