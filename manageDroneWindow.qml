import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform

// This is the ui/qml file that corresponds to the manage drone window popout.
// This will allow one to add and delete drones from the database and what the application will process

Window {
    width: 300
    height: 200
    title: qsTr("Manage Drones")

    // Display input fields for drone object
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Field 1: Drone Name
        Row {
            spacing: 10
            Text {
                text: "Drone name:"
                verticalAlignment: Text.AlignVCenter
            }

            TextField {
                id: droneName
                width: 150
            }
        }
        // Field 2: Drone ID
        Row {
            spacing: 10
            Text {
                text: "Drone ID:"
                verticalAlignment: Text.AlignVCenter
            }

            TextField {
                id: droneID
                width: 150
            }
        }
        // Field 3: Drone Onboard Xbee ID
        Row {
            spacing: 10
            Text {
                text: "Drone Xbee ID:"
                verticalAlignment: Text.AlignVCenter
            }

            TextField {
                id: droneXbeeID
                width: 150
            }
        }
        // Field 4: Drone Type
        Row {
            spacing: 10
            Text {
                text: "Drone Type:"
                verticalAlignment: Text.AlignVCenter
            }

            TextField {
                id: droneType
                width: 150
            }
        }
    }

    // Create button to save drone
    Button {
        text: "Save Drone"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10

        //**TO-DO**: add onClicked command
    }
}
