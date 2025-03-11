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
    height: 600
    title: qsTr("Manage Drones")

    // Property to track the currently selected drone
    property int selectedDroneIndex: -1
    // Properties for simulation mode and connection status
    property bool simulationMode: false
    property bool xbeeConnected: false
    property string simulationStatusText: simulationMode ? "SIMULATION MODE" : (xbeeConnected ? "CONNECTED" : "DISCONNECTED")

    ListModel {
        id: droneModel
    }

    FileHandler {
        id: fileHandler
    }

    Connections {
        target: droneController

        function onDronesChanged() {
            console.log("dronesChanged signal received in QML");

            // Store the currently selected drone address if any
            var selectedDroneAddr = "";
            if (selectedDroneIndex >= 0 && selectedDroneIndex < droneModel.count) {
                selectedDroneAddr = droneModel.get(selectedDroneIndex).xbeeAddress;
            }

            // Reload drones from database
            const drones = droneController.getDrones();
            console.log("Fetched drones after change:", JSON.stringify(drones));

            // Track the index of the previously selected drone
            var newSelectedIndex = -1;

            if (drones && drones.length > 0) {
                for (var i = 0; i < drones.length; i++) {
                    var drone = drones[i];
                    console.log("Appending drone to model:", JSON.stringify(drone));

                    droneModel.append({
                        "name": drone.name || "",
                        "type": drone.type || "",
                        "xbeeId": drone.xbeeId || "",
                        "xbeeAddress": drone.xbeeAddress || ""
                    });

                    // If this is the previously selected drone, note its new index
                    if (selectedDroneAddr && drone.xbeeAddress === selectedDroneAddr) {
                        newSelectedIndex = i;
                    }
                }
                console.log("Model count after reload:", droneModel.count);

                // Update the selected index
                selectedDroneIndex = newSelectedIndex;

                // If there's still a selection, repopulate the fields
                if (selectedDroneIndex >= 0) {
                    populateFieldsWithSelectedDrone();
                }
            } else {
                console.log("No drones found after change signal");
            }

            // These three ensure the manage window works
            droneListView.forceLayout();
            droneListView.positionViewAtBeginning();
            droneListView.forceLayout();
        }

        function onXbeeConnectionChanged(connected) {
            console.log("XBee connection status changed:", connected);
            xbeeConnected = connected;
        }
    }

    Component.onCompleted: {
        try {
<<<<<<< HEAD
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
=======
            console.log("Loading drones from database...");

            // Use the sync function instead of manual model updates
            syncModelWithDatabase();

            // Check if we have any drones at all
            if (droneModel.count === 0 && simulationMode) {
                console.log("No drones found, adding simulation drones");
                // Add simulation drones
                addSimulationDrones();
            }

            // Check for XBee monitoring function
            if (!simulationMode) {
                if (typeof droneController.startXbeeMonitoring === 'function') {
                    console.log("Starting XBee monitoring");
                    droneController.startXbeeMonitoring();
                } else {
                    console.log("startXbeeMonitoring function not available");
                    // Create a dummy property or function to avoid future errors
                    if (typeof droneController.startXbeeMonitoring === 'undefined') {
                        droneController.startXbeeMonitoring = function() {
                            console.log("Dummy XBee monitoring function called");
                            // You might want to signal connection status here
                            xbeeConnected = false;
                        };
                    }
                }
>>>>>>> 24d6d9c (PLEASE GOD HELP ME)
            }
        } catch (error) {
            console.error("Error in Component.onCompleted:", error);
        }
    }

    // Function to sync the model with database
    function syncModelWithDatabase() {
        console.log("Syncing model with database...");

        // Clear the current model
        droneModel.clear();

        // Fetch latest data from database
        const drones = droneController.getDrones();
        console.log("Fetched drones:", JSON.stringify(drones));

        // Add each drone to the model
        if (drones && drones.length > 0) {
            for (var i = 0; i < drones.length; i++) {
                var drone = drones[i];
                console.log("Processing drone:", JSON.stringify(drone));

                droneModel.append({
                    "name": drone.name || "",
                    "type": drone.type || "",
                    "xbeeId": drone.xbeeId || "",
                    "xbeeAddress": drone.xbeeAddress || ""
                });
            }
            console.log("Model updated with", droneModel.count, "drones from database");
        } else {
            console.log("No drones found in database");
        }

        // Force layout update
        droneListView.forceLayout();
        droneListView.positionViewAtBeginning();
        droneListView.forceLayout();
    }

    // Adds simulated drone
    function addSimulationDrones() {
        const simulationDrones = [
            {
                "name": "Scout1",
                "type": "Scout",
                "xbeeId": "SIM001",
                "xbeeAddress": "0013A20012345678"
            },
            {
                "name": "Cargo2",
                "type": "Carrier",
                "xbeeId": "SIM002",
                "xbeeAddress": "0013A20087654321"
            }
        ];

        simulationDrones.forEach(drone => {
            droneModel.append(drone);

            // Optionally save to database
            try {
                droneController.saveDrone(
                    drone.name,
                    drone.type,
                    drone.xbeeId,
                    drone.xbeeAddress
                );
            } catch (e) {
                console.log("Error saving simulation drone:", e);
            }
        });

        console.log("Added simulation drones, model count:", droneModel.count);
    }

    // Clears simulated drones
    function clearSimulationDrones() {
        if (simulationMode) {
            // Store addresses of all SIM drones to delete
            let simDroneAddresses = [];

            // Find drones with SIM prefix in xbeeId
            for (let i = droneModel.count - 1; i >= 0; i--) {
                if (droneModel.get(i).xbeeId.startsWith("SIM")) {
                    simDroneAddresses.push(droneModel.get(i).xbeeAddress);
                }
            }

            // Delete each simulation drone from database
            simDroneAddresses.forEach(address => {
                try {
                    droneController.deleteDrone(address);
                    console.log("Deleted simulation drone with address:", address);
                } catch (e) {
                    console.log("Error removing simulation drone from database:", e);
                }
            });

            // Sync model with database after all deletions
            syncModelWithDatabase();
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

    // Status indicator at the top
    Rectangle {
        id: statusIndicator
        color: simulationMode ? "#FFF3CD" : (xbeeConnected ? "#D4EDDA" : "#F8D7DA")  // Yellow for sim, green for connected, red for disconnected
        border.color: simulationMode ? "#FFECB5" : (xbeeConnected ? "#C3E6CB" : "#F5C6CB")
        border.width: 1
        radius: 4
        height: statusText.height + 10
        width: statusText.width + 20
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10

        Text {
            id: statusText
            text: simulationStatusText
            font.bold: true
            color: simulationMode ? "#856404" : (xbeeConnected ? "#155724" : "#721C24")  // Text color matching the background theme
            anchors.centerIn: parent
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
<<<<<<< HEAD
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
=======
                        // Validate input - we need at least a name
                        if (droneNameField.text.length > 0) {
                            try {
                                // We no longer manually add to the model
                                // Instead, we rely on the dronesChanged signal to update the UI
                                droneController.saveDrone(
                                    droneNameField.text,
                                    droneType.text,
                                    droneXbeeID.text,
                                    droneXbeeAddr.text
                                );

                                // Update the model from database
                                syncModelWithDatabase();

                                // Show success message
>>>>>>> 24d6d9c (PLEASE GOD HELP ME)
                                successMessage.text = "Drone added successfully!";
                                successPopup.open();

                                // Clear fields
                                clearFields();
                            } catch (error) {
                                console.error("Failed to save to database:", error);
                                errorMessage.text = "Failed to add drone: " + error;
                                errorPopup.open();
                            }
                        } else {
                            // Show error for missing name
                            errorMessage.text = "Drone name is required!";
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
                            var oldXbeeAddress = droneModel.get(selectedDroneIndex).xbeeAddress;

                            // Update the item in the model
<<<<<<< HEAD
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
=======
                            try {
                                droneController.updateDrone(oldXbeeAddress, droneNameField.text,
                                                          droneType.text, droneXbeeID.text, droneXbeeAddr.text);
                                // Update model from database
                                syncModelWithDatabase();

>>>>>>> 24d6d9c (PLEASE GOD HELP ME)
                                successMessage.text = "Drone updated successfully!";
                                successPopup.open();
                                clearFields();
                            } catch (error) {
                                console.error("Failed to update in database:", error);
                                errorMessage.text = "Failed to update drone: " + error;
                                errorPopup.open();
                            }
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
                            var xbeeAddress = droneModel.get(selectedDroneIndex).xbeeAddress;

                            // Remove from database
                            try {
                                droneController.deleteDrone(xbeeAddress);
                                // Update model from database
                                syncModelWithDatabase();

                                successMessage.text = "Drone deleted successfully!";
                                successPopup.open();
                                clearFields();
                            } catch (error) {
                                console.error("Failed to delete from database:", error);
                                errorMessage.text = "Failed to delete drone: " + error;
                                errorPopup.open();
                            }
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

                ScrollBar.vertical: ScrollBar {}

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

        Item {
                width: parent.width
                height: 20  // Small height or use Layout.fillHeight: true if using ColumnLayout
            }

        Row {
            width: parent.width
            anchors.right: parent.right
            layoutDirection: Qt.RightToLeft
            spacing: 10

            // Button to start XBee monitoring
            Button {
                id: xbeeConnectButton
                text: xbeeConnected ? "Reconnect XBee" : "Connect XBee"
                visible: !simulationMode  // Only show when not in simulation mode

                background: Rectangle {
                    color: xbeeConnected ? "#4CAF50" : "#e0e0e0"
                    radius: 4
                    border.color: xbeeConnected ? "#388E3C" : "#cccccc"
                    border.width: 1
                }

                contentItem: Text {
                    text: xbeeConnectButton.text
                    color: xbeeConnected ? "#FFFFFF" : GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    // Call the C++ method to start monitoring
                    if (typeof droneController.startXbeeMonitoring === 'function') {
                        droneController.startXbeeMonitoring();
                        connectionInitializationMessage.text = "XBee Connection Initialized.";
                        connectionInitializationPopup.open();
                    } else {
                        console.log("Note: startXbeeMonitoring function not available");
                        // The XBee connection may already be working based on your logs
                    }
                }
            }

            // Toggle button for simulation mode
            Button {
                id: simulationToggle
                text: simulationMode ? "Exit Simulation Mode" : "Enter Simulation Mode"

                background: Rectangle {
                    color: simulationMode ? "#FFC107" : "#e0e0e0"
                    radius: 4
                    border.color: simulationMode ? "#FFA000" : "#cccccc"
                    border.width: 1
                }

                contentItem: Text {
                    text: simulationToggle.text
                    color: simulationMode ? "#000000" : GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    simulationMode = !simulationMode;

                    if (simulationMode) {
                        // Entering simulation mode
                        if (droneModel.count === 0) {
                            addSimulationDrones();

                            // Show success popup
                            successMessage.text = "Simulation mode activated with test drones";
                            successPopup.open();
                        }
                    } else {
                        // Exiting simulation mode
                        clearSimulationDrones();

                        // Show success popup
                        successMessage.text = "Exited simulation mode";
                        successPopup.open();
                    }
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
