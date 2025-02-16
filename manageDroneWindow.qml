import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform

// This is the ui/qml file that corresponds to the manage drone window popout.
// This will allow one to add and delete drones from the database and what the application will process

Window {
    id: manageDroneWindow
    width: 400
    height: 300
    title: qsTr("Manage Drones")

    // Custom error popup using Popup
    Popup {
        id: errorPopup
        modal: true
        focus: true
        width: 300
        height: 150
        // Center the popup in the window
        x: (manageDroneWindow.width - width) / 2
        y: (manageDroneWindow.height - height) / 2

        background: Rectangle {
            color: "#f8d7da"
            border.color: "#f5c6cb"
            radius: 10
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            // Error message text displayed
            Text {
                id: errorMessage
                text: "Failed to add drone. Please check your input."
                wrapMode: Text.WordWrap
                // Width is parent's width minus margins
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 12
                color: "#721c24"
            }

            Button { // button is technically not needed you can just click outside the popup
                text: "OK"
                onClicked: errorPopup.close()
            }
        }
    }

       /* Display input fields for drone object
        Current: Drone Name, Status, Battery @ Connor
        New: Drone Name, ID, Xbee ID, Type @ Brandon
      */

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Text {
            text: "Add New Drone"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Drone Name Input
        TextField {
            id: droneNameField
            placeholderText: "Drone Name"
            width: parent.width
        }

        // Drone ID
        TextField {
            id: droneID
            placeholderText: "Drone ID"
            width: parent.width
        }

        // Drone Onboard Xbee ID
        TextField {
            id: droneXbeeID
            placeholderText: "Drone Xbee ID"
            width: parent.width
        }

        // Drone Onboard Xbee ID
        TextField {
            id: droneType
            placeholderText: "Drone Type"
            width: parent.width
        }


        // Submit Button
        Button {
            id: submitButton
            text: "Add Drone"
            width: parent.width

            onClicked: {
                // Dummy submission logic used
                // Checks can be added here or for each input field for actually checking the logic in submission to match the field needs
                var submissionSuccessful = false; // Change to false/true to test the error popup

                if (!submissionSuccessful) {
                    errorPopup.open();
                } else {
                    // Process the submission normally. Logic/method for actually adding drones goes here
                    
                    // Brandon V Note: this would record the information in the console instead of on the UI itself
                    console.log("Drone name: "+ droneName.text)
                    console.log("Drone ID: "+ droneID.text)
                    console.log("Drone Xbee ID: "+ droneXbeeID.text)
                    console.log("Drone Type: "+ droneType.text)
                }
            }
        }

        // Import drone button
        Button {
            text: "Import Drone"
            width: parent.width

            //**TO-DO**: add onClicked command for imported drone (task #52)
            // Option to have error input if drone is not imported correctly
            onClicked: {
                console.log("Drone imported successfully")
            }
        }
  
    }

    /* BrandonV
    TODO: After clicking "add drone", (1) link input fields with database &
    (2) have new drone appear on DroneStatusPanel
        (user should be able to interact with it like the other drones)
    */
}