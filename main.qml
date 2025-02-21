import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform
/*
  Our entry point for UI/GUI
  Displays all UI Components here
*/

Window {
    width: 1280
    height: 720
    visible: true
    title: qsTr("GCS - Cal Poly Pomona")

    // Menu bar for the top of the application to display various features and actions
    MenuBar {
        id: menuBar
        Menu {
            id: gcsMenu
            // title of the menu bar
            title: qsTr("GCS")
            // first button tab of the menu bar allows you to open the manage drone panel
            // this button is attached to the manage drone window.qml
            MenuItem {
                text: qsTr("Manage Drone")
                onTriggered: {
                    var component = Qt.createComponent("manageDroneWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating object:", component.errorString());
                        }
                    } else {
                        console.error("Component not ready:", component.errorString());
                    }
                }
            }
        }
    }

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
            margins: 10
        }
    }

    DroneStatusPanel {
        id: droneStatusPanel
        anchors {
            top: parent.top
            right: parent.right
            margins: 10
        }
    }

    DroneTrackingPanel {
        id: droneTrackingPanel
        anchors {
            top: parent.top
            left: parent.left
            margins: 10
        }
    }

    /*
      Connections is how we connect our QML and QML together

      The question becomes; do we need to use cpp in our QML UI elements?
      No, we don't.
      We actually want certain UI to be self-contained as it becomes more modular.
      Despite this some UI needs to be connected to cpp, especially if it has more complex logic.
    */
    Connections {
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

        fetch();
    }

    function fetch() {
        const response = [
                           {name: "Drone 1", status: "Flying", battery: 10, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 2", status: "Idle", battery: 54, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 3", status: "Stationy", battery: 70, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 4", status: "Dead", battery: 0, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 5", status: "Flying", battery: 90, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45},
                           {name: "Drone 6", status: "Ready", battery: 100, lattitude: 34.54345, longitude: -117.564345, altitude: 150.4, airspeed: 32.45}
                          ]
        droneTrackingPanel.populateListModel(response)
    }
}
