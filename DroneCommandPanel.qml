import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: mainPanel
    width: 280
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius

    // has the collapsed form opened by default for main panel
    property bool expanded: false
    property var activeDrone: null
    property int commandsBodyHeight: 0
    property int configBodyHeight: 0
    property int maxPanelHeight: Math.max(tabColumn.childrenRect.height, maxBodyHeight) // comparing the height between the expandedBody and tabColumn
    property int maxBodyHeight: Math.max(commandsBodyHeight, configBodyHeight)  // commparing the height between the expandedBody (commands/config) pages
    property string currentTab: "Commands"
    property var waypointManager   // reference to Waypoint.qml
    property bool showingWaypoints: false
    property int waypointVersion: 0  // increment to refresh ListView


    // The Loaders: loads in invisible object to measure the
    // height of each panel, helps us determine
    // how tall the expanded panel will be
    Loader {
        id: commandsBodyMeasure
        sourceComponent: commandsBody
        visible: false
        onLoaded: commandsBodyHeight = item.implicitHeight
    }

    Loader {
        id: configBodyMeasure
        sourceComponent: configBody
        visible: false
        onLoaded: configBodyHeight = item.implicitHeight
    }


    function expand() {
        mainPanel.expanded = true
    }

    function collapse() {
        mainPanel.expanded = false
    }


    //drone status for buttons
    readonly property int statusNotAvailable: 0
    readonly property int statusInProgress: 1
    readonly property int statusAvailable: 2




    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            // Header aka collapsed view
            Rectangle {
                z: 2
                Layout.fillWidth: true
                height: GcsStyle.PanelStyle.headerHeight + 10
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            id: droneNameText
                            text: activeDrone ? activeDrone.name: ""
                            font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                            font.bold: true
                            color: GcsStyle.PanelStyle.textPrimaryColor
                        }

                        // spacer
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }

                        // collapse/expand arrow button
                        Button {
                            id: collapseButton
                            padding: 4
                            icon.width: 28 - padding * 2
                            icon.height: 24 - padding * 2
                            icon.source: mainPanel.expanded ? "qrc:/resources/arrow-up.png" : "qrc:/resources/arrow-down.png"
                            icon.color: GcsStyle.PanelStyle.textPrimaryColor
                            Layout.alignment: Qt.AlignTop | Qt.AlignRight

                            background: Rectangle {
                                border.width: 0
                                color: GcsStyle.PanelStyle.buttonColor
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mainPanel.expanded = !mainPanel.expanded
                        }
                    }
                }
            }

            //expanded form
            Rectangle {
                id: expandedBody
                z: 1
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                Layout.topMargin: -20   //so the expanded/collapse view overlap and dont show ugly rounded corner
                Layout.fillWidth: true
                clip: true

                property int paddingHeight: bodyLoader.anchors.topMargin + bodyLoader.anchors.bottomMargin  // including the height of the margin padding in our overall panel height
                Layout.preferredHeight: mainPanel.expanded ? (maxPanelHeight + paddingHeight) : 0

                ListModel {
                    id: repeaterModel

                    ListElement {
                        name: "Go To"; //; destination:
                    }
                    ListElement {
                        name: "Return Home";//; destination:
                    }
                    ListElement {
                        name: "Hover"; //; destination:
                    }
                    ListElement {
                        name: "Waypoints"; //; destination:
                    }
                    ListElement {
                        name: "Do A Flip!"; //; destination:
                    }
                    ListElement {
                        name: "Connect"; //; destination:
                    }
                    ListElement {
                        name: "Evaluate Fleet"; //; destination:
                    }
                    ListElement {
                        name: "Arm Motors"; //; destination:
                    }
                    ListElement {
                        name: "Diagnose"; //; destination:
                    }
                }

                // mock status for testing
                property var buttonStatuses: ({
                    "Go To": statusAvailable, "Return Home": statusAvailable, "Hover": statusAvailable,"Waypoints": statusAvailable, "Do A Flip!": statusAvailable, "Connect": statusAvailable, "Evaluate Fleet": statusAvailable, "Arm Motors": statusAvailable, "Diagnose": statusAvailable
                })

                Loader {
                    id: bodyLoader
                    anchors.fill: parent
                    anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.bottomMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.topMargin: 20

                    sourceComponent: {
                        if (mainPanel.currentTab !== "Commands")
                            return configBody

                        if (mainPanel.showingWaypoints)
                            return waypointsBody

                        return commandsBody
                    }
                }
            }
        }

        // column housing the tabs on the right side of the panel
        Column {
            id: tabColumn
            width: 24

            // rectangle button for the commands tab
            Rectangle {
                id: commandsTab
                width: 24
                height: 90
                radius: GcsStyle.PanelStyle.buttonRadius
                visible: mainPanel.expanded

                // this statement has the tab match the body color of the current panel, with the other grayed out
                color: mainPanel.currentTab === "Commands" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor

                // overlayed rectangle on the top left corner so that only the outer corners appear rounded
                Rectangle {
                    width: 7
                    height: 7
                    color: mainPanel.currentTab === "Commands" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor
                    x: 0; y: 0
                }

                // overlayed rectangle on the bottom left corner so that only the outer corners appear rounded
                Rectangle {
                    width: 7
                    height: 7
                    color: mainPanel.currentTab === "Commands" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor
                    x:0; y: parent.height - 7
                }

                Text {
                    anchors.centerIn: parent
                    text: "Commands"
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    rotation: 90
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mainPanel.currentTab = "Commands"
                }
            }

            // rectangle button for the configuration tab
            Rectangle {
                id: configTab
                width: 24
                height: 60
                radius: GcsStyle.PanelStyle.buttonRadius
                visible: mainPanel.expanded

                // this statement has the tab match the body color of the current panel, with the other grayed out
                color: mainPanel.currentTab === "Config" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor

                // overlayed rectangle on the top left corner so that only the outer corners appear rounded
                Rectangle {
                    width: 7
                    height: 7
                    color: mainPanel.currentTab === "Config" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor
                    x: 0; y: 0
                }

                // overlayed rectangle on the bottom left corner so that only the outer corners appear rounded
                Rectangle {
                    width: 7
                    height: 7
                    color: mainPanel.currentTab === "Config" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor
                    x:0; y: parent.height - 7
                }

                Text {
                    anchors.centerIn: parent
                    text: "Config"
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    rotation: 90
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mainPanel.currentTab = "Config"
                }
            }
        }
    }

    // content on 'commands' tab
    Component {
        id: commandsBody

        ColumnLayout {
            spacing: 0

            // repeater model used to create the dynamic buttons
            Repeater {
                model: repeaterModel
                delegate: Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize

                    background: Rectangle {
                            border.width: 0.05
                            radius: GcsStyle.PanelStyle.buttonRadius
                            color: hovered ? GcsStyle.PanelStyle.buttonHoverColor : GcsStyle.PanelStyle.buttonColor
                        }

                    // gets button status
                    property int status: expandedBody.buttonStatuses[modelData] ?? statusNotAvailable

                    enabled: status === statusAvailable     // button only clickable for when status is available
                    hoverEnabled: enabled

                    // icon and text for each button
                    contentItem: RowLayout {
                        spacing: 2
                        anchors.margins: 6

                        // the icon for each button command (the 'source:..." under Image is a placeholder)
                        Item {
                            Layout.preferredWidth: GcsStyle.PanelStyle.iconSize
                            height: GcsStyle.PanelStyle.iconSize
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                //source: "https://supertails.com/cdn/shop/articles/360_f_681163919_71bp2aiyziip3l4j5mbphdxtipdtm2zh_e2c1dbbd-e3b0-4c7d-bc09-1ebff39513ef.jpg?v=1747293323"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        //changing text color based on the action's status
                        Text {
                            text: name
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            font.family: GcsStyle.PanelStyle.fontFamily
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true

                            color: {
                                if (status === statusNotAvailable)
                                    return GcsStyle.PanelStyle.commandNotAvailable
                                else if (status === statusInProgress)
                                    return GcsStyle.PanelStyle.commandInProgress
                                else
                                    return GcsStyle.PanelStyle.commandAvailable
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log ("opening", text)
                            if (name === "Waypoints") {
                                mainPanel.showingWaypoints = true
                                return
                            }

                            if (status === statusAvailable) {
                                status = statusInProgress

                                console.log ("Action started:", text)
                            }
                        }  
                    }
                }
            }

            // spacer so the buttons stay at the top
            Item {
                Layout.fillHeight: true
            }
        }
    }
    // content on 'Waypoints' tab
    Component {
        id: waypointsBody

        ColumnLayout {
            spacing: 6

            Text {
                text: "Waypoint Queue"
                font.bold: true
                color: GcsStyle.PanelStyle.textPrimaryColor
            }

            // Waypoint queue list -- model is fetched from MissionManager each
            // time waypointVersion increments (triggered by waypointsChanged signal)
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: {
                    if (!activeDrone)
                        return []
                    waypointVersion
                    return missionManager.getWaypoints(activeDrone.xbeeAddress)
                }

                delegate: Rectangle {
                    height: 32
                    width: parent.width
                    color: GcsStyle.PanelStyle.secondaryColor
                    radius: 4

                    Text {
                        text: index === 0 ? "Origin" : "WP " + index
                        color: "#9ccfff"
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                    }

                    Text {
                        text: Number(modelData.lat).toFixed(5) + ", " + Number(modelData.lon).toFixed(5)
                        color: GcsStyle.PanelStyle.textPrimaryColor
                        anchors.left: parent.left
                        anchors.leftMargin: 70
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Button {
                text: "Back to Commands"
                onClicked: {
                    mainPanel.showingWaypoints = false
                }

                // Set text color to white
                contentItem: Text {
                    text: "Back to Commands"
                    color: "white"
                    font.pixelSize: 16   // optional, adjust size
                    anchors.centerIn: parent
                }

                background: Rectangle {
                    // Sets a fixed background color for the button
                    color: GcsStyle.PanelStyle.buttonColor2
                    radius: 5
                    border.width: GcsStyle.PanelStyle.defaultBorderWidth
                    border.color: GcsStyle.PanelStyle.defaultBorderColor
                }
            }
        }
    }

    // content on 'config' tab
    Component {
        id: configBody

        Text {
            text: "hi"
            color: GcsStyle.PanelStyle.textPrimaryColor
        }
    }

    onActiveDroneChanged: {
        if (activeDrone === null) {
            mainPanel.visible = false;
        } else {
            mainPanel.visible = true;
        }
    }
    // Refresh the waypoint ListView whenever MissionManager reports a change
    // for the currently selected drone
    Connections {
        target: missionManager
        function onWaypointsChanged(uavID) {
            if (activeDrone && uavID === activeDrone.xbeeAddress) {
                mainPanel.waypointVersion++
            }
        }
    }
}
