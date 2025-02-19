import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform
import com.gcs.filehandler

// This is the ui/qml file that corresponds to the manage drone window popout.
// This will allow one to add and delete drones from the database and what the application will process

Window {
    id: manageDroneWindow
    width: 400
    height: 300
    title: qsTr("Manage Drones")

    FileHandler {
        id: fileHandler
    }

    // Function to read and parse the JSON file
    function loadJson(fileUrl) {
        var filePath = fileUrl.toString().replace("file://", "");
        console.log("Loading JSON from:", filePath);

        // Use fileHandler to read the file
        var fileContent = fileHandler.readFile(filePath);
        console.log("File content read:", fileContent);

        if (fileContent.length === 0) {
            console.log("Failed to read JSON file or file is empty.");
            return;
        }

        try {
            // Attempt to parse the JSON
            var jsonData = JSON.parse(fileContent);
            console.log("Parsed JSON:", JSON.stringify(jsonData, null, 2));

            // Check if the drones array exists and iterate over it
            if (jsonData.drones) {
                for (var i = 0; i < jsonData.drones.length; i++) {
                    console.log("Drone Name: " + (jsonData.drones[i].name || "Unknown"));
                    console.log("Drone ID: " + (jsonData.drones[i].id || "N/A"));
                    console.log("Drone Xbee ID: " + (jsonData.drones[i].address || "N/A"));
                    console.log("Drone Type: " + (jsonData.drones[i].role || "N/A"));
                }
            } else {
                console.log("No drones found in the JSON data.");
            }
        } catch (e) {
            console.log("Error parsing JSON:", e);
        }
    }

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
        New: Drone Name, Drone Type*, Xbee ID, Type @ Brandon
        Drone ID will seen somewhere else
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

        // Drone Type
        TextField {
            id: droneType
            placeholderText: "Drone Type"
            width: parent.width
        }

        // Drone Onboard Xbee ID
        TextField {
            id: droneXbeeID
            placeholderText: "Drone Xbee ID"
            width: parent.width
        }

        // Drone Onboard Xbee Address
        TextField {
            id: droneXbeeAddr
            placeholderText: "Drone Xbee Address"
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
                // Change this for dummy text input check, Name of Field is the only required item.
                if (droneNameField.text.length > 0) {
                    // Brandon V Note: this would record the information in the console instead of on the UI itself
                    console.log("Drone name: "+ droneNameField.text)
                    console.log("Drone ID: "+ droneType.text)
                    console.log("Drone Xbee ID: "+ droneXbeeID.text)
                    console.log("Drone Type: "+ droneXbeeAddr.text)
                //direct DB
                //onClicked: addDrone(droneNameField.text, droneType.text, droneXbeeID.text, droneXbeeAddr.text) // this is directly from the db.manager
                //UI Controller
                //perhaps onClicked should be QML stuff?
                    onClicked:   droneController.saveDrone(droneNameField.text, droneType.text, droneXbeeID.text, droneXbeeAddr.text);
                }
                else {
                    errorPopup.open();
                }
            }
        }

        // Import drone button
        Button {
            text: "Import Drone JSON"
            width: parent.width
            onClicked: fileDialog.open()
        }

        // File dialog to allow users to select a JSON file
        FileDialog {
            id: fileDialog
            title: "Select a JSON file"
            fileMode: FileDialog.OpenFile
            nameFilters: ["JSON Files (*.json)", "All Files (*)"]
            onAccepted: {
                console.log("Selected file:", fileDialog.file)
                loadJson(fileDialog.file)
            }
        }
  
    }

    /* BrandonV
    TODO: After clicking "add drone", (1) link input fields with database &
    (2) have new drone appear on DroneStatusPanel
        (user should be able to interact with it like the other drones)
    */
}
