import QtQuick 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

/*
 * PopupMenuItem - Reusable popup menu item component
 * Used for items inside dropdown menus
 */

Button {
    id: menuItem
    width: parent.width
    height: textOfButton.implicitHeight + 15
    flat: true
    
    property bool isDangerous: false
    property string windowFile: ""
    property var menuPopup: null  // Reference to parent Popup passed in by parent
    property bool clickable: true // determines whether it can be clicked or not 

    signal menuItemClicked()  // Custom signal for parent to handle
    
    background: Rectangle {
        color: !clickable
            ? "transparent"
            : (parent.pressed || parent.hovered
                ? (isDangerous
                    ? GcsStyle.PanelStyle.buttonDangerHoverColor
                    : GcsStyle.PanelStyle.buttonHoverColor)
                : "transparent")
        radius: GcsStyle.PanelStyle.buttonRadius
    }
    
    contentItem: Text {
        id: textOfButton
        text: parent.text
        color: !clickable
            ? GcsStyle.PanelStyle.commandNotAvailable
            : (isDangerous
                ? (parent.pressed || parent.hovered
                    ? GcsStyle.PanelStyle.buttonDangerTextColor
                    : GcsStyle.PanelStyle.buttonDangerColor)
                : GcsStyle.PanelStyle.textPrimaryColor)
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.pointSize: GcsStyle.PanelStyle.fontSizeXS
        anchors.left: parent.left
        anchors.leftMargin: 10
    }
    
    // When clicked: 1. Close the menu 2. Emit signal 3. Open window (if windowFile is set)
    onClicked: {
        if (!clickable) return

        // Close parent Popup
        if (menuPopup) {
            menuPopup.close()
        }
        
        // Emit signal for parent to handle custom behavior
        menuItemClicked()
                
        // If windowFile is provided, handle window creation automatically
        if (windowFile !== "") {
            // Resolve path relative to root (not components folder)
            var filePath = windowFile.startsWith("qrc:/") ? windowFile : "qrc:/" + windowFile
            var component = Qt.createComponent(filePath)
            if (component.status === Component.Ready) {
                var window = component.createObject(null)
                if (window !== null) {
                    window.show()
                } else {
                    console.error("Error creating window for", text + ":", component.errorString())
                }
            } else {
                console.error("Component not ready for", text + ":", component.errorString())
            }
        } else {
            parent.clicked()
        }
    }
}

