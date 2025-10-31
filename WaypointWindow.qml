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