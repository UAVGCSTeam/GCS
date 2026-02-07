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
    property var selectedDrones: [] // a list of DroneClass objects --- QML doesn't allow list<DroneClass>
    property var activeDrone: null // DroneClass type

    // These are our components that sit on top of our Window object

    QmlMap {
        id: mapComponent
        anchors.fill: parent
        activeDrone: mainWindow.activeDrone
        selectedDrones: mainWindow.selectedDrones 
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

    //active drone, initial anchor drone, clicked selected first, 
    //more than one selected, pass in list of selected drones to qml map, -> use list to determine what is selected 
    //to select each drone, to change our icon. 
    TelemetryPanel {
        id: telemetryPanel
        activeDrone: mainWindow.activeDrone // Pass the active drone reference to the telemetry panel
        anchors {
            bottom: parent.bottom
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
    }

    DroneCommandPanel {
        id: droneCommandPanel
        activeDrone: mainWindow.activeDrone
        anchors {
            top: droneMenuBar.bottom
            right: parent.right
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        visible: false
    }
    
    DroneTrackingPanel {
        id: droneTrackingPanel
        anchors {
            top: droneMenuBar.bottom
            left: parent.left
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
        onSelectionChanged: function(selected) { updateActiveDrone(selected) }
        onActiveDroneChanged: function(activeDrone) { mainWindow.activeDrone = activeDrone }
        onFollowRequested: function(drone) {
            if (!drone) {
                console.warn("Follow requested without a drone reference")
                return
            }

            console.log("[main.qml] Follow requested via modifier click:", drone.name)
            // Reset the current follow target so the map component doesn't keep the old pointer
            mapComponent.turnOffFollowDrone()
            // Immediately re-enable follow mode
            mapComponent.turnOnFollowDrone()
        }
    }

    // Shortcut for toggling follow functionality (cmd + f or ctrl + f)
    Shortcut {
        sequence: StandardKey.Find       // cmd + f (macOS) / ctrl + f (Windows)
        onActivated: mapComponent.toggleFollowDrone()
    }

    Component.onCompleted: {
        // Once the component is fully loaded, run through our js file to grab the needed info
        var coords = Coordinates.getAllCoordinates();
        mapController.setCenterPosition(coords[0].lat, coords[0].lon)
        for (var i = 0; i < 3; i++) {
            var coord = coords[i]
            mapController.setLocationMarking(coord.lat, coord.lon)
        }
        // droneController.openXbee("/dev/ttys005", 57600)
        droneController.openXbee("/dev/cu.usbserial-AQ015EBI", 57600)
    }

    function updateActiveDrone(selected) {
        if (selected.length < 1) activeDrone = null
        selectedDrones = selected
    }
}
