// Waypoint Window UI Component
//Pop-up window for setting waypoints for the drone
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "qrc://gcsStyle/panelStyle.qml" as GcsStyle


Popup {
    id: waypointWindow
    width: 400
    height: 300
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    background: Rectangle {
        color: GcsStyle.PanelStyle.primaryColor
        radius: GcsStyle.PanelStyle.cornerRadius
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: GcsStyle.PanelStyle.defaultMargin
        spacing: GcsStyle.PanelStyle.defaultMargin

        // Header
        Text {
            text: "Set Waypoints"
            font.pixelSize: GcsStyle.PanelStyle.headerFontSize
            color: GcsStyle.PanelStyle.textOnPrimaryColor
            Layout.alignment: Qt.AlignHCenter
        }

        // Waypoint Input Area
        TextArea {
            id: waypointInput
            placeholderText: "Enter waypoints here..."
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // Buttons
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: GcsStyle.PanelStyle.defaultMargin

            Button {
                text: "Cancel"
                onClicked: waypointWindow.close()
            }

            Button {
                text: "Save"
                onClicked: {
                    console.log("Waypoint Input:", waypointInput.text);
                    // TODO: Save waypoints to drone
                    waypointWindow.close();
                }
            }
        }
    }
}