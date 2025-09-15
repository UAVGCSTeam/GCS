import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: waypointPanel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 12
    radius: GcsStyle.PanelStyle.cornerRadius
    height: whitePanel.height
    visible: false
    color: "transparent"
    property string droneName: ""
    property var droneLatitude
    property var droneLongitude

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: GcsStyle.PanelStyle.defaultSpacing

        Item {
            Layout.fillWidth: true
        }

        Rectangle{
            id: whitePanel
            width: 250
            height: 250
            radius: GcsStyle.PanelStyle.cornerRadius
            color: GcsStyle.PanelStyle.secondaryColor

            ColumnLayout
            {
                anchors.centerIn: parent
                width: parent.width - 20
                spacing: GcsStyle.PanelStyle.defaultSpacing

                Text{
                    text: "Waypoint for " + (waypointPanel.droneName.length ? waypointPanel.droneName : "Drone")
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                }

                TextField {
                    placeholderText: " altitude "
                    Layout.fillWidth: true
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                }
                TextField {
                    placeholderText: " longitude "
                    Layout.fillWidth: true
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                }
                Button
                {
                    text: "start"
                    Layout.fillWidth: true
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    onClicked: {
                        console.log("The location of " + waypointPanel.droneName + " is: latitude:", waypointPanel.droneLatitude, "longitude:", waypointPanel.droneLongitude)
                    }
                }
                Button
                {
                    text: "cancel"
                    Layout.fillWidth: true
                    onClicked: waypointPanel.visible = false
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                }
            }
        }
    }
}

