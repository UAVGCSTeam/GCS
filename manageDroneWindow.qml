import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform
import com.gcs.filehandler
import "qrc:/gcsStyle" as GcsStyle
import QtQuick.Controls.Basic 2.15

// This is the ui/qml file that corresponds to the manage drone window popout.
// This will allow one to add and delete drones from the database and what the application will process

Window {
    id: manageDroneWindow
    width: 1050 // Perfect length, not sure why but the boxes get mis aligned. Maybe right padding; too tired to worry about
    height: 500
    title: qsTr("Manage Drones")

    // Property to track the currently selected drone
    property int selectedDroneIndex: -1

    ListModel {
        id: droneModel
    }

    FileHandler {
        id: fileHandler
    }

    Component.onCompleted: {
        try {
            const drones = droneController.getDroneList() // or whatever the actual method name is GIAN PLEASE MAKE (maybe not in droneController)
            // debug
            console.log("Fetched drones:", drones)
            console.log("Length:", drones.length)
            console.log("Fetched drones:", JSON.stringify(drones));
            // change if statement logic
            if (drones.length > 0 ) {
                drones.forEach(drone => {
                   droneModel.append({
                     "name": drone.name || "",
                     "role": drone.role || "",
                     "xbeeId": drone.xbeeId || "",
                     "xbeeAddress": drone.xbeeAddress || ""
                 })
               })
            }
        } catch (error) {
            console.error("Error fetching drones:", error)
        }
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
                    console.log("Drone Role: " + (jsonData.drones[i].role || "N/A"));
                }
            } else {
                console.log("No drones found in the JSON data.");
            }
        } catch (e) {
            console.log("Error parsing JSON:", e);
        }
    }

    // Function to populate input fields with selected drone data
    function populateFieldsWithSelectedDrone() {
        if (selectedDroneIndex >= 0 && selectedDroneIndex < droneModel.count) {
            var selectedDrone = droneModel.get(selectedDroneIndex);
            droneNameField.text = selectedDrone.name;
            droneRole.text = selectedDrone.role;
            droneXbeeID.text = selectedDrone.xbeeId;
            droneXbeeAddr.text = selectedDrone.xbeeAddress;
        }
    }

    // Function to clear input fields
    function clearFields() {
        droneNameField.text = "";
        droneRole.text = "";
        droneXbeeID.text = "";
        droneXbeeAddr.text = "";
        selectedDroneIndex = -1;
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
            // If we define error-specific stylized properties in the panel style it will be easy to implement here:
            color: "#f8d7da"  // or: GcsStyle.errorBackgroundColor
            border.color: "#f5c6cb"  // or: GcsStyle.errorBorderColor
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

    // Custom xbee connection initialized popup using Popup
    Popup {
        id: connectionInitializationPopup
        modal: true
        focus: true
        width: 300
        height: 150
        // Center the popup
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
                id: connectionInitializationMessage
                text: "xbee Connection Initialized."
                wrapMode: Text.WordWrap
                // Width is parent's width minus margins
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 12
                color: "#721c24"
            }

            Button {
                text: "OK"
                onClicked: connectionInitializationPopup.close()
            }
        }
    }

    // For successful operations
    Popup {
        id: successPopup
        modal: true
        focus: true
        width: 300
        height: 150
        // Center the popup
        x: (manageDroneWindow.width - width) / 2
        y: (manageDroneWindow.height - height) / 2

        background: Rectangle {
            color: "#d4edda"  // Light green background
            border.color: "#c3e6cb"
            radius: 10
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: successMessage
                text: "Operation completed successfully!"
                wrapMode: Text.WordWrap
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 12
                color: "#155724"  // Dark green text
            }

            Button {
                text: "OK"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: successPopup.close()
            }
        }
    }

    Column {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Text {
            text: "Manage Drones"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Input and Action Area
        Column {
            width: parent.width
            spacing: 10

            // Input boxes row
            Row {
                width: parent.width
                spacing: 10

                // Small Input Fields
                TextField {
                    id: droneNameField
                    placeholderText: "Drone Name"
                    placeholderTextColor: GcsStyle.PanelStyle.textPrimaryColor
                    width: (parent.width - 30) * 0.15

                    background: Rectangle {
                        color: "#f5f5f5"
                        radius: 4
                        border.color: parent.focus ? "#4CAF50" : "#e0e0e0"
                        border.width: parent.focus ? 2 : 1
                    }
                    color: "#333333"
                    font.pixelSize: 14
                    leftPadding: 8
                }

                TextField {
                    id: droneRole
                    placeholderText: "Drone Role"
                    placeholderTextColor: GcsStyle.PanelStyle.textPrimaryColor
                    width: (parent.width - 30) * 0.15

                    background: Rectangle {
                        color: "#f5f5f5"
                        radius: 4
                        border.color: parent.focus ? "#4CAF50" : "#e0e0e0"
                        border.width: parent.focus ? 2 : 1
                    }
                    color: "#333333"
                    font.pixelSize: 14
                    leftPadding: 8
                }

                // Large field style
                TextField {
                    id: droneXbeeID
                    placeholderText: "Drone Xbee ID"
                    placeholderTextColor: GcsStyle.PanelStyle.textPrimaryColor
                    width: (parent.width - 30) * 0.35

                    background: Rectangle {
                        color: "#f5f5f5"
                        radius: 6
                        border.color: parent.focus ? "#4CAF50" : "#e0e0e0"
                        border.width: parent.focus ? 2 : 1
                    }
                    color: "#333333"
                    font.pixelSize: 15
                    leftPadding: 12
                }

                TextField {
                    id: droneXbeeAddr
                    placeholderText: "Drone Xbee Address"
                    placeholderTextColor: GcsStyle.PanelStyle.textPrimaryColor
                    width: (parent.width - 30) * 0.35

                    background: Rectangle {
                        color: "#f5f5f5"
                        radius: 6
                        border.color: parent.focus ? "#4CAF50" : "#e0e0e0"
                        border.width: parent.focus ? 2 : 1
                    }
                    color: "#333333"
                    font.pixelSize: 15
                    leftPadding: 12
                    rightPadding: 12
                }
            }

            // Action Buttons Row
            Row {
                width: parent.width
                spacing: 10

                // Add Drone Button
                Button {
                    id: addButton
                    text: "Add Drone"
                    width: (parent.width - 30) / 4

                    background: Rectangle {
                        color: addButton.pressed ? "#e0e0e0" : parent.hovered ? "#f0f0f0" : "#f5f5f5"
                        radius: 4
                        border.color: "#e0e0e0"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: addButton.text
                        color: GcsStyle.PanelStyle.textPrimaryColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        // We are going to NEED to put more input validation
                        // TODO: add input validation for same name droneNames.
                        if (droneNameField.text.length > 0) {
                            // Add to list model first
                            droneModel.append({
                                                  "name": droneNameField.text,
                                                  "role": droneRole.text,
                                                  "xbeeId": droneXbeeID.text,
                                                  "xbeeAddress": droneXbeeAddr.text
                                              });

                            // Log to console
                            console.log("Added drone to list:")
                            console.log("Drone name: " + droneNameField.text)
                            console.log("Drone role: " + droneRole.text)
                            console.log("Drone Xbee ID: " + droneXbeeID.text)
                            console.log("Drone Xbee Address: " + droneXbeeAddr.text)

                            // Try to save to database (keep this for later, for when all database methods are added)
                            try {
                                droneController.saveDrone(droneNameField.text, droneRole.text,
                                                          droneXbeeID.text, droneXbeeAddr.text);
                                successMessage.text = "Drone added successfully!";
                                successPopup.open();

                            } catch (error) {
                                console.error("Failed to save to database:", error);
                                // Note: We're not showing error popup here since we at least added to the list
                                // Could be worth to add robust error pop ups for this input validation
                            }

                            // Clear the input fields
                            clearFields();
                        } else {
                            errorPopup.open();
                        }
                    }
                }

                // Update Button - Only enabled when a drone is selected
                Button {
                    id: updateButton
                    text: "Update Drone"
                    width: (parent.width - 30) / 4
                    enabled: selectedDroneIndex >= 0

                    background: Rectangle {
                        color: updateButton.enabled ?
                                   (updateButton.pressed ? "#e0e0e0" : parent.hovered ? "#f0f0f0" : "#f5f5f5")
                                 : "#d0d0d0"
                        radius: 4
                        border.color: "#e0e0e0"
                        border.width: 1
                        opacity: updateButton.enabled ? 1.0 : 0.5
                    }

                    contentItem: Text {
                        text: updateButton.text
                        color: updateButton.enabled ? GcsStyle.PanelStyle.textPrimaryColor : "#888888"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (selectedDroneIndex >= 0 && droneNameField.text.length > 0) {
                            var oldXbeeId = droneModel.get(selectedDroneIndex).xbeeId;

                            // Update the item in the model
                            droneModel.set(selectedDroneIndex, {
                                               "name": droneNameField.text,
                                               "role": droneRole.text,
                                               "xbeeId": droneXbeeID.text,
                                               "xbeeAddress": droneXbeeAddr.text
                                           });

                            // Update in database
                            try {
                                // UPDATE TO BE THE ACTUAL METHOD
                                droneController.updateDrone(oldXbeeId, droneNameField.text,
                                                            droneRole.text, droneXbeeID.text, droneXbeeAddr.text);
                                successMessage.text = "Drone updated successfully!";
                                successPopup.open();
                            } catch (error) {
                                console.error("Failed to update in database:", error);
                            }

                            // Clear the input fields and selection
                            clearFields();
                        }
                    }
                }

                // Delete Button - Only enabled when a drone is selected
                Button {
                    id: deleteButton
                    text: "Delete Drone"
                    width: (parent.width - 30) / 4
                    enabled: selectedDroneIndex >= 0

                    background: Rectangle {
                        color: deleteButton.enabled ?
                                   (deleteButton.pressed ? "#e07070" : parent.hovered ? "#ffdddd" : "#f5f5f5")
                                 : "#d0d0d0"
                        radius: 4
                        border.color: "#e0e0e0"
                        border.width: 1
                        opacity: deleteButton.enabled ? 1.0 : 0.5
                    }

                    contentItem: Text {
                        text: deleteButton.text
                        color: deleteButton.enabled ?
                                   (deleteButton.pressed || parent.hovered ? "#cc0000" : "#404040")
                                 : "#888888"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (selectedDroneIndex >= 0) {
                            var xbeeId = droneModel.get(selectedDroneIndex).xbeeId;

                            // Remove from model
                            droneModel.remove(selectedDroneIndex);

                            // Remove from database
                            try {
                                droneController.deleteDrone(xbeeId);
                                successMessage.text = "Drone deleted successfully!";
                                successPopup.open();
                            } catch (error) {
                                console.error("Failed to delete from database:", error);
                            }

                            // Clear the input fields and selection
                            clearFields();
                        }
                    }
                }

                Button {
                    id: importDroneButton
                    text: "Import Drone JSON"
                    width: (parent.width - 30) / 4
                    onClicked: fileDialog.open()

                    background: Rectangle {
                        color: importDroneButton.pressed ? "#e0e0e0" : parent.hovered ? "#f0f0f0" : "#f5f5f5"
                        radius: 4
                        border.color: "#e0e0e0"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: importDroneButton.text
                        color: GcsStyle.PanelStyle.textPrimaryColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
            }

            // Drone List Section
            Text {
                text: "Current Drones"
                font.pixelSize: 16
            }

            // Table Header
            Rectangle {
                id: tableHeader
                width: parent.width
                height: 30
                color: "#f5f5f5"
                anchors.left: parent.left
                anchors.right: parent.right

                Row {
                    anchors.fill: parent
                    spacing: 1

                    // Selection column
                    Rectangle {
                        width: 40
                        height: parent.height
                        color: "#e8e8e8"
                        Text {
                            anchors.centerIn: parent
                            font.bold: true
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.15 - 10
                        height: parent.height
                        color: "#e8e8e8"
                        Text {
                            anchors.centerIn: parent
                            text: "Drone Name"
                            font.bold: true
                        }
                    }
                    Rectangle {
                        width: parent.width * 0.15
                        height: parent.height
                        color: "#e8e8e8"
                        Text {
                            anchors.centerIn: parent
                            text: "Role"
                            font.bold: true
                        }
                    }
                    Rectangle {
                        width: parent.width * 0.33
                        height: parent.height
                        color: "#e8e8e8"
                        Text {
                            anchors.centerIn: parent
                            text: "Xbee ID"
                            font.bold: true
                        }
                    }
                    Rectangle {
                        width: parent.width * 0.33
                        height: parent.height
                        color: "#e8e8e8"
                        Text {
                            anchors.centerIn: parent
                            text: "Xbee Address"
                            font.bold: true
                        }
                    }
                }
            }

            // Drone List BOTTOM LIST OF ALL DRONES
            ListView {
                id: droneListView
                width: parent.width
                height: 200
                clip: true
                model: droneModel
                anchors.left: parent.left
                anchors.right: parent.right

                delegate: Rectangle {
                    width: parent ? parent.width : 0
                    height: 40
                    color: index === selectedDroneIndex ? "#e3f2fd" : (index % 2 === 0 ? "#ffffff" : "#f9f9f9")
                    anchors.left: parent ? parent.left : undefined
                    anchors.right: parent ? parent.right : undefined

                    Row {
                        width: parent.width
                        height: parent.height
                        spacing: 1
                        anchors.left: parent.left
                        anchors.right: parent.right

                        // Selection checkbox
                        Rectangle {
                            width: 40
                            height: parent.height
                            color: index % 2 === 0 ? "#f2f2f2" : "#ffffff"
                            border.width: 1
                            border.color: "#e0e0e0"

                            CheckBox {
                                anchors.centerIn: parent
                                checked: index === selectedDroneIndex
                                indicator: Rectangle {
                                    implicitWidth: 18
                                    implicitHeight: 18
                                    x: 9
                                    y: 6
                                    border.color: "#888888"
                                    border.width: 1
                                    color: index === selectedDroneIndex ? "#4CAF50" : "white"

                                    Rectangle {
                                        width: 10
                                        height: 10
                                        anchors.centerIn: parent
                                        visible: index === selectedDroneIndex
                                        color: "white"
                                    }
                                }

                                onClicked: {
                                    if (selectedDroneIndex === index) {
                                        // If clicking the already selected row, deselect it
                                        clearFields();
                                    } else {
                                        // Select this row
                                        selectedDroneIndex = index;
                                        populateFieldsWithSelectedDrone();
                                    }
                                }
                            }
                        }

                        // Name cell
                        Rectangle {
                            width: parent.width * 0.15 - 10
                            height: parent.height
                            color: index % 2 === 0 ? "#f2f2f2" : "#ffffff"
                            border.width: 1
                            border.color: "#e0e0e0"

                            Text {
                                text: name
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                elide: Text.ElideRight
                                width: parent.width - 20
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (selectedDroneIndex === index) {
                                        clearFields();
                                    } else {
                                        selectedDroneIndex = index;
                                        populateFieldsWithSelectedDrone();
                                    }
                                }
                            }
                        }

                        // Role cell
                        Rectangle {
                            width: parent.width * 0.15
                            height: parent.height
                            color: index % 2 === 0 ? "#f2f2f2" : "#ffffff"
                            border.width: 1
                            border.color: "#e0e0e0"

                            Text {
                                text: role
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                elide: Text.ElideRight
                                width: parent.width - 20
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (selectedDroneIndex === index) {
                                        clearFields();
                                    } else {
                                        selectedDroneIndex = index;
                                        populateFieldsWithSelectedDrone();
                                    }
                                }
                            }
                        }

                        // Xbee ID cell
                        Rectangle {
                            width: parent.width * 0.35
                            height: parent.height
                            color: index % 2 === 0 ? "#f2f2f2" : "#ffffff"
                            border.width: 1
                            border.color: "#e0e0e0"

                            Text {
                                text: xbeeId
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                elide: Text.ElideRight
                                width: parent.width - 20
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (selectedDroneIndex === index) {
                                        clearFields();
                                    } else {
                                        selectedDroneIndex = index;
                                        populateFieldsWithSelectedDrone();
                                    }
                                }
                            }
                        }

                        // Xbee Address cell
                        Rectangle {
                            width: parent.width * 0.35 - 30
                            height: parent.height
                            color: index % 2 === 0 ? "#f2f2f2" : "#ffffff"
                            border.width: 1
                            border.color: "#e0e0e0"

                            Text {
                                text: xbeeAddress
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                elide: Text.ElideRight
                                width: parent.width - 20
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (selectedDroneIndex === index) {
                                        clearFields();
                                    } else {
                                        selectedDroneIndex = index;
                                        populateFieldsWithSelectedDrone();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // For if there are no drones
            Item {
                width: parent.width
                height: 100
                visible: droneModel.count === 0  // Only shows when no drones exist

                Text {
                    anchors.centerIn: parent
                    text: "No drones added yet. Add your first drone above."
                    color: "#888888"
                    font.italic: true
                }
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
    }
    Connections {
        target: droneController
        // on receiving an emitted signal the connections refresh the droneModel ListModel using the updated drone list
        onDroneAdded: {
            var drones = droneController.getDroneList();
            droneTrackingPanel.populateListModel(drones);
        }
        onDroneUpdated: {
            var drones = droneController.getDroneList();
            droneTrackingPanel.populateListModel(drones);
        }
        onDroneDeleted: {
            var drones = droneController.getDroneList();
            droneTrackingPanel.populateListModel(drones);
        }
    }
}
