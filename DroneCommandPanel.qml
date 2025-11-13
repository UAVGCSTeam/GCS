import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: mainPanel
    width: 320
    color: GcsStyle.PanelStyle.secondaryColor
    radius: GcsStyle.PanelStyle.cornerRadius

    signal commandActivated(string commandName)

    property bool expanded: false
    property var activeDrone: null

    readonly property var commandGroups: [
        { title: "Ground", commands: ["Connect", "Arm Drone", "Take Off"] },
        { title: "In-Flight", commands: ["Waypointing", "Go Home", "Hover"] }
    ]

    readonly property int statusNotAvailable: 0
    readonly property int statusInProgress: 1
    readonly property int statusAvailable: 2

    property var commandStateMap: defaultCommandStates()

    function defaultCommandStates() {
        // Demo: mix of states so visual differences are obvious
        return {
            "Connect": statusAvailable,
            "Arm Drone": statusAvailable,
            "Take Off": statusAvailable,
            "Waypointing": statusNotAvailable,  // unavailable
            "Go Home": statusAvailable,
            "Hover": statusNotAvailable         // unavailable
        }
    }

    onActiveDroneChanged: {
        commandStateMap = defaultCommandStates()
        if (!activeDrone) {
            expanded = false
            expandedBody.setCollapsedHeight()
        }
    }

    function setCommandStatus(commandName, status) {
        var updated = Object.assign({}, commandStateMap)
        updated[commandName] = status
        commandStateMap = updated
    }

    function commandVisualState(commandName) {
        var status = commandStateMap[commandName]
        if (status === statusInProgress)
            return "loading"
        if (status === statusAvailable || status === undefined)
            return "selectable"
        return "unavailable"
    }

    function isCommandHoverable(state) {
        return state === "selectable" || state === "loading"
    }

    function backgroundColorFor(state, hovered) {
        if (state === "unavailable")
            return GcsStyle.PanelStyle.buttonUnavailableColor
        if (state === "loading")
            return GcsStyle.PanelStyle.secondaryColor   // keep loading on primary
        // selectable
        return hovered ? GcsStyle.PanelStyle.buttonHoverColor : GcsStyle.PanelStyle.secondaryColor
    }


    function textColorFor(state) {
        if (state === "unavailable")
            // lighter gray text
            return "#959595"
        if (state === "loading")
            return "#A67400"
        return GcsStyle.PanelStyle.textPrimaryColor
    }

    function iconForState(state) {
        // no icon for now (including loading)
        return ""
    }

    function iconColorFor(state) {
        return state === "loading" ? "#A67400" : "transparent"
    }

    function stripeColorFor(state) {
        if (state === "loading")
            return "#D0B36B"   // warm gold accent for loading
        if (state === "unavailable")
            return "#D8D8D8"   // muted gray accent for unavailable
        return "#7AAFC3"       // accent for selectable
    }

    function handleCommandInvoked(commandName) {
        console.log("Command invoked:", commandName)
        commandActivated(commandName)
        setCommandStatus(commandName, statusInProgress)
        if (commandName == "Arm Drone") { 
            droneController.sendArm("11062025", true)
        } else if (commandName == "Take Off") { 
                const target = "11062025" // the custom SITL drone
                const ok = droneController.sendTakeoffCmd(target)   // true = arm, false = disarm
                console.log("TAKEOFF ->", target, ok)
        }

        setCommandStatus(commandName, statusAvailable)
    }

    function expand() {
        if (!activeDrone)
            return
        expanded = true
        expandedBody.expand()
    }

    function collapse() {
        expanded = false
        expandedBody.collapse()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerPanel
            Layout.fillWidth: true
            height: GcsStyle.PanelStyle.headerHeight + 10
            color: GcsStyle.PanelStyle.primaryColor
            radius: GcsStyle.PanelStyle.cornerRadius
            clip: true
            border.width: 0
            z: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: GcsStyle.PanelStyle.defaultMargin
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        id: droneNameText
                        text: activeDrone ? activeDrone.name : "No drone selected"
                        font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                        font.bold: true
                        color: activeDrone ? "#DFECFF" : "#9E9E9E"
                        wrapMode: Text.WrapAnywhere
                        Layout.fillWidth: true
                    }

                    Button {
                        id: collapseButton
                        enabled: activeDrone !== null
                        opacity: enabled ? 1 : 0.25
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        implicitWidth: 28
                        implicitHeight: 24

                        background: Rectangle {
                            border.width: 0
                            color: "white"
                            height: 10
                            width: 10
                            radius: 7
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: activeDrone !== null
                            cursorShape: activeDrone ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (!activeDrone)
                                    return
                                if (expanded) {
                                    mainPanel.collapse()
                                } else {
                                    mainPanel.expand()
                                }
                            }
                        }
                    }
                }

                Text {
                    text: activeDrone ? "Commands" : "Select a drone to view commands"
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                    color: activeDrone ? GcsStyle.PanelStyle.textOnPrimaryColor : "#B0B0B0"
                }
            }
        }

        Rectangle {
            id: expandedBody
            Layout.topMargin: -6
            Layout.fillWidth: true
            Layout.preferredHeight: 0
            color: GcsStyle.PanelStyle.primaryColor
            radius: GcsStyle.PanelStyle.cornerRadius
            clip: true
            opacity: activeDrone ? 1 : 0.2
            enabled: activeDrone !== null
            visible: activeDrone !== null
            z: 1

            PropertyAnimation {
                id: bodyAnimation
                target: expandedBody
                property: "Layout.preferredHeight"
                easing.type: Easing.InOutQuad
                duration: 250
            }

            function desiredHeight() {
                if (!activeDrone)
                    return 0
                return content.implicitHeight + (GcsStyle.PanelStyle.defaultMargin * 2)
            }

            function expand() {
                bodyAnimation.stop()
                bodyAnimation.from = Layout.preferredHeight
                bodyAnimation.to = desiredHeight()
                bodyAnimation.running = true
            }

            function collapse() {
                bodyAnimation.stop()
                bodyAnimation.from = Layout.preferredHeight
                bodyAnimation.to = 0
                bodyAnimation.running = true
            }

            function syncToContent() {
                if (mainPanel.expanded && activeDrone) {
                    bodyAnimation.stop()
                    Layout.preferredHeight = desiredHeight()
                }
            }

            function setCollapsedHeight() {
                bodyAnimation.stop()
                Layout.preferredHeight = 0
            }

            ColumnLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: GcsStyle.PanelStyle.defaultMargin
                spacing: 12
                Layout.fillWidth: true
                visible: activeDrone !== null

                onImplicitHeightChanged: expandedBody.syncToContent()

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 12
                }

                Repeater {
                    model: commandGroups
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        property var group: modelData

                        Text {
                            text: group.title
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            color: GcsStyle.PanelStyle.textOnPrimaryColor
                        }

                        Repeater {
                            model: group.commands
                            delegate: commandDelegate
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                }
            }
        }

        Component {
            id: commandDelegate

            Button {
                id: commandButton
                Layout.fillWidth: true
                Layout.leftMargin: 12
                implicitHeight: background.implicitHeight
                Layout.preferredHeight: implicitHeight
                hoverEnabled: visualState !== "unavailable"

                property string commandName: modelData
                property string visualState: mainPanel.commandVisualState(commandName)

                enabled: visualState !== "unavailable"
                onClicked: {
                    if (visualState === "selectable") {
                        mainPanel.handleCommandInvoked(commandName)
                    }
                }

                background: Rectangle {
                    id: background
                    radius: 4
                    color: mainPanel.backgroundColorFor(visualState, commandButton.hovered && commandButton.enabled)
                    border.width: 0
                    implicitHeight: commandRow.implicitHeight + 18
                    clip: true
                    opacity: visualState === "unavailable" ? 0.9 : 1
                }

                contentItem: RowLayout {
                    id: commandRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: mainPanel.iconForState(visualState)
                        visible: text.length > 0
                        color: mainPanel.iconColorFor(visualState)
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: commandName
                        color:  mainPanel.textColorFor(visualState)
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        elide: Text.ElideRight
                        opacity: 1
                    }
                }
            }
        }
    }
}

