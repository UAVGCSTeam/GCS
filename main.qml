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
    property var selectedDrones: []
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
            right: parent.right
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        visible: false
        onVisibleChanged: {
                // TO-DO: do we actually need this. isn't there the same functionality below for the drone tracking panel?
                if (!visible) {
                    console.log("Stop following current drone de-clicked:", mapComponent.followDroneName)
                    mapComponent.turnOffFollowDrone()
                }
            }
    }
    DroneTrackingPanel {
        id: droneTrackingPanel
        anchors {
            top: droneMenuBar.bottom
            left: parent.left
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        onSelectionChanged: function(selected) {
            // function(selected) is used here to avoid implicit parameter passing
            // In this case the implicit parameter was passing was 'selected'
            // Implicit parameter passing is not allowed for QT 6.5+
            handleSelectedDrones(selected)
        }
        onFollowRequested: function(drone) {
            if (!drone) {
                console.warn("Follow requested without a drone reference")
                return
            }

            console.log("[main.qml] Follow requested via modifier click:", drone.name)
            // Reset the current follow target so the map component doesn't keep the old pointer
            mapComponent.turnOffFollowDrone()
            // Immediately re-enable follow mode. map component will use telemetryPanel.activeDrone
            mapComponent.turnOnFollowDrone()
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
    // TODO: update this to include the command panel instead in the future
    // Connections {
    //     target: droneStatusPanel
    //     function onStatusHeightReady(h) {
    //         telemetryPanel.setStatusHeight(h)
    //     } 
    // }
    Connections {
        target: droneTrackingPanel
        function onTrackingWidthReady(w) {
            telemetryPanel.setTrackingWidth(w)
        } 
    }


    // Connections {
    //     target: MapScaleBarIndicator
    //     function on(w) {
    //         telemetryPanel.setTrackingWidth(w)
    //     } 
    // }
    

    Component.onCompleted: {
        // Once the component is fully loaded, run through our js file to grab the needed info
        var coords = Coordinates.getAllCoordinates();
        mapController.setCenterPosition(coords[0].lat, coords[0].lon)
        for (var i = 0; i < coords.length; i++) {
            var coord = coords[i]
            mapController.setLocationMarking(coord.lat, coord.lon)
            console.log("[main.qml] Marked location:", coord.name, "at", coord.lat, coord.lon)
        }

        // Get the width and height of the tracking panel and command panel
        // used for the resizing limit on the telemetry panel
        // droneStatusPanel.publishStatusHeight(); // TODO: update this to include the command panel instead in the future
        droneTrackingPanel.publishTrackingWidth();

        fetch();
    }

    Connections {
        target: droneController

    }

    // NOT DYNAMIC: deleted functionality 
    function fetch() {
        // changing between droneController.getAllDrones() and droneController.drones
        // var drones = droneController.getAllDrones();
        // droneTrackingPanel.populateListModel(drones);
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

    // Syncs telemetry visibility and follow state whenever the selection array updates
    function handleSelectedDrones(selected) {
        selectedDrones = selected

        console.log("Selection count:", selected.length)
        for (var i = 0; i < selected.length; ++i) {
            var drone = selected[i]
            var name = drone && drone.name !== undefined ? drone.name : "<unknown>"
            console.log("Selected drone: ", name)
        }

        if (selected.length === 1) {
            var drone = selected[0]
            telemetryPanel.populateActiveDroneModel(drone)
            telemetryPanel.visible = true

        } else {
            // No selection or multiple selection: hide telemetry panel and stop following
            if (telemetryPanel.visible) {
                telemetryPanel.visible = false
            }
            mapComponent.turnOffFollowDrone()
        }
    }
}
