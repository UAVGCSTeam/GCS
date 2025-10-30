import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform
import com.gcs.filehandler
import QtQuick.Controls.Basic 2.15
import "qrc:/gcsStyle/panelStyle.qml" as GcsStyle

Window {
    id: coordinateNavigationWindow
    width: 300
    height: 300
    title: qsTr("Coordinate Navigation Command")

    Column {
        id: coordinateNavBackground
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        // Title
        Text {
            text: "Enter Coordinates"
            font.pixelSize: 20
            color: "#000000"
        }

        // Coordinate Input Fields
        TextField {
            id: longitudeField
            placeholderText: "Enter Longitude"
            width: parent.width
            height: 30
            color: "#000000"
        }

        TextField {
            id: latitudeField
            placeholderText: "Enter Latitude"
            width: parent.width
            height: 30
            color: "#000000"
        }

        // Submit Button
        Button {
            id: submitButton
            width: parent.width
            height: 30
            background: Rectangle {
                radius: 4
                color: submitButton.pressed ? "#e0e0e0" : submitButton.hovered ? "#f0f0f0" : "#f5f5f5"
                border.color: "#e0e0e0"
                border.width: 1
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Longitude: " + longitudeField.text +
                                "\nLatitude: " + latitudeField.text)
                    coordinateNavigationWindow.close();
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Submit"
                color: "#000000"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Cancel Button
        Button {
            id: cancelButton
            width: parent.width
            height: 30
            background: Rectangle {
                radius: 4
                color: cancelButton.pressed ? "#e0e0e0" : cancelButton.hovered ? "#f0f0f0" : "#f5f5f5"
                border.color: "#e0e0e0"
                border.width: 1
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    coordinateNavigationWindow.close();
                }
            }

            contentItem: Text {
                text: "Cancel"
                color: "#000000"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
