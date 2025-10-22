import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle

/*
 * DroneMenuBar - Menu bar component to display various features and actions
 * Designed to be embedded in WindowTitleBar
 * Contains menu items and their dropdown popups:
 * 1. "GCS" that opens the manage drone window.
 * 2. "Command Menu" that shows a submenu with the 4 command options.
 */

// TODO:    It's worth a shot looking into making the menus dynamic as a WHOLE.
//          If we're given a json of --> "Commands": {"Take Off", "Arm Drone"}
//          Maybe not that simple, but the idea is that we don't have to hard
//          code each command into this file. Because each command does a similar 
//          thing, we just need to iterate through that list of commands and display them.

Row {
    id: menuRow
    spacing: 0
    
    // GCS Menu Item
    Button {
        id: gcsMenuItem
        text: "GCS"
        height: parent.height
        leftPadding: 15
        rightPadding: 15
        flat: true
        
        background: Rectangle {
            color: parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor : 
                   parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor : 
                   "transparent"
        }
        
        contentItem: Text {
            text: parent.text
            color: GcsStyle.PanelStyle.textPrimaryColor
            font.pointSize: GcsStyle.PanelStyle.fontSizeExtraSmall
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
        height: parent.height
        leftPadding: 15
        rightPadding: 15
        flat: true
        
        background: Rectangle {
            color: parent.hovered ? GcsStyle.PanelStyle.buttonHoverColor :
                   parent.pressed ? GcsStyle.PanelStyle.buttonPressedColor :
                   "transparent"
        }
        
        contentItem: Text {
            text: parent.text
            color: GcsStyle.PanelStyle.textPrimaryColor
            font.pointSize: GcsStyle.PanelStyle.fontSizeExtraSmall
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: commandMenu.open()
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
        // Positioned in regards to menu button
        x: gcsMenuItem.x + 2
        y: menuRow.height + 5
        width: 200
        height: 50
        modal: false
        // Allows popup to receive keyboard events
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: GcsStyle.PanelStyle.primaryColor
            border.color: GcsStyle.PanelStyle.buttonBorderColor
            border.width: 1
            radius: 4
        }
        
        // Column layout for menu items
        Column {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 2
            
            Button {
                width: parent.width
                height: 30
                text: "Manage Drones"
                
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
                    font.pixelSize: fontSizeExtraSmall
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
        y: menuRow.height + 5
        width: 200
        height: 200
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
            anchors.fill: parent
            anchors.margins: 5
            spacing: 2
            
            Button {
                width: parent.width
                height: 30
                text: "ARM"
                
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
                    font.pixelSize: fontSizeExtraSmall
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
                    font.pixelSize: fontSizeExtraSmall
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
                    font.pixelSize: fontSizeExtraSmall
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
                    font.pixelSize: fontSizeExtraSmall
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
                    font.pixelSize: fontSizeExtraSmall
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
        y: menuRow.height + 5
        
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
        y: menuRow.height + 5
        
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
