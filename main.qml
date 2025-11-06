import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle

/*
  Our entry point for UI/GUI
  Displays all UI Components here
*/

Window {
    id: mainWindow
    width: 1280
    height: 720
    visible: true
    title: qsTr("GCS - Cal Poly Pomona")
    // These are our components that sit on top of our Window object


    QmlMap {
        // Reference by id not file name
        id: mapComponent
        anchors.fill: parent
        onZoomScaleChanged: function(coord1, coord2, pixelLength) {  
            mapScaleBar.updateScaleBar(coord1, coord2, pixelLength)
        }
        onMapInitialized: function(coord1, coord2, pixelLength) {  
            mapScaleBar.updateScaleBar(coord1, coord2, pixelLength)
        }
    }

    MapScaleBarIndicator {
        id: mapScaleBar
        anchors {
            bottom: parent.bottom
            left: mapTypeButton.right
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
    }

    MapDisplayTypeButton {
        id: mapTypeButton
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: GcsStyle.PanelStyle.applicationBorderMargin
            bottomMargin: GcsStyle.PanelStyle.applicationBorderMarginBottom
        }
    }

    // Menu bar above the drone tracking panel
    DroneMenuBar {
        id: droneMenuBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        z: 100
    }

    TelemetryPanel {
        id: telemetryPanel
        anchors {
            bottom: parent.bottom
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
    }
    
    DroneTrackingPanel {
        id: droneTrackingPanel
        anchors {
            top: droneMenuBar.bottom
            left: parent.left
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        onDroneClicked: function(drone, cmdOrCtrlPressed) {
            // function(drone) is used here to avoid implicit parameter passing. 
            // In this case the implicit parameter passing was 'drone'
            // Implicit parameter passing is not allowed for Qt 6.5+
            if (telemetryPanel.activeDrone && telemetryPanel.activeDrone.name === drone.name && telemetryPanel.visible) {
                droneTrackingPanel.clearSelection() // clear selected color
                telemetryPanel.clearActiveDrone()
            } else {
                // This is the case when the drone that was clicked was not the currently selected drone
                telemetryPanel.setActiveDrone(drone)

                // Ensure that the applicaiton will no longer follow a drone
                console.log("Stop following current drone when selecting another drone:", mapComponent.followDroneName)
                mapComponent.turnOffFollowDrone()

                // Check to see if command or ctrl key was pressed
                if (cmdOrCtrlPressed) {
                    mapComponent.turnOnFollowDrone()
                    console.log("Cmd or Ctrl Pressed. Following :", mapComponent.followDroneName)
                } else {
                    // add center drone functionality 
                    if (drone.latitude && drone.longitude){
                        mapController.setCenterPosition(drone.latitude, drone.longitude)
                        console.log("Map on centered drone:", drone.name, drone.latitude, drone.longitude)
                    } else {
                        console.warn("Drone has no position")
                    }
                }
            }
        }
    }

    // Shortcut for toggling follow functionality (cmd + f or ctrl + f)
    Shortcut {
        sequence: StandardKey.Find       // cmd + f (macOS) / ctrl + f (Windows)
        onActivated: mapComponent.toggleFollowDrone()
    }

    /*
      Connections is how we connect our QML and QML together

      The question becomes; do we need to use cpp in our QML UI elements?
      No, we don't.
      We actually want certain UI to be self-contained as it becomes more modular.
      Despite this some UI needs to be connected to cpp, especially if it has more complex logic.
    */

    // The following two connections are crucial for setting the limits of how much the telemetry window can expand

    Component.onCompleted: {
        // Once the component is fully loaded, run through our js file to grab the needed info
        var coords = Coordinates.getAllCoordinates();
        mapController.setCenterPosition(coords[0].lat, coords[0].lon)
        for (var i = 0; i < coords.length; i++) {
            var coord = coords[i]
            mapController.setLocationMarking(coord.lat, coord.lon)
        }

        // droneController.openXbee("/dev/ttys005", 57600)
        droneController.openXbee("/dev/cu.usbserial-A10KFA7J", 57600)
    }
}
