import QtQuick 2.15
import QtLocation
import QtPositioning

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
                // center the icon
                anchorPoint.x: sourceItem.width / 2 
                anchorPoint.y: sourceItem.height / 2

                sourceItem: Item {
                    width: markerImage.width
                    height: markerImage.height + droneLabel.height

                    Image {
                        id: markerImage
                        source: "qrc:/resources/droneMapIconSVG02.svg"
                        width: 50 // controlling w or h affects the whole image due to preserving the aspect fit
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
        onZoomLevelChanged: updateScaleBar()
        onCenterChanged: updateScaleBar()
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
