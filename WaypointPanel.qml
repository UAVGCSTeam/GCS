import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: wayPointPanel
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    height: 200
    width: 200
    radius: 10
    visible: false
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            anchors.centerIn: parent
            text: "Waypoint for "
            color: "black"
        }

        Button {
            text: "latitude"
            Layout.fillWidth: true
            Layout.margins: GcsStyle.PanelStyle.defaultMargin
        }
        Button {
            text: "longitude"
            Layout.fillWidth: true
            Layout.margins: GcsStyle.PanelStyle.defaultMargin
        }
        Button {
            text: "start"
            Layout.fillWidth: true
            Layout.margins: GcsStyle.PanelStyle.defaultMargin
        }
        Button {
            text: "cancel"
            Layout.fillWidth: true
            Layout.margins: GcsStyle.PanelStyle.defaultMargin
        }
    }
}
