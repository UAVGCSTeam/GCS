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

    // Menu bar for the top of the application to display various features and actions
    MenuBar {
        id: menuBar

        // GCS Menu with two items:
        // 1. "Manage Drones" that opens the manage drone window.
        // 2. "Command Menu" that shows a submenu with the 4 command options.
        Menu {
            id: gcsMenu
            title: qsTr("GCS")
            // first button tab of the menu bar allows you to open the manage drone panel
            // this button is attached to the manageDroneWindow.qml

            // "Manage Drones" menu item
            MenuItem {
                text: qsTr("Manage Drones")
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

        Menu {
            id: commandMenu
            title: qsTr("Command Menu")

            MenuItem {
                id: armMenuItem
                text: qsTr("ARM")
                onTriggered: {
                    // Load and show armWindow.qml
                    var component = Qt.createComponent("armWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating ARM window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }
            MenuItem {
                id: takeOffMenuItem
                text: qsTr("Take-off")
                onTriggered: {
                    // Load and show takeOffWindow.qml
                    var component = Qt.createComponent("takeOffWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating Take-off window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }
            MenuItem {
                id: coordinateNavMenuItem
                text: qsTr("Coordinate Navigation")
                onTriggered: {
                    // Load and show coordinateNavigationWindow.qml
                    var component = Qt.createComponent("coordinateNavigationWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating Coordinate Navigation window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }
            MenuItem {
                id: goHomeLandingMenuItem
                text: qsTr("Go Home Landing")
                onTriggered: {
                    // Load and show goHomeLandingWindow.qml
                    var component = Qt.createComponent("goHomeLandingWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating Go Home Landing window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }

            MenuItem {
                text: qsTr("Delete All Drones")
                onTriggered: {
                    deleteAllDronesWindow.open();
                }
            }
        }
    }

    // Creates pop-up for Delete drone command
    Popup {
            id: deleteAllDronesWindow
            modal: true
            focus: true
            width: 200
            height: 200

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                // Display confirmation message
                Text {
                    id: confirmMessage
                    text: "Are you sure you want to delete ALL drones?"
                    wrapMode: Text.WordWrap
                    // Width is parent's width minus margins
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 12
                    color: GcsStyle.PanelStyle.textPrimaryColor
                }

                Button {
                    text: "No"
                    width: parent.width
                    onClicked: {
                        deleteAllDronesWindow.close()
                    }
                }

                Button {
                    text: "Yes"
                    width: parent.width
                    onClicked: {
                        droneController.deleteALlDrones_UI()
                        deleteAllDronesWindow.close()
                        confirmWindow.open()
                    }
                }
            }
        }
           /* Display input fields for drone object
            Current: Drone Name, Status, Battery @ Connor
            New: Drone Name, Drone Type*, Xbee ID, Type @ Brandon
            Drone ID will seen somewhere else
          */

        Popup {
            id: confirmWindow
            modal: true
            focus: true
            width: 200
            height: 200
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: confirmWindowText
                    text: "Drone successfully deleted!"
                    color: GcsStyle.PanelStyle.textPrimaryColor
                }

                Button {
                    text: "Ok"
                    width: parent.width
                    onClicked: {
                        confirmWindow.close();
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
        visible: false
    }
    DroneTrackingPanel {
        id: droneTrackingPanel
        anchors {
            top: parent.top
            left: parent.left
            margins: 10
        }
        onDroneClicked: {
                console.log("Clicked drone:", drone.name)
                // change so that none of these need to be called, instead call the for the object
                droneStatusPanel.populateActiveDroneModel(
                    drone.name,
                    drone.status,
                    drone.battery,
                    drone.latitude,
                    drone.longitude,
                    drone.altitude,
                    drone.airspeed
                )
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
                        droneTrackingPanel.updateSelectedDroneSignal(
                            drones[i].name,
                            drones[i].status,
                            drones[i].battery,
                            drones[i].latitude,
                            drones[i].longitude,
                            drones[i].altitude,
                            drones[i].airspeed
                        );
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
