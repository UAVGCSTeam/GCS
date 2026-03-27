import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    height: 18
    width: connRow.width + 14
    radius: 8
    color: Qt.rgba(0, 0, 0, 0.25)
    border.color: GcsStyle.PanelStyle.defaultBorderColor
    border.width: GcsStyle.PanelStyle.defaultBorderWidth

    Row {
        id: connRow
        anchors.centerIn: parent
        spacing: 4

        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: "#4caf50"
            // TODO: update this to be dynamic
            y: (connLabel.implicitHeight - 6) / 2 + 1
        }

        Text {
            id: connLabel
            text: "Connected"
            color: "#4caf50"
            font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
            font.family: GcsStyle.PanelStyle.fontFamily
            y: (parent.height - implicitHeight) / 2 + 1
        }
    }
}
