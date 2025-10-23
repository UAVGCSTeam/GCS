import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle

/*
 * DroneMenuBar - Menu bar component to display various features and actions
 * Located below the native window title bar
 * Full-width bar with menu items on the left
 * Contains two dropdown items:
 * 1. "GCS" that opens the manage drone window.
 * 2. "Command Menu" that shows a submenu with the 4 command options.
 */

Rectangle {
    id: menuBar
    height: 26
    color: GcsStyle.PanelStyle.primaryColor
    
    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: GcsStyle.PanelStyle.buttonBorderColor
        opacity: 0.5
    }
    
    // Menu items row
    Row {
        id: menuRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        
        // GCS Menu Item
        Button {
            id: gcsMenuItem
            text: "GCS"
            height: menuBar.height - 1
            leftPadding: 15
            rightPadding: 15
            flat: true
            
            background: Rectangle {
                radius: 5
                color: parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor : 
                       parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor : 
                       "transparent"
            }
            
            contentItem: Text {
                text: parent.text
                color: GcsStyle.PanelStyle.textPrimaryColor
                font.pointSize: GcsStyle.PanelStyle.fontSizeXS
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: gcsMenu.open()
        }
        
        // Command Menu Item
        Button {
            id: commandMenuItem
            text: "Command Menu"
            height: menuBar.height - 1
            leftPadding: 15
            rightPadding: 15
            flat: true
            
            background: Rectangle {
                radius: 5
                color: parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor :
                       parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor :
                       "transparent"
            }
            
            contentItem: Text {
                text: parent.text
                color: GcsStyle.PanelStyle.textPrimaryColor
                font.pointSize: GcsStyle.PanelStyle.fontSizeXS
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: commandMenu.open()
        }
    }
    
    // Keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+Shift+P"
        onActivated: commandMenu.open()
    }
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (gcsMenu.visible) gcsMenu.close()
            if (commandMenu.visible) commandMenu.close()
        }
    }
    
    // GCS Menu Popup
    Popup {
        id: gcsMenu
        x: gcsMenuItem.x + 2
        y: menuBar.height
        width: 200
        padding: 5
        modal: false
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: GcsStyle.PanelStyle.primaryColor
            border.color: GcsStyle.PanelStyle.buttonBorderColor
            border.width: 1
            radius: 4
        }
        
        Column {
            width: parent.width
            spacing: 2
            
            Button {
                width: parent.width
                height: 30
                text: "Manage Drones"
                flat: true
                
                background: Rectangle {
                    color: parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor :
                           parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor :
                           "transparent"
                    radius: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: GcsStyle.PanelStyle.fontSizeXXS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                onClicked: {
                    gcsMenu.close()
                    var component = Qt.createComponent("manageDroneWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating object:", component.errorString());
                        }
                    } else {
                        console.error("Component not ready:", component.errorString());
                    }
                }
            }
        }
    }
    
    // Command Menu Popup
    Popup {
        id: commandMenu
        x: commandMenuItem.x + 2
        y: menuBar.height
        width: 200
        padding: 5
        modal: false
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: GcsStyle.PanelStyle.primaryColor
            border.color: GcsStyle.PanelStyle.buttonBorderColor
            border.width: 1
            radius: 4
        }
        
        Column {
            width: parent.width
            spacing: 2
            
            Button {
                width: parent.width
                height: 30
                text: "ARM"
                flat: true
                
                background: Rectangle {
                    color: parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor :
                           parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor :
                           "transparent"
                    radius: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: GcsStyle.PanelStyle.fontSizeXXS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                onClicked: {
                    commandMenu.close()
                    var component = Qt.createComponent("armWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating ARM window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }
            
            Button {
                width: parent.width
                height: 30
                text: "Take-off"
                flat: true
                
                background: Rectangle {
                    color: parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor :
                           parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor :
                           "transparent"
                    radius: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: GcsStyle.PanelStyle.fontSizeXXS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                onClicked: {
                    commandMenu.close()
                    var component = Qt.createComponent("takeOffWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating Take-off window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }
            
            Button {
                width: parent.width
                height: 30
                text: "Coordinate Navigation"
                flat: true
                
                background: Rectangle {
                    color: parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor :
                           parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor :
                           "transparent"
                    radius: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: GcsStyle.PanelStyle.fontSizeXXS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                onClicked: {
                    commandMenu.close()
                    var component = Qt.createComponent("coordinateNavigationWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating Coordinate Navigation window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }
            
            Button {
                width: parent.width
                height: 30
                text: "Go Home Landing"
                flat: true
                
                background: Rectangle {
                    color: parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor :
                           parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor :
                           "transparent"
                    radius: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: GcsStyle.PanelStyle.fontSizeXXS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                onClicked: {
                    commandMenu.close()
                    var component = Qt.createComponent("goHomeLandingWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating Go Home Landing window:", component.errorString())
                        }
                    } else {
                        console.error("Component not ready:", component.errorString())
                    }
                }
            }
            
            Button {
                width: parent.width
                height: 30
                text: "Delete All Drones"
                flat: true
                
                background: Rectangle {
                    color: parent.pressed ? "#ff6b6b" :
                           parent.hovered ? "#ff8e8e" :
                           "transparent"
                    radius: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.pressed || parent.hovered ? "#ffffff" : "#ff4444"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: GcsStyle.PanelStyle.fontSizeXXS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                onClicked: {
                    commandMenu.close()
                    deleteAllDronesWindow.open()
                }
            }
        }
    }
    
    // Delete confirmation popup
    Popup {
        id: deleteAllDronesWindow
        modal: true
        focus: true
        width: 200
        height: 200
        x: 105
        y: menuBar.height
        
        background: Rectangle {
            color: "#f8d7da"
            border.color: "#f5c6cb"
            radius: 10
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                text: "Are you sure you want to delete ALL drones?"
                wrapMode: Text.WordWrap
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 12
                color: GcsStyle.PanelStyle.textPrimaryColor
            }
            
            Button {
                text: "No"
                width: parent.width
                onClicked: {
                    deleteAllDronesWindow.close()
                }
            }
            
            Button {
                text: "Yes"
                width: parent.width
                onClicked: {
                    droneController.deleteALlDrones_UI()
                    deleteAllDronesWindow.close()
                    confirmWindow.open()
                }
            }
        }
    }
    
    Popup {
        id: confirmWindow
        modal: true
        focus: true
        width: 200
        height: 200
        x: 105
        y: menuBar.height + 5
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                text: "Drone successfully deleted!"
                color: GcsStyle.PanelStyle.textPrimaryColor
            }
            
            Button {
                text: "Ok"
                width: parent.width
                onClicked: {
                    confirmWindow.close();
                }
            }
        }
    }
}
