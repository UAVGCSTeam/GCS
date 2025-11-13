import QtQuick 2.15
import QtLocation
import QtPositioning
import QtQuick.Controls

Item {
    id: mapwindow

    property string followDroneName: ""
    property var followDrone: null
    property bool followingDrone: false
    property double latitude: 34.059174611493965
    property double longitude: -117.82051240067321
    // property double latitude: -35.363
    // property double longitude: 149.165
    property var supportedMapTypes: [
        { name: "Street", type: Map.StreetMap },
        { name: "Satellite", type: Map.SatelliteMapDay },
        { name: "Terrain", type: Map.TerrainMap },
    ]
    property int currentMapTypeIndex: 0
    property bool wayPointingActive: false
    property var selectedDrone: null
    property var waypointLineModel: []
    property var clickedCoordLabel: null
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
            acceptedButtons: Qt.LeftButton
            onTranslationChanged: (delta) => {
                mapview.pan(-delta.x, -delta.y);
            }
            onActiveChanged: if (active) {turnOffFollowDrone()}
        }

        // this is where we overlay the satellite map
        MapItemView {
            id: satelliteMap
            model: 1
            delegate: MapQuickItem { 
                coordinate: QtPositioning.coordinate(34.060978616851145, -117.83110213699356)
                anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                
                scale: Math.pow(2, mapview.zoomLevel - 15)

                sourceItem: Image {
                    id: satelliteImage
                    source: "qrc:/resources/satelliteMap.png"
                    width: 269 // controlling w or h affects the whole image due to preserving the aspect fit
                    fillMode: Image.PreserveAspectFit
                }
            }
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
        MouseArea {
            id: rightClickMenuArea
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true

            // store last right-click coordinate
            property var lastRightClickCoord: null

            onPressed: function(mouse) {
                if (mouse.button === Qt.RightButton) {

                    // convert pixel → geo coordinate
                    lastRightClickCoord = mapview.toCoordinate(Qt.point(mouse.x, mouse.y))

                    if (telemetryPanel.activeDrone) {
                        contextMenu.x = mouse.x
                        contextMenu.y = mouse.y
                        contextMenu.open()
                    }
                }
            }
        }
        // Context menu for waypointing
        Menu {
            id: contextMenu
            
            MenuItem {
                text: "Go to"

                //enabled: telemetryPanel.activeDrone

                onTriggered: {
                    console.log("Go to clicked for drone:", telemetryPanel.activeDrone.name)

                    mapwindow.selectedDrone = telemetryPanel.activeDrone

                    // Use the saved right-click coordinate
                    var clicked = rightClickMenuArea.lastRightClickCoord
                    var droneCoord = QtPositioning.coordinate(
                        mapwindow.selectedDrone.latitude,
                        mapwindow.selectedDrone.longitude
                    )

                    // Immediately draw dashed line
                    mapwindow.waypointLineModel = [droneCoord, clicked]

                    // Save the label
                    mapwindow.clickedCoordLabel = clicked

                    // Disable waypointing (since we already processed it)
                    mapwindow.wayPointingActive = false

                    console.log("Waypoint set at:", clicked.latitude, clicked.longitude)
                    droneController.sendWaypointCmd(clicked.latitude, clicked.longitude, telemetryPanel.activeDrone.xbeeAddress)

                    // repaint dashed line
                    waypointCanvas.requestPaint()
                }
            }
        }
        MapQuickItem {
            id: clickedCoordLabelItem
            coordinate: mapwindow.clickedCoordLabel
            visible: mapwindow.clickedCoordLabel !== null

            // offset label 10px right & 15px down from the actual coordinate
            anchorPoint.x: labelRect.width / 2 - 10
            anchorPoint.y: labelRect.height + 15

            sourceItem: Rectangle {
                id: labelRect
                color: "#ffffff"
                radius: 5

                // Let the rectangle size itself around the text
                width: coordTex.implicitWidth + 8
                height: coordTex.implicitHeight + 8

                Text {
                    id: coordTex
                    anchors.centerIn: parent
                    text: mapwindow.clickedCoordLabel
                        ? mapwindow.clickedCoordLabel.latitude.toFixed(6) + ", " + mapwindow.clickedCoordLabel.longitude.toFixed(6)
                        : ""
                    color: "black"
                    font.pixelSize: 14
                }
            }
        }
        Canvas {
            id: waypointCanvas
            anchors.fill: parent
            z: 15

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                if (mapwindow.waypointLineModel.length < 2)
                    return

                function geoToPixel(lat, lon) {
                    var mapWidth = 256 * Math.pow(2, mapview.zoomLevel);
                    var x = (lon + 180) / 360 * mapWidth
                    var sinLat = Math.sin(lat * Math.PI / 180)
                    var y = (0.5 - Math.log((1 + sinLat) / (1 - sinLat)) / (4 * Math.PI)) * mapWidth

                    var centerX = (mapview.center.longitude + 180) / 360 * mapWidth
                    var sinCenterLat = Math.sin(mapview.center.latitude * Math.PI / 180)
                    var centerY = (0.5 - Math.log((1 + sinCenterLat) / (1 - sinCenterLat)) / (4 * Math.PI)) * mapWidth

                    return { x: width / 2 + (x - centerX), y: height / 2 + (y - centerY) }
                }

                var start = geoToPixel(mapwindow.waypointLineModel[0].latitude,
                                       mapwindow.waypointLineModel[0].longitude)
                var end = geoToPixel(mapwindow.waypointLineModel[1].latitude,
                                     mapwindow.waypointLineModel[1].longitude)

                // Draw dotted line
                ctx.beginPath()
                ctx.setLineDash([5, 5])
                ctx.moveTo(start.x, start.y)
                ctx.lineTo(end.x, end.y)
                ctx.lineWidth = 2
                ctx.strokeStyle = "red"
                ctx.stroke()
                ctx.setLineDash([])

                // Draw circle at the end of the line)
                var radius = 6
                ctx.beginPath()
                ctx.arc(end.x, end.y, radius, 0, 2 * Math.PI)
                ctx.fillStyle = "red"
                ctx.fill()

                // Draw circle at the start (where the drone was)
                ctx.beginPath()
                ctx.arc(start.x, start.y, radius, 0, 2 * Math.PI)
                ctx.fillStyle = "red"
                ctx.fill()
            }

            Connections { target: mapwindow; function onWaypointLineModelChanged() {waypointCanvas.requestPaint()}}
            Connections { target: mapview; function onCenterChanged() {waypointCanvas.requestPaint()} function onZoomLevelChanged() {waypointCanvas.requestPaint()}}
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
        function onDronesChanged() {
            // Refresh the drone markers when the drone list changes
            droneMarkerView.model = droneController.drones;
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
        console.log("[QmlMap.qml] Number of drones in model:", droneController.drones.length)
    }
}
