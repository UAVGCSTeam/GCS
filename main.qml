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
    }

    MapDisplayTypeButton {
        id: mapTypeButton
        anchors {
            top: parent.top
            right: parent.right
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
    }
    DroneStatusPanel {
        id: droneStatusPanel
        anchors {
            top: parent.top
            right: parent.right
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        visible: false
    }
    // Menu bar above the drone tracking panel
    DroneMenuBar {
        id: menuBar
        anchors {
            top: parent.top
            left: parent.left
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
    }

    TelemetryPanel {
        id: telemetryPanel
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        visible: false
    }
    DroneTrackingPanel {
        id: droneTrackingPanel
        anchors {
            top: menuBar.bottom
            left: parent.left
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        onDroneClicked: {
            console.log("[main.qml] Clicked drone:", drone.name)
            if (telemetryPanel.activeDrone && telemetryPanel.activeDrone.name === drone.name) {
                // Toggle the visability of the telemetry panel if same drone is clicked
                telemetryPanel.visible = !telemetryPanel.visible

                //If the drone telemetry panel is not visible, then clear selected color
                if (!telemetryPanel.visible) {
                    droneTrackingPanel.clearSelection()
                }
            } else {
                // update telemetry panel with different drone info
                telemetryPanel.populateActiveDroneModel(drone)
                // Ensure panel is visible for a new drone
                telemetryPanel.visible = true
            }
        }
    }

    /*
      Connections is how we connect our QML and QML together

      The question becomes; do we need to use cpp in our QML UI elements?
      No, we don't.
      We actually want certain UI to be self-contained as it becomes more modular.
      Despite this some UI needs to be connected to cpp, especially if it has more complex logic.
    */

    // The following two connections are crucial for setting the limits of how much the telemetry window can expand
    Connections {
        target: droneStatusPanel
        function onStatusHeightReady(h) {
            telemetryPanel.setStatusHeight(h)
        } 
    }
    Connections {
        target: droneTrackingPanel
        function onTrackingWidthReady(w) {
            telemetryPanel.setTrackingWidth(w)
        } 
    }

    // Once the component is fully loaded, run through our js file to grab the needed info
    Component.onCompleted: {
        var coords = Coordinates.getAllCoordinates();
        mapController.setCenterPosition(coords[0].lat, coords[0].lon)
        droneStatusPanel.publishStatusHeight();
        droneTrackingPanel.publishTrackingWidth();
        for (var i = 0; i < coords.length; i++) {
            var coord = coords[i]
            mapController.setLocationMarking(coord.lat, coord.lon)
            console.log("[main.qml] Marked location:", coord.name, "at", coord.lat, coord.lon)
        }

        fetch();
    }

    Connections {
        target: droneController

        function onDroneStateChanged(droneName) {
            // Refresh the displayed list
            fetch();

            // If this is the currently selected drone, update its panel too
            if (droneStatusPanel.visible) {
                // Find the updated drone
                var drones = droneController.getAllDrones();
                for (var i = 0; i < drones.length; i++) {
                    if (drones[i].name === droneName) {
                        // Update the status panel
                        droneStatusPanel.populateActiveDroneModel(drones[i]);
                        break;
                    }
                }
            }
        }
    }

    function fetch() {
        var drones = droneController.getAllDrones();
        droneTrackingPanel.populateListModel(drones);
        // uncomment these for populating the list based on the database

        /*const response = [
                           {name: "Drone 1", status: "Flying", battery: 10, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 2", status: "Idle", battery: 54, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 3", status: "Stationy", battery: 70, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 4", status: "Dead", battery: 0, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 5", status: "Flying", battery: 90, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 6", status: "Ready", battery: 100, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45}
                          ]
        droneTrackingPanel.populateListModel(response)*/
        // uncomment these for the original static response
    }
}
