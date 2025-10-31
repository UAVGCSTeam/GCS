import QtQuick 2.15
import QtLocation
import QtPositioning

Item {
    id: mapwindow

    property string followDroneName: ""
    property bool followingDrone: false
    property double latitude: 34.059174611493965
    property double longitude: -117.82051240067321
    property var supportedMapTypes: [
        { name: "Street", type: Map.StreetMap },
        { name: "Satellite", type: Map.SatelliteMapDay },
        { name: "Terrain", type: Map.TerrainMap },
    ]
    property int currentMapTypeIndex: 0
    property var _pendingCenter: undefined

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    signal zoomScaleChanged(var coord1, var coord2, var pixelLength) // signal to change the scale bar indicator
    signal mapInitialized(var coord1, var coord2, var pixelLength)

    Map {
        id: mapview
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(latitude, longitude)
        zoomLevel: 18

        // Throttle timer (coalesce bursts)
        Timer {
            id: followTimer
            interval: 50            // 20 Hz max
            repeat: false
            onTriggered: {
                if (_pendingCenter) {
                    // Option A: jump
                    // mapview.center = _pendingCenter

                    // Option B (nicer): animate to it
                    coordAnim.from = mapview.center
                    coordAnim.to   = _pendingCenter
                    coordAnim.start()
                    _pendingCenter = undefined
                }
            }
        }

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
                if (active) {
                    startCenteroid = mapview.toCoordinate(centroid.position, false)
                    turnOffFollowDrone()
                }
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
            onActiveChanged: if (active) {turnOffFollowDrone()}
            onTranslationChanged: (delta) => { mapview.pan(-delta.x, -delta.y); }
        }

        MapItemView {
            id: droneMarkerView
            model: droneController ? droneController.getAllDrones() : []
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(
                    modelData.latitude !== undefined ? modelData.latitude : latitude,
                    modelData.longitude !== undefined ? modelData.longitude : longitude
                )
                // center the icon
                anchorPoint.x: markerImage.width / 2 
                anchorPoint.y: markerImage.height / 2

                sourceItem: Item {
                    width: markerImage.width
                    height: markerImage.height + droneLabel.height

                    Image {
                        id: markerImage
                        source: "qrc:/resources/droneMapIconSVG.svg"
                        width: 100 // controlling w or h affects the whole image due to preserving the aspect fit
                        fillMode: Image.PreserveAspectFit
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
        onZoomLevelChanged: {
            // This is the logic needed in order to update the scale bar indicator

            // set fixed pixel length
            var pixelLength = 100;

            // Map two points on the same horizontal line
            var coord1 = mapview.toCoordinate(Qt.point(0, mapview.height - 50))
            var coord2 = mapview.toCoordinate(Qt.point(pixelLength, mapview.height - 50))
            zoomScaleChanged(coord1, coord2, pixelLength)
        }

        Component.onCompleted: { 
            // This is the logic needed in order to update the scale bar indicator

            // set fixed pixel length
            var pixelLength = 100;

            // Map two points on the same horizontal line
            var coord1 = mapview.toCoordinate(Qt.point(0, mapview.height - 50))
            var coord2 = mapview.toCoordinate(Qt.point(pixelLength, mapview.height - 50))
            mapInitialized(coord1, coord2, pixelLength)
        }
    }

    // Adding functionality to toggle following a drone 
    // if called, it will swap from either following the current selected drone or stop following that drone
    function toggleFollowDrone() {
        if (followingDrone){
            turnOffFollowDrone()
        } else {
            turnOnFollowDrone()
        }
    }

    function turnOnFollowDrone() {
        if(telemetryPanel.activeDrone !== null) {
            followingDrone = true
            followDroneName = telemetryPanel.activeDrone.name
            if (!followTimer.running) followTimer.start()
        } else {
            console.warn("No drone is currently selected to toggle")
        }
    }

    function turnOffFollowDrone() {
        if (followingDrone){
            console.log("Stop following current drone: ", followDroneName)
            followingDrone = false;
            followDroneName = ""
            if (followTimer.running) followTimer.stop()
        }
    }

    // Connect to droneController to listen for drone state changes
    Connections {
        target: droneController

        function onDroneStateChanged(droneName) {
            // Refresh the drone markers when a drone's state changes
            droneMarkerView.model = droneController.getAllDrones();
            // Following drone functions
            if (mapwindow.followingDrone && droneName === mapwindow.followDroneName) {
                var drone = droneController.getDrone(droneName)
                if (drone) {
                    // mapview.center = QtPositioning.coordinate(drone.latitude, drone.longitude)
                    _pendingCenter = QtPositioning.coordinate(drone.latitude, drone.longitude)
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
