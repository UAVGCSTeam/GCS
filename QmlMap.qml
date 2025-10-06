import QtQuick 2.15
import QtLocation
import QtPositioning

Item {
    id: mapwindow

    property string followedDroneName: ""
    property bool followDrone: false
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

    Map {
        id: mapview
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(latitude, longitude)
        zoomLevel: 18

        // gives smooth transition for center changes
        Behavior on center {
                CoordinateAnimation {
                    duration: 1200
                    easing.type: Easing.InOutQuad
                }
            }

        PinchHandler {
            target: null
            grabPermissions: PointerHandler.TakeOverForbidden
            property geoCoordinate startCenteroid
            onActiveChanged: {
                if (active)
                    startCenteroid = mapview.toCoordinate(centroid.position, false)
            }
            onScaleChanged: (delta) => {
                mapview.zoomLevel += Math.log(delta)
                mapview.alignCoordinateToPoint(startCenteroid, centroid.position)
            }
        }

        WheelHandler {
            onWheel: function(event) {
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

        MapItemView {
            id: droneMarkerView
            model: droneController ? droneController.getAllDrones() : []
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(
                    modelData.latitude > 0 ? modelData.latitude : latitude,
                    modelData.longitude > 0 ? modelData.longitude : longitude
                )
                anchorPoint.x: sourceItem.width / 2
                anchorPoint.y: sourceItem.height

                sourceItem: Item {
                    width: markerImage.width
                    height: markerImage.height + droneLabel.height

                    Image {
                        id: markerImage
                        source: "qrc:/resources/droneMapIconSVG.svg"
                        width: 100
                        height: 100
                    }

                    DroneLabelComponent {
                        id: droneLabel
                        text: modelData.name || "Unknown"
                        x: (parent.width - width) / 2
                        y: markerImage.height + 5
                    }
                }
            }
        }
    }

    // Connect to droneController to listen for drone state changes
    Connections {
        target: droneController

        function onDroneStateChanged(droneName) {
            // Refresh the drone markers when a drone's state changes
            droneMarkerView.model = droneController.getAllDrones();
            // Following drone funcitions
            if (mapwindow.followDrone && droneName === mapwindow.followedDroneName) {
                    var drone = droneController.getDrone(droneName)
                    if (drone) {
                        mapview.center = QtPositioning.coordinate(drone.latitude, drone.longitude)
                }
            }
        }

        function onDronesChanged() {
            // Refresh the drone markers when the drone list changes
            droneMarkerView.model = droneController.getAllDrones();
        }
    }

    Connections {
        target: mapController
        function onCenterPositionChanged(lat, lon) {
            mapview.center = QtPositioning.coordinate(lat, lon)
        }
        function onMapTypeChanged(index) {
            if (index < mapview.supportedMapTypes.length) {
                mapview.activeMapType = mapview.supportedMapTypes[index]
            }
        }
        function onZoomLevelChanged(level) {
                mapview.zoomLevel = level
        }
    }

    Component.onCompleted: {
        // Initial drone marker setup
        droneMarkerView.model = droneController.getAllDrones();
    }
}
