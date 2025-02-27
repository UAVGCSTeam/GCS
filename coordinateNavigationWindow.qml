import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
//import "qrc://gcsStyle/panelStyle.qml" as GcsStyle
import "qrc:/gcsStyle" as GcsStyle // can change current layout colors if needed to fit panelStyle

Window {
    id: coordinateNavigationWindow
    width: 300
    height: 300
    title: qsTr("Coordinate Navigation Command")

    Rectangle {
        id: coordinateNavBackground
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                text: "Enter Coordinates"
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
                color: GcsStyle.PanelStyle.textOnPrimaryColor
            }

            // Coordinate Input
            TextField {
                id: longitudeField
                placeholderText: "Enter Longitude"
                width: parent.width
                color: GcsStyle.PanelStyle.textOnPrimaryColor
            }

            TextField {
                id: latitudeField
                placeholderText: "Enter Latitude"
                width: parent.width
                color: GcsStyle.PanelStyle.textOnPrimaryColor
            }

             /* Not sure if submit button needs to be redeclared?
                Might be easier if it can be referenced
            */
            Button {
                id: submitButton
                text: "Submit"
                width: parent.width
                // Background color theme retrieved from manageDroneWindow
                background: Rectangle {
                    color: submitButton.pressed ? "#e0e0e0" : parent.hovered ? "#f0f0f0" : "#f5f5f5"
                    radius: 4
                    border.color: "#e0e0e0"
                    border.width: 1
                }

                contentItem: Text {
                    text: submitButton.text
                    color: GcsStyle.PanelStyle.textOnPrimaryColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
            }
                //TODO: Confirm drone flies to submitted coordinates (future task)
                onClicked: {
                    console.log("Longitude: " + longitudeField.text +
                                "\nLatitude: " + latitudeField.text)
                    coordinateNavigationWindow.close();
                }
            }

            Button {
                id: cancelButton
                text: "Cancel"
                width: parent.width

                // Background color theme retrieved from manageDroneWindow
                background: Rectangle {
                    color: cancelButton.pressed ? "#e0e0e0" : parent.hovered ? "#f0f0f0" : "#f5f5f5"
                    radius: 4
                    border.color: "#e0e0e0"
                    border.width: 1
                }
                contentItem: Text {
                    text: cancelButton.text
                    color: GcsStyle.PanelStyle.textOnPrimaryColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    coordinateNavigationWindow.close();
                }
            }
        }
    }
}
