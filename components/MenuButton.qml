import QtQuick 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

/*
 * MenuButton - Reusable menu bar button component
 * Used for top-level menu items like "GCS" and "Command Menu"
 * IMPORTANT: this button should be independent of its parents
 * meaning that it does need to have a special configuration in 
 * the surrounding components in order to work.
 */

Button {
    id: menuButton
    height: textOfButton.implicitHeight + 15
    flat: true
    anchors.margins: 12
    
    background: Rectangle {
        radius: GcsStyle.PanelStyle.buttonRadius
        color: (parent.hovered || parent.pressed)
               ? GcsStyle.PanelStyle.buttonHoverColor
               : "transparent"
    }
    
    contentItem: Text {
        id: textOfButton
        text: parent.text
        color: GcsStyle.PanelStyle.textPrimaryColor
        font.pointSize: GcsStyle.PanelStyle.fontSizeXS
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}

