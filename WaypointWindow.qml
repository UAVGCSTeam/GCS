import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: waypointWindow
    width: 300
    height: 280
    color: "white"
    radius: 10
    border.color: "lightgray"
    border.width: 2
    visible: false

    // Property to receive the drone name
    property string droneName: ""

    //storing wayoint data for each drone
    property var droneWaypoints: ({}) 

    //tracking drone data 
    property string previousDrone: ""

    //when drone changes save old date and load new data 
    onDroneNameChanged: {
        console.log("Drone name changed to:", droneName)

        //save the current field values for the previous drone if it exists
        if(previousDrone !== "") {
            droneWaypoints[previousDrone] = {
                latitude: latitudeField.text,
                longitude: longitudeField.text
            }
            console.log("Saved waypoints for", previousDrone, ":", droneWaypoints[previousDrone])
        }

        //load saved data for the new drone if it exists, otherwise clear the fields
        if(droneName !== "" && droneWaypoints[droneName]) {
            latitudeField.text = droneWaypoints[droneName].latitude
            longitudeField.text = droneWaypoints[droneName].longitude
            console.log("Loaded waypoints for", droneName, ":", droneWaypoints[droneName])
        } else {
            latitudeField.text = ""
            longitudeField.text = ""
            console.log("No saved waypoints for", droneName, "clearing fields.")
        }

        //update previousDrone to the current one
        previousDrone = droneName

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        // Header with drone name
        Text {
            text: "Set Waypoints" + (droneName ? " - " + droneName : "")
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            color: "black"
        }

        // Latitude input
        TextField {
            id: latitudeField
            placeholderText: "Enter Latitude"
            Layout.fillWidth: true
            Layout.preferredHeight: 45   
            font.pixelSize: 15
            background: Rectangle {
                color: "lightgray"
                radius: 6
                border.color: "gray"
                border.width: 2
            }


            onTextChanged: {
            if(droneName !== "") {
                if(!droneWaypoints[droneName]){
                    droneWaypoints[droneName] = {}
                }
                    
                 droneWaypoints[droneName].latitude = text
                }
            }
        }

        

        // Longitude input
        TextField {
            id: longitudeField
            placeholderText: "Enter Longitude"
            Layout.fillWidth: true
            Layout.preferredHeight: 45   
            font.pixelSize: 15
            background: Rectangle {
                color: "lightgray"
                radius: 6
                border.color: "gray"
                border.width: 2
            }

            // Auto-save as user types
            onTextChanged: {
                if (droneName !== "") {
                    if (!droneWaypoints[droneName]) {
                        droneWaypoints[droneName] = {}
                    }
                    droneWaypoints[droneName].longitude = text
                }
            }
        }

         

        // Buttons row
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: "Cancel"
                background: Rectangle {
                    color: "lightgray"
                    radius: 6
                    border.color: "gray"
                }
                onClicked: waypointWindow.visible = false
            }

            Button {
                text: "Start"
                background: Rectangle {
                    color: "lightblue"
                    radius: 6
                    border.color: "gray"
                }
                onClicked: {
                    console.log("Starting waypointing for drone:", droneName)
                    console.log("Latitude:", latitudeField.text)
                    console.log("Longitude:", longitudeField.text)
                    waypointWindow.visible = false
                }
            }
        }
    }
}