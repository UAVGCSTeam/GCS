import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle

// Status icon
Rectangle {
    height: 18
    width: statusRow.width + 14
    radius: 8
    color: Qt.rgba(0, 0, 0, 0.25)
    border.color: GcsStyle.PanelStyle.defaultBorderColor
    border.width: GcsStyle.PanelStyle.defaultBorderWidth
    property var status

    Row {
        id: statusRow
        anchors.centerIn: parent
        spacing: 4

        Image {
            source: "qrc:/resources/flightIcon.svg"
            sourceSize.width: 11
            sourceSize.height: 11
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: statusLabel
            text: status ? status : "NO STAT FOUND"
            color: Qt.rgba(255, 255, 255, 0.5)
            font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
            font.family: GcsStyle.PanelStyle.fontFamily
            y: (parent.height - implicitHeight) / 2 + 1
        }
    }
}