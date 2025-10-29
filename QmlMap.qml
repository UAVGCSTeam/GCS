import QtQuick 2.15
import QtLocation
import QtPositioning
import QtQuick.Controls

Item {
    id: mapwindow

    property double latitude: 34.059174611493965
    property double longitude: -117.82051240067321
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
            acceptedButtons: Qt.LeftButton | Qt.RightButton  // allow both buttons
            onActiveChanged: {
                // Disable left-drag if waypointing is active
                if (active && Qt.application.mouseButtons === Qt.LeftButton && mapwindow.wayPointingActive) {
                    active = false;
                }
            }
            onTranslationChanged: (delta) => {
                mapview.pan(-delta.x, -delta.y);
            }
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
        MouseArea {
            id: mapMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            enabled: mapwindow.wayPointingActive  // only active during waypoint mode

            // start null so "visible" can depend on it
            property var cursorCoord: null

            onPositionChanged: {
                if (!mapwindow.selectedDrone) {
                    cursorCoord = null
                    return
                }
                // use mouseX/mouseY (MouseArea properties) to avoid deprecated implicit mouse param
                cursorCoord = mapview.toCoordinate(Qt.point(mouseX, mouseY))

                var droneCoord = QtPositioning.coordinate(
                    mapwindow.selectedDrone.latitude,
                    mapwindow.selectedDrone.longitude
                )
                mapwindow.waypointLineModel = [droneCoord, cursorCoord]
            }

            onClicked: {
                if (mapwindow.wayPointingActive && mapwindow.selectedDrone) {
                    var clickedCoord = mapview.toCoordinate(Qt.point(mouseX, mouseY))

                    // Draw the line
                    var droneCoord = QtPositioning.coordinate(
                        mapwindow.selectedDrone.latitude,
                        mapwindow.selectedDrone.longitude
                    )
                    mapwindow.waypointLineModel = [droneCoord, clickedCoord]

                    // Save the clicked coordinate for the label
                    mapwindow.clickedCoordLabel = clickedCoord

                    console.log("Waypoint set at:", clickedCoord.latitude.toFixed(6), clickedCoord.longitude.toFixed(6))

                    // Optionally disable waypointing
                    mapwindow.wayPointingActive = false
                }
            }

            // Coordinate display near the mouse
            Item {
                id: coordDisplayWrapper
                visible: mapwindow.wayPointingActive && mapMouseArea.cursorCoord !== null
                x: mapMouseArea.mouseX + 15
                y: mapMouseArea.mouseY + 15
                Rectangle {
                    id: coordBackground
                    color: "#ffffffff"  // semi-transparent white
                    radius: 5
                    anchors.fill: coordText
                    anchors.margins: -4  // padding around text
                }

                Text {
                    id: coordText
                    text: {
                        var c = mapMouseArea.cursorCoord
                        return c ? (c.latitude.toFixed(6) + ", " + c.longitude.toFixed(6)) : ""
                    }
                    color: "black"
                    font.pixelSize: 14
                }
            }
        }
        MapQuickItem {
            id: clickedCoordLabelItem
            coordinate: mapwindow.clickedCoordLabel
            visible: mapwindow.clickedCoordLabel !== null

            // offset label 15px right & 15px down from the actual coordinate
            anchorPoint.x: labelRect.width / 2 - 15
            anchorPoint.y: labelRect.height + 15

            sourceItem: Rectangle {
                id: labelRect
                color: "#ffffff"
                radius: 5

                // Let the rectangle size itself around the text
                width: coordText.implicitWidth + 8
                height: coordText.implicitHeight + 8

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
        MapPolyline {
            line.width: 2
            line.color: "red"
            path: mapwindow.waypointLineModel
        }
        onZoomLevelChanged: updateScaleBar()
        onCenterChanged: updateScaleBar()
    }
    // Floating overlay for selected drones and actions
    Rectangle {
        id: selectedDronesOverlay
        width: 200
        height: 300
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        color: "#ffffffff"   // semi-transparent white
        radius: 10
        z: 20  // always on top

        // Column for title and drone list
        Column {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: cancelButton.top   // stop just above the Cancel button
                margins: 10
            }
            spacing: 10

            Text {
                text: "Waypointing"
                font.bold: true
                font.pointSize: 14
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ListView {
                id: selectedDronesList
                model: mapwindow.selectedDrone ? [mapwindow.selectedDrone] : []
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                anchors.left: parent.left
                anchors.right: parent.right

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 40
                    color: index % 2 === 0 ? "#eeeeee" : "#dddddd"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: modelData.name
                        font.pointSize: 12
                    }
                }
            }
        }

        // Select Points button
        Button {
            id: selectPointsButton
            text: "Select Points"
            enabled: mapwindow.selectedDrone !== null
            anchors {
                bottom: cancelButton.top
                left: parent.left
                right: parent.right
                margins: 10
                bottomMargin: 6
            }
            onClicked: {
                console.log("Selecting points for drone:", mapwindow.selectedDrone.name)
                mapwindow.wayPointingActive = true
                mapwindow.clickedCoordLabel = null
            }
        }

        // Cancel button
        Button {
            id: cancelButton
            text: "Cancel"
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 10
                bottomMargin: 10
            }
            onClicked: {
                mapwindow.wayPointingActive = false
                mapwindow.selectedDrone = null
                mapwindow.waypointLineModel = []
                mapwindow.clickedCoordLabel = null
            }
        }

        visible: mapwindow.selectedDrone !== null
    }

    // Scale Indicator
    Item {
        id: scaleBarContainer
        anchors {
                    left: parent.left
                    bottom: parent.bottom
                    leftMargin: 50
                    bottomMargin: 20
                }
        width: 160
        height: 30

        // Horizontal scale line
        Rectangle {
            id: scaleBarLine
            anchors.verticalCenter: parent.verticalCenter
            x: 10
            height: 2
            width: 100   // will update dynamically
            color: "black"
        }

        // Left bracket
        Rectangle {
            anchors.left: scaleBarLine.left
            anchors.verticalCenter: scaleBarLine.verticalCenter
            width: 2
            height: 10
            color: "black"
        }

        // Right bracket
        Rectangle {
            anchors.left: scaleBarLine.right
            anchors.verticalCenter: scaleBarLine.verticalCenter
            width: 2
            height: 10
            color: "black"
        }

        Text {
            id: scaleText
            anchors.verticalCenter: scaleBarLine.verticalCenter
            anchors.right: scaleBarLine.left
            anchors.rightMargin: 5
            color: "black"
            font.pixelSize: 14
            text: ""  // will dynamically update
        }
    }

    // Dynamically updates scale bar when zoom level is changed
    function updateScaleBar() {
        // set fixed pixel length
        var pixelLength = 100;

        // Map two points on the same horizontal line
        var coord1 = mapview.toCoordinate(Qt.point(0, mapview.height - 50))
        var coord2 = mapview.toCoordinate(Qt.point(pixelLength, mapview.height - 50))

        var distance = coord1.distanceTo(coord2)

        // get the distance in a nice value
        var niceDistance = getNiceDistance(distance)
        var scaleWidth = pixelLength * niceDistance / distance

        scaleBarLine.width = scaleWidth

        if (niceDistance >= 1000)
            scaleText.text = (niceDistance / 1000).toFixed(0) + " km"
        else
            scaleText.text = Math.round(niceDistance) + " m"
    }

    // helper to round distances to multiples of 1, 2, 5 * 10^n
    function getNiceDistance(d){
        var pow10 = Math.pow(10, Math.floor(Math.log10(d)))
        var n = d / pow10
        if (n < 1.5) return 1 * pow10
        else if (n < 3) return 2 * pow10
        else if (n < 7) return 5 * pow10
        else return 10 * pow10
    }

    // Connect to droneController to listen for drone state changes
    Connections {
        target: droneController

        function onDroneStateChanged(droneName) {
            // Refresh the drone markers when a drone's state changes
            droneMarkerView.model = droneController.getAllDrones();
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
    }

    Component.onCompleted: {
        // Initial drone marker setup
        droneMarkerView.model = droneController.getAllDrones();
    }
}
