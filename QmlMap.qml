import QtQuick 2.15
import QtLocation
import QtPositioning
import QtQuick.Controls
import "qrc:/gcsStyle" as GcsStyle
import "./components"

Item {
    id: mapwindow

    Waypoint {
        id: waypointManager
        mapview: mapview
        activeDrone: mapwindow.activeDrone
        anchors.fill: mapview
        z: 15
    }

    property string followDroneName: ""
    property var followDrone: null
    property bool followingDrone: false
    
    // Compute initial position from settings 
    property double initialLatitude: settingsManager.leaveAtLastMapLocation ? settingsManager.lastMapLat : settingsManager.homeLat
    property double initialLongitude: settingsManager.leaveAtLastMapLocation ? settingsManager.lastMapLong : settingsManager.homeLong
    property double initialZoomLevel: settingsManager.leaveAtLastMapLocation ? settingsManager.lastMapZoom : 16
    
    // Current map state
    readonly property double latitude: mapview.center ? mapview.center.latitude : initialLatitude
    readonly property double longitude: mapview.center ? mapview.center.longitude : initialLongitude
    readonly property double zoomLevel: mapview.zoomLevel

    property var supportedMapTypes: [
        { name: "Street", type: Map.StreetMap },
        { name: "Satellite", type: Map.SatelliteMapDay },
        { name: "Terrain", type: Map.TerrainMap },
    ]
    property int currentMapTypeIndex: 0
    property bool wayPointingActive: false
    property var selectedDrone: null
    property var _pendingCenter: undefined

    property var activeDrone: null
    property var selectedDrones: null
    property Waypoint waypointManagerRef: waypointManager

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
        center: QtPositioning.coordinate(initialLatitude, initialLongitude)
        zoomLevel: initialZoomLevel

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

        // Context menu for waypointing
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

                    contextMenu.x = mouse.x
                    contextMenu.y = mouse.y
                    contextMenu.open()
                }
            }
        }
        Popup {
            id: contextMenu
            width: 200
            padding: 5
            modal: false
            focus: true
            closePolicy: Popup.CloseOnPressOutside
            
            background: Rectangle {
                color: GcsStyle.PanelStyle.primaryColor
                border.color: GcsStyle.PanelStyle.defaultBorderColor
                border.width: GcsStyle.PanelStyle.defaultBorderWidth
                radius: GcsStyle.PanelStyle.buttonRadius + 3
            }
            
            Column {
                width: parent.width
                spacing: 2
                
                PopupMenuItem {
                    text: "Go-To"
                    clickable: activeDrone ? true : false
                    onMenuItemClicked: {
                        contextMenu.close()
                        waypointManager.addWaypoint(
                            activeDrone.name,
                            activeDrone.latitude,
                            activeDrone.longitude,
                            rightClickMenuArea.lastRightClickCoord.latitude,
                            rightClickMenuArea.lastRightClickCoord.longitude
                        )
                        clickedCoordLabelItem.coordinate = rightClickMenuArea
                    }
                }
            }
        }

        MapQuickItem {
            id: clickedCoordLabelItem
            coordinate: null
            visible: clickedCoordLabelItem.coordinate !== null

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
                    text: clickedCoordLabelItem.coordinate
                        ? clickedCoordLabelItem.coordinate.latitude.toFixed(6) + ", " + clickedCoordLabelItem.coordinate.longitude.toFixed(6)
                        : ""
                    color: "black"
                    font.pixelSize: 14
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
        if(activeDrone !== null) {
            followingDrone = true
            followDrone = activeDrone
            followDroneName = activeDrone.name
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

    onActiveDroneChanged: {
        if (activeDrone === null) {
            turnOffFollowDrone()
        }
    }

    onSelectedDronesChanged: {
        // This is where you will update the selection of drones
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
        // Breaks initial properties binding to settingsManager via self-assignment (prevents settings changes from moving map during session)
        // Settings will take effect on next app launch
        initialLatitude = initialLatitude
        initialLongitude = initialLongitude
        initialZoomLevel = initialZoomLevel
        
        // console.log("[QmlMap.qml] Number of drones in model:", droneController.drones.length)
    }
}
