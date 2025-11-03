import QtQuick 2.15
import QtLocation
import QtPositioning

Item {
    id: mapwindow

    property string followDroneName: ""
    property var followDrone: null
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

        Connections {
            target: followDrone
            enabled: followingDrone && !!followDrone
            // These handler names come from your Q_PROPERTY NOTIFY signals
            function onLatitudeChanged()  { mapview.queueCenterUpdate() }
            function onLongitudeChanged() { mapview.queueCenterUpdate() }
        }

        function queueCenterUpdate() {
            if (!followingDrone || !followDrone) return
            _pendingCenter = QtPositioning.coordinate(followDrone.latitude, followDrone.longitude)
        }

        // Throttle timer (coalesce bursts)
        Timer {
            id: followTimer
            interval: 50            // 20 Hz max
            repeat: true
            onTriggered: {
                if (_pendingCenter) {
                    // console.log("we are in the timer: longitude", _pendingCenter)
                    coordAnim.from = mapview.center
                    coordAnim.to   = _pendingCenter
                    coordAnim.start()
                    _pendingCenter = undefined
                }
            }
        }

        CoordinateAnimation {
            id: coordAnim
            target: mapview
            property: "center"
            duration: 45
            easing.type: Easing.InOutQuad
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
            model: droneController ? droneController.drones : []
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
            followDrone = telemetryPanel.activeDrone
            followDroneName = telemetryPanel.activeDrone.name
            console.log("Starting to follow the drone!: ", followDroneName)
            if (!followTimer.running) followTimer.start()
        } else {
            console.warn("No drone is currently selected to toggle")
        }
    }

    function turnOffFollowDrone() {
        if (followingDrone){
            console.log("Stop following current drone: ", followDroneName)
            followingDrone = false;
            followDrone = null
            followDroneName = ""
            if (followTimer.running) followTimer.stop()
        }
    }

    // Connect to droneController to listen for drone state changes
    Connections {
        target: droneController

        // function onDroneStateChanged(droneName) {
        //     // Refresh the drone markers when a drone's state changes
        //     droneMarkerView.model = droneController.getAllDrones();
        //     // Following drone functions
        //     if (mapwindow.followingDrone && droneName === mapwindow.followDroneName) {
        //         var drone = droneController.getDrone(droneName)
        //         if (drone) {
        //             // mapview.center = QtPositioning.coordinate(drone.latitude, drone.longitude)
        //             _pendingCenter = QtPositioning.coordinate(drone.latitude, drone.longitude)
        //         }
        //     }
        // }

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
        console.log("Number of drones in model:", droneController.drones.length)

    }
}
