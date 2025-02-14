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

    /* Display input fields for drone object

        Current: Drone Name, Status, Battery
        New: Drone Name, ID, Xbee ID, Type
      */
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

    // Import drone button
    Button {
        text: "Import Drone"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10

        //**TO-DO**: add onClicked command for imported drone (task #52)
        // Option to have error input if drone is not imported correctly
        onClicked: {
            console.log("Drone imported successfully")
        }
    }

    // Create button to add drone
    Button {
        text: "Add Drone"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10

        /* Note: (1) this would record the information in the console instead of on the UI itself
           (2) Requires error input for empty/null/invalid fields
        */
        onClicked: {
            console.log("Drone name: "+ droneName.text)
            console.log("Drone ID: "+ droneID.text)
            console.log("Drone Xbee ID: "+ droneXbeeID.text)
            console.log("Drone Type: "+ droneType.text)
        }
    }
    /*
    TODO: After clicking "add drone", (1) link input fields with database &
    (2) have new drone appear on DroneStatusPanel
        (user should be able to interact with it like the other drones)
    */
}
