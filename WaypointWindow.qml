import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: waypointWindow
    width: 300
    height: 230
    color: "white"
    radius: 10
    border.color: "lightgray"
    border.width: 2
    visible: false

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 20

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        // Header
        Text {
            text: "Set Waypoints"
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
                    console.log("Starting waypointing...")
                    console.log("Latitude:", latitudeField.text)
                    console.log("Longitude:", longitudeField.text)
                    waypointWindow.visible = false
                }
            }
        }
    }
}
