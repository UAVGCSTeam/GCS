import QtQuick 2.15
import QtLocation
import QtPositioning

Item
{
    id:mapwindow

    property double latitude: 34.059174611493965
    property double longitude: -117.82051240067321
    property var supportedMapTypes: [
        { name: "Street", type: Map.StreetMap },
        { name: "Satellite", type: Map.SatelliteMapDay },
        { name: "Terrain", type: Map.TerrainMap },
    ]
    property int currentMapTypeIndex: 0

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Map
    {
        id:mapview
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(latitude,longitude)
        zoomLevel: 18

        PinchHandler
        {
            target: null
            grabPermissions: PointerHandler.TakeOverForbidden
            property geoCoordinate startCenteroid
            onActiveChanged:
            {
                if (active)
                    startCenteroid = mapview.toCoordinate(centroid.position, false)
            }
            onScaleChanged: (delta) =>
                            {
                mapview.zoomLevel += Math.log(delta)
                mapview.alignCoordinateToPoint(startCenteroid, centroid.position)
            }
        }

        WheelHandler
        {
            onWheel: function(event)
            {
                const loc = mapview.toCoordinate(point.position)
                mapview.zoomLevel += event.angleDelta.y / 120;
                mapview.alignCoordinateToPoint(loc, point.position)
            }
        }

        DragHandler {
            target: null
            grabPermissions: PointerHandler.TakeOverForbidden
            onTranslationChanged: (delta) => { mapview.pan(-delta.x, -delta.y); }
        }
        MapItemView
        {
            model: ListModel { id: markersModel }
            delegate: MapQuickItem
            {
                coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                anchorPoint.x: markerImage.width / 2
                anchorPoint.y: markerImage.height
                sourceItem: Image {
                    id: markerImage
                    source: "qrc:/resources/droneMapIconSVG.svg"
                    width: 100
                    height: 100
                }
            }
        }
    }

    Connections {
        target: droneController
        function onDroneAdded() {
            let drones = droneController.getAllDrones();
            markersModel.clear();
            for (let i = 0; i < drones.length; i++) {
                markersModel.append({
                    "name": drones[i].name,
                    "latitude": drones[i].latitude,
                    "longitude": drones[i].longitude
                });
            }
        }
    }

    Connections {
        target: mapController
        function onCenterPositionChanged(lat, lon) {
            mapview.center = QtPositioning.coordinate(lat, lon);
        }
        function onLocationMarked(lat, lon) {
            markersModel.append({"latitude": lat, "longitude": lon});
        }
        function onMapTypeChanged(index) {
            if (index < mapview.supportedMapTypes.length) {
                mapview.activeMapType = mapview.supportedMapTypes[index];
            }
        }
    }

    Component.onCompleted: {
        let drones = droneController.getAllDrones();
        markersModel.clear();
        for (let i = 0; i < drones.length; i++) {
            markersModel.append({
                "name": drones[i].name,
                "latitude": drones[i].latitude,
                "longitude": drones[i].longitude
            });
        }
    }
}
