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

    signal zoomScaleChanged(var coord1, var coord2, var pixelLength) // signal to change the scale bar indicator


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
