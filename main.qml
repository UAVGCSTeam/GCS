import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Map Application")

    QmlMap {
        id: mapComponent
        anchors.fill: parent
    }

    Connections {
        target: mapController
        function onCenterPositionChanged(lat, lon) {
            mapComponent.setCenterPosition(lat, lon)
        }
        function onLocationMarked(lat, lon) {
            mapComponent.setLocationMarking(lat, lon)
        }
    }

    // Once the component is fully loaded, run through our js file to grab the needed info
    Component.onCompleted: {
        var coords = Coordinates.getAllCoordinates();
        mapController.setCenterPosition(coords[0].lat, coords[0].lon)

        for (var i = 0; i < coords.length; i++) {
            var coord = coords[i]
            mapController.setLocationMarking(coord.lat, coord.lon)
            console.log("Marked location:", coord.name, "at", coord.lat, coord.lon)
        }
    }
}
