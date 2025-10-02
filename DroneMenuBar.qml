import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle

/*
 * DroneMenuBar - Menu bar component to display various features and actions
 * Located at the top of the drone tracking panel
 * Contains two dropdown items:
 * 1. "GCS" that opens the manage drone window.
 * 2. "Command Menu" that shows a submenu with the 4 command options.
 */

// TODO:    The sizing and spacing for all the elements should be dynamic: 
//          Meaning changing the text of a button will change the width as well. 

// TODO:    It's worth a shot looking into making the menus dynamic as a WHOLE.
//          If we're given a json of --> "Commands": {"Take Off", "Arm Drone"}
//          Maybe not that simple, but the idea is that we don't have to hard
//          code each command into this file. Because each command does a similar 
//          thing, we just need to iterate through that list of commands and display them.
 



Rectangle {
    id: menuBar
    height: 30 // This height of the entire menu bar controls the height of 
                // all the menu bar buttons. 
    color: "transparent"
    radius: GcsStyle.PanelStyle.cornerRadius - 3
        // This radius of the ENTIRE menu bar controls the radius of 
        // all the menu bar buttons


    // Colors sourced from theme
    property color baseColor: GcsStyle.PanelStyle.primaryColor
    property color borderClr: GcsStyle.PanelStyle.buttonBorderColor
    property color hoverClr: GcsStyle.PanelStyle.buttonHoverColor
    property color pressedClr: GcsStyle.PanelStyle.buttonPressedColor
    property int fontSize: GcsStyle.PanelStyle.fontSizeSmall


    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 0
        spacing: 5

        // "GCS" Menu Button 
        Rectangle {
            id: gcsMenuButton
            height: parent.parent.height
            width: gcsLabel.width + 40
            radius: parent.parent.radius
            border.color: borderClr
            border.width: 1

            // Text styling
            Text {
                id: gcsLabel
                text: "GCS ▼"
                anchors.centerIn: parent
                color: GcsStyle.PanelStyle.textPrimaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: fontSize
            }

            color:  gcsMenuButtonMouseArea.pressed ? pressedClr :
                    gcsMenuButtonMouseArea.containsMouse ? hoverClr :
                    baseColor
            MouseArea {
                id: gcsMenuButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                onClicked: gcsMenu.open()
            }
        }

        // Command Menu Button
        Rectangle {
            id: commandMenuButton
            height: parent.parent.height
            width: commandLabel.width + 40
            radius: parent.parent.radius
            border.color: borderClr
            border.width: 1
            color:  commandMenuButtonMouseArea.containsMouse ? hoverClr : 
                    commandMenuButtonMouseArea.pressed ? pressedClr : 
                    baseColor

            // Text styling
            Text {
                id: commandLabel
                text: "Command Menu ▼"
                anchors.centerIn: parent
                color: GcsStyle.PanelStyle.textPrimaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: fontSize
            }

            MouseArea {
                id: commandMenuButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                onClicked: commandMenu.open()
            }
        }
    }

    // Keyboard shortcut for Command Menu (Ctrl+Shift+P on Windows, Cmd+Shift+P on Mac)
    Shortcut {
        sequence: "Ctrl+Shift+P"
        onActivated: commandMenu.open()
    }

    // ESC key to close any open menu
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
        x: gcsMenuButton.x + 2
        // positioned just below the menu button
        y: menuBar.height + 5
        width: 200
        modal: false
        focus: true // Allows popup to receive keyboard events
        closePolicy: Popup.CloseOnPressOutside && gcsMenuButton // Closes popup when clicking outside
        padding: 3

        background: Rectangle {
            color: baseColor
            border.color: borderClr
            border.width: 1
            radius: menuBar.radius
        }

        // Column layout for menu items
        Column {
            anchors.fill: parent

            Button {
                width: parent.width
                height: menuBar.height
                text: "Manage Drones"

                background: Rectangle {
                    // Button background color logic for hovering and clicking, for intuity
                    color: parent.pressed ? pressedClr :
                           parent.hovered ? hoverClr :
                           "transparent"
                    radius: menuBar.radius - 3
                }

                // Text styling
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: fontSize
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
        x: commandMenuButton.x + 2
        y: menuBar.height + 5
        width: 200
        modal: false
        focus: true // Allows popup to receive keyboard events
        closePolicy: Popup.CloseOnPressOutside // Closes popup when clicking outside
        padding: 3

        background: Rectangle {
            color: baseColor
            border.color: borderClr
            border.width: 1
            radius: menuBar.radius
        }

        // Column layout for menu items
        Column {
            anchors.fill: parent

            // ARM Menu item
            Button {
                width: parent.width
                height: menuBar.height
                text: "ARM"

                background: Rectangle {
                    // Background color logic for clicking and hovering
                    color: parent.pressed ? pressedClr :
                           parent.hovered ? hoverClr :
                           "transparent"
                    radius: menuBar.radius - 3
                }

                // Menu Item text styling
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: fontSize
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

            // Take-off Menu item
            Button {
                width: parent.width
                height: menuBar.height
                text: "Take-off"

                background: Rectangle {
                    // Button background color logic
                    color: parent.pressed ? pressedClr :
                           parent.hovered ? hoverClr :
                           "transparent"
                    radius: menuBar.radius - 3
                }

                // Text styling
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: fontSize
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

            // Coordinate Navigation Menu item
            Button {
                width: parent.width
                height: menuBar.height
                text: "Coordinate Navigation"

                background: Rectangle {
                    // Background color logic
                    color: parent.pressed ? pressedClr :
                           parent.hovered ? hoverClr :
                           "transparent"
                    radius: menuBar.radius - 3
                }

                // Text styling
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: fontSize
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

            // Go Home Landing Menu item
            Button {
                width: parent.width
                height: menuBar.height
                text: "Go Home Landing"

                background: Rectangle {
                    // Background color logic
                    color: parent.pressed ? pressedClr :
                           parent.hovered ? hoverClr :
                           "transparent"
                    radius: menuBar.radius - 3
                }

                // Text styling
                contentItem: Text {
                    text: parent.text
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: fontSize
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

            // Delete All Drones Menu item
            Button {
                width: parent.width
                height: menuBar.height
                text: "Delete All Drones"

                background: Rectangle {
                    // Background color logic
                    color: parent.pressed ? "#ff6b6b" :
                           parent.hovered ? "#ff8e8e" :
                           "transparent"
                    radius: menuBar.radius - 3
                }

                // Text styling
                contentItem: Text {
                    text: parent.text
                    color: parent.pressed || parent.hovered ? "#ffffff" : "#ff4444"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: fontSize
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

    // Creates pop-up for Delete drone command
    Popup {
        id: deleteAllDronesWindow
        modal: true
        focus: true
        width: 200
        height: 200
        x: 105
        y: menuBar.height + 5

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
                font.pointSize: fontSize
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
