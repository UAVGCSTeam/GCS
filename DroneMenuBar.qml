import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle
import "./components"

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
    property int padding: 2 // padding between the menu bar and the buttons within it
    height: 26 + padding * 2
    color: GcsStyle.PanelStyle.primaryColor

    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        height: GcsStyle.panelStyle.defaultBorderWidth // "width" of the border 
        width: parent.width // span across the menu bar 
        color: GcsStyle.PanelStyle.buttonBorderColor
    }
    
    RowLayout { 
        id: menuRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: padding + 0.5 // 0.5 offset helps the visuals :)
        spacing: 0
        
        // GCS Menu Item
        MenuButton {
            id: gcsMenuItem
            text: "GCS"
            onClicked: gcsMenu.open()
        }
        
        // Command Menu Item
        MenuButton {
            id: commandMenuItem
            text: "Command Menu"
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
            border.color: GcsStyle.PanelStyle.defaultBorderColor
            border.width: GcsStyle.PanelStyle.defaultBorderWidth
            radius: GcsStyle.PanelStyle.buttonRadius + 3
        }
        
        Column {
            width: parent.width
            spacing: 2
            
            PopupMenuItem {
                text: "Manage Drones"
                windowFile: "manageDroneWindow.qml"
                menuPopup: gcsMenu
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
            border.color: GcsStyle.PanelStyle.defaultBorderColor
            border.width: GcsStyle.PanelStyle.defaultBorderWidth
            radius: GcsStyle.PanelStyle.buttonRadius + 3
        }
        
        Column {
            width: parent.width
            spacing: 2
            
            PopupMenuItem {
                text: "ARM"
                windowFile: "armWindow.qml"
                menuPopup: commandMenu
            }
            
            PopupMenuItem {
                text: "Take-off"
                windowFile: "takeOffWindow.qml"
                menuPopup: commandMenu
            }
            
            PopupMenuItem {
                text: "Coordinate Navigation"
                windowFile: "coordinateNavigationWindow.qml"
                menuPopup: commandMenu
            }
            
            PopupMenuItem {
                text: "Go Home Landing"
                windowFile: "goHomeLandingWindow.qml"
                menuPopup: commandMenu
            }
            
            PopupMenuItem {
                text: "Delete All Drones"
                isDangerous: true
                menuPopup: commandMenu
                onMenuItemClicked: deleteAllDronesWindow.open()
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
        x: commandMenuItem.x + 2
        y: menuBar.height
        
        background: Rectangle {
            color: "#f8d7da"
            border.color: "#f5c6cb"
            radius: 10
        }
        
        Column {
            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 10
            
            Text {
                text: "Are you sure you want to delete ALL drones?"
                wrapMode: Text.WordWrap
                width: parent.width 
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
        x: commandMenuItem.x + 2
        y: menuBar.height + 5
        
        Column {
            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 10
            
            Text {
                text: "Drone successfully deleted!"
                color: GcsStyle.PanelStyle.textPrimaryColor
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
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
