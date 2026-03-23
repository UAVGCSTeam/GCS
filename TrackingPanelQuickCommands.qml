import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle
import "./components" as Components

Rectangle {
    id: root

    property var commandDrone: null // The drone that the user has selected to command

    property string activeAction: "" // The action that the user is currently performing

    width: 70 // Width of the panel
    height: commandColumn.implicitHeight + 6 // Height of the panel
    color: GcsStyle.PanelStyle.secondaryColor // Color of the panel
    radius: GcsStyle.PanelStyle.cornerRadius // Radius of the panel
    border.color: GcsStyle.PanelStyle.defaultBorderColor // Border color of the panel
    border.width: GcsStyle.PanelStyle.defaultBorderWidth // Border width of the panel

    ListModel {
        id: buttonModel
        ListElement { label: "Arm";     icon: "qrc:/resources/armIcon.svg";         action: "arm" }
        ListElement { label: "Guided";  icon: "qrc:/resources/guidedModeIcon.svg";  action: "guided" }
        ListElement { label: "Takeoff"; icon: "qrc:/resources/takeoffIcon.svg";     action: "takeoff" }
        ListElement { label: "Return";  icon: "qrc:/resources/returnHomeIcon.svg";  action: "return" }
    }

    // Column layout for the buttons
    Column {
        id: commandColumn
        anchors.centerIn: parent

        // Repeater that iterates over the buttonModel and creates a column for each button
        Repeater {
            model: buttonModel 
            delegate: Column { 
                width: root.width

                Item {
                    width: parent.width
                    height: GcsStyle.PanelStyle.buttonSize + 14
                    opacity: root.commandDrone !== null ? 1.0 : 0.35

                    property bool hovered: false

                    property bool isActive: root.activeAction === model.action

                    // Hover/active highlight
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 10
                        height: parent.height - 6
                        radius: 8
                        color: parent.isActive
                               ? GcsStyle.PanelStyle.listItemSelectedColor
                               : parent.hovered
                                 ? GcsStyle.PanelStyle.listItemHoverColor
                                 : "transparent"
                    }

                    // Button icon and label
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            source: model.icon
                            sourceSize.width: GcsStyle.PanelStyle.iconSize
                            sourceSize.height: GcsStyle.PanelStyle.iconSize
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: model.label
                            color: GcsStyle.PanelStyle.textOnPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeXXS
                            font.family: GcsStyle.PanelStyle.fontFamily
                        }
                    }

                    // Hover enabler and click handler for each button
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                        onClicked: {
                            if (!root.commandDrone) return
                            root.activeAction = model.action
                            switch (model.action) {
                            case "arm":     armConfirmation.open();     break
                            case "guided":  guidedConfirmation.open();  break
                            case "takeoff": takeoffConfirmation.open(); break
                            case "return":  returnConfirmation.open();  break
                            }
                        }
                    }
                }

                // Divider line between buttons
                Rectangle {
                    width: parent.width * 0.7
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: GcsStyle.PanelStyle.defaultBorderColor
                    visible: index < buttonModel.count - 1 // Only show the divider between buttons, not after the last one
                }
            }
        }
    }

    // Confirmation popups for each action
    Components.UniversalPopup {
        id: armConfirmation
        onClosed: root.activeAction = ""
        popupTitle: "Arm the UAV?"
        popupMessage: root.commandDrone && root.commandDrone.name
                      ? "Are you sure you want to arm " + root.commandDrone.name + "?"
                      : "No UAV selected"
        onAccepted: {
            if (root.commandDrone)
                droneController.sendArm(root.commandDrone.xbeeAddress, true)
        }
    }

    Components.UniversalPopup {
        id: guidedConfirmation
        onClosed: root.activeAction = ""
        popupTitle: "Set UAV to Guided Mode"
        popupMessage: root.commandDrone && root.commandDrone.name
                      ? "Are you sure you want to set " + root.commandDrone.name + " to guided mode?"
                      : "No UAV selected"
        onAccepted: {
            if (root.commandDrone)
                droneController.sendGuidedMode(root.commandDrone.xbeeAddress, true)
        }
    }

    Components.UniversalPopup {
        id: takeoffConfirmation
        onClosed: root.activeAction = ""
        popupTitle: "Takeoff"
        popupMessage: root.commandDrone && root.commandDrone.name
                      ? "Are you sure you want to takeoff " + root.commandDrone.name + "?"
                      : "No UAV selected"
        onAccepted: {
            if (root.commandDrone)
                droneController.sendTakeoffCmd(root.commandDrone.xbeeAddress, true)
        }
    }

    Components.UniversalPopup {
        id: returnConfirmation
        onClosed: root.activeAction = ""
        popupTitle: "Return Home"
        popupMessage: root.commandDrone && root.commandDrone.name
                      ? "Send " + root.commandDrone.name + " back to home location?"
                      : "No UAV selected"
        onAccepted: {
            console.log("[TrackingPanelQuickCommands] Return Home: backend not yet implemented")
        }
    }
}
