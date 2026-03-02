import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle
import "./components"
import "./components" as Components

Rectangle {
    id: menuBar
    property int padding: 2 // padding between the menu bar and the buttons within it
    property var activeDrone
    height: 26 + padding * 2
    color: GcsStyle.PanelStyle.primaryColor

    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        height: GcsStyle.panelStyle.defaultBorderWidth // "width" of the border 
        width: parent.width // span across the menu bar 
        color: GcsStyle.PanelStyle.defaultBorderColor
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
                text: "Settings"
                menuPopup: gcsMenu
                onMenuItemClicked: mainWindow.openSettingsWindow()
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
                menuPopup: commandMenu
                clickable: activeDrone !== null
                onMenuItemClicked: armUAVConfirmation.open() 
            }
            
            PopupMenuItem {
                text: "Takeoff"
                menuPopup: commandMenu
                clickable: activeDrone !== null
                onMenuItemClicked: takeoffUAVConfirmation.open()
            }
            
            PopupMenuItem {
                text: "Go Home Landing"
                windowFile: "goHomeLandingWindow.qml"
                clickable: activeDrone !== null
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
    
    // Delete confirmation popup. Uses the UniversalPopup component to pass on properties
    Components.UniversalPopup {
        id: deleteAllDronesWindow
        popupVariant: "destructive"
        popupTitle: "Delete all UAVs?"
        popupMessage: "Are you sure you want to delete ALL UAVs?"
        onAccepted: {
            droneController.deleteALlDrones_UI()
            deleteAllConfirmed.open()
        }
    }

    Components.UniversalPopup {
        id: armUAVConfirmation
        popupTitle: "Arm the UAV?"
        popupMessage: (activeDrone && activeDrone.name
                    ? "Are you sure you want to arm the UAV, " + activeDrone.name + "?"
                    : "NO UAV SELECTED")
        onAccepted: {
            // TEMP: hardcode a target; replace with your real XBee address or ID later
            const target = activeDrone.xbeeAddress
            const ok = droneController.sendArm(target, true)   // true = arm, false = disarm
            console.log("[DroneMenuBar] ARM ->", target, ok)
            armConfirmed.open()
        }
    }

    Components.UniversalPopup {
        id: takeoffUAVConfirmation
        popupTitle: "Takeoff"
        popupMessage: (activeDrone && activeDrone.name
                    ? "Are you sure you want to takeoff: " + activeDrone.name + "?"
                    : "NO UAV SELECTED")
        onAccepted: {
            // TEMP: hardcode a target; replace with your real XBee address or ID later
            const target = activeDrone.xbeeAddress
            const ok = droneController.sendTakeoffCmd(target)   // true = arm, false = disarm
            console.log("[DroneMenuBar] TAKEOFF ->", target, ok)
            takeoffConfirmed.open()
        }
    }

    // Confirmation popup for successful drone deletion. Uses the UniversalPopup component to pass on properties
    Components.UniversalPopup {
        id: deleteAllConfirmed
        popupVariant: "success"
        popupTitle: "Drone deletion"
        popupMessage: "All drones successfully deleted"
    }

    Components.UniversalPopup {
        id: armConfirmed
        popupVariant: "success"
        popupTitle: "Armed"
        popupMessage: (activeDrone && activeDrone.name
                    ? activeDrone.name + " successfully armed"
                    : "NO UAV SELECTED")
    }

    Components.UniversalPopup {
        id: takeoffConfirmed
        popupVariant: "success"
        popupTitle: "Takeoff"
        popupMessage: "Takeoff command sent to "
                    + (activeDrone && activeDrone.name ? activeDrone.name : "NO UAV SELECTED")
    }
}
