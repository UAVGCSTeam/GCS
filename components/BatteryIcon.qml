import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    property var batteryLevel // set by parent; nested delegates do not see modelData

    anchors.bottom: parent.bottom
    anchors.left: parent.left
    width: battRow.width + 11
    height: 16
    radius: 10
    anchors.leftMargin: -5
    anchors.bottomMargin: -1
    color: GcsStyle.PanelStyle.lowBatteryColor
    border.color: Qt.rgba(255, 255, 255, 0.5)
    // TODO: Update this to be green when battery is above 70% and red otherwise
    border.width: 0.5

    Row {
        id: battRow
        anchors.centerIn: parent
        spacing: 4

        Image {
            source: "qrc:/resources/batteryIcon.svg"
            sourceSize.width: 15
            sourceSize.height: 13
            y: (battText.implicitHeight - 13) / 2
        }

        Text {
            id: battText
            text: batteryLevel ? batteryLevel + "%" : "?"
            color: "white"
            font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
        }
    }
}
