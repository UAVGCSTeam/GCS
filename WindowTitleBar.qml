import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: titleBar
    height: 32
    color: GcsStyle.PanelStyle.primaryColor
    radius: targetWindow && targetWindow.isMaximized ? 0 : 8
    
    // Properties
    property string windowTitle: "GCS - Cal Poly Pomona"
    property var targetWindow: null
    
    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: GcsStyle.PanelStyle.buttonBorderColor
        opacity: 0.5
    }
    
    // Left side: Menu items
    DroneMenuBar {
        id: droneMenuBar
        height: titleBar.height - 1
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }
    
    // Center: Window Title
    Text {
        id: titleText
        text: windowTitle
        anchors.centerIn: parent
        color: GcsStyle.PanelStyle.textPrimaryColor
        font.pointSize: GcsStyle.PanelStyle.fontSizeSmall
        font.weight: Font.Medium
    }
    
    // Right side: Window controls
    Row {
        id: windowControls
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        
        // Minimize button
        Button {
            id: minimizeButton
            width: 46
            height: titleBar.height - 1
            flat: true
            
            background: Rectangle {
                anchors.fill: parent
                color: minimizeButton.hovered ? GcsStyle.PanelStyle.buttonHoverColor : "transparent"
            }
            
            contentItem: Text {
                text: "─"
                color: GcsStyle.PanelStyle.textPrimaryColor
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                if (targetWindow) {
                    targetWindow.showMinimized()
                }
            }
        }
        
        // Maximize button
        Button {
            id: maximizeButton
            width: 46
            height: titleBar.height - 1
            flat: true
            
            background: Rectangle {
                anchors.fill: parent
                color: maximizeButton.hovered ? GcsStyle.PanelStyle.buttonHoverColor : "transparent"
            }
            
            contentItem: Text {
                text: "❐"
                color: GcsStyle.PanelStyle.textPrimaryColor
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                if (targetWindow) {
                    if (targetWindow.isMaximized) {
                        targetWindow.showNormal()
                        targetWindow.isMaximized = false
                    } else {
                        targetWindow.showMaximized()
                        targetWindow.isMaximized = true
                    }
                }
            }
        }
        
        // Close button
        Button {
            id: closeButton
            width: 46
            height: titleBar.height - 1
            flat: true
            
            background: Rectangle {
                anchors.fill: parent
                color: closeButton.hovered ? GcsStyle.PanelStyle.buttonCloseHoverColor : "transparent"
            }
            
            contentItem: Text {
                text: "✕"
                color: closeButton.hovered ? "#FFFFFF" : GcsStyle.PanelStyle.textPrimaryColor
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                if (targetWindow) {
                    targetWindow.close()
                }
            }
        }
    }
    
    // Make title bar draggable
    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: droneMenuBar.width
        anchors.rightMargin: windowControls.width
        
        property point clickPos: "0,0"
        
        onPressed: {
            clickPos = Qt.point(mouse.x, mouse.y)
        }
        
        onPositionChanged: {
            if (pressed && targetWindow) {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                targetWindow.x += delta.x
                targetWindow.y += delta.y
            }
        }
        
        onDoubleClicked: {
            if (targetWindow) {
                if (targetWindow.isMaximized) {
                    targetWindow.showNormal()
                    targetWindow.isMaximized = false
                } else {
                    targetWindow.showMaximized()
                    targetWindow.isMaximized = true
                }
            }
        }
    }
}
