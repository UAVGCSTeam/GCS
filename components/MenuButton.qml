import QtQuick 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

/*
 * MenuButton - Reusable menu bar button component
 * Used for top-level menu items like "GCS" and "Command Menu"
 */

Button {
    id: menuButton
    anchors.centerIn: parent.parent
    property var menuBar: parent.parent
    height: menuBar.height - 2
    leftPadding: 15
    rightPadding: 15
    flat: true
    
    background: Rectangle {
        radius: 5
        color: (parent.hovered || parent.pressed)
               ? GcsStyle.PanelStyle.buttonHoverColor
               : "transparent"
    }
    
    contentItem: Text {
        text: parent.text
        color: GcsStyle.PanelStyle.textPrimaryColor
        font.pointSize: GcsStyle.PanelStyle.fontSizeXS
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}

