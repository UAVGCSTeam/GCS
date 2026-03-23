import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

/*
 * MissionPlanPanel.qml
 *
 * Right-side panel displayed when the user switches to the "Mission Planning"
 * nav tab in DroneTrackingPanel.  It shows the active mission for whichever
 * drone is currently selected and lets the user start or clear that mission.
 *
 * Data flow:
 *   - activeDrone (DroneClass*) is passed in from main.qml via the activeDrone property.
 *   - Waypoints are fetched from MissionManager (C++ context property) using the
 *     drone's xbeeAddress as the key.
 *   - The local `waypoints` list is refreshed whenever activeDrone changes, 
 *     or MissionManager emits waypointsChanged for this drone.
 *   - Index 0 of the MissionManager waypoint list is always the auto-generated
 *     origin (the drone's position when the first waypoint was placed) and is
 *     intentionally excluded from the UI — only user-placed waypoints are shown.

 */

Rectangle {
    id: missionPanel
    width: 280
    color: GcsStyle.PanelStyle.primaryColor

    // DroneClass* set by main.qml; null when no drone is selected
    property var activeDrone: null

    // Full waypoint list from MissionManager (index 0 = auto origin, excluded from UI)
    property var waypoints: []

    // User-placed waypoints only (index 1 onwards)
    property var userWaypoints: waypoints.length > 1 ? waypoints.slice(1) : []

    // Tab state — "Manual" is the only implemented mode for now
    property string activeTab: "Manual"

    // Pull the latest waypoints from MissionManager for the active drone
    function refreshWaypoints() {
        if (!activeDrone) {
            waypoints = []
            return
        }
        waypoints = missionManager.getWaypoints(activeDrone.xbeeAddress)
    }

    onActiveDroneChanged: refreshWaypoints()

    // Re-fetch whenever MissionManager reports a change for this drone
    Connections {
        target: missionManager
        function onWaypointsChanged(uavID) {
            if (activeDrone && uavID === activeDrone.xbeeAddress)
                missionPanel.refreshWaypoints()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Tabs ─────────────────────────────────────────────────────────────
        // "Manual" and "Other" tabs with rounded top corners only.
        // The active tab blends into the panel background; inactive sits on baseBackground.
        Row {
            Layout.fillWidth: true
            height: 34

            Repeater {
                model: ["Manual", "Other"]

                Rectangle {
                    width: missionPanel.width / 2
                    height: 34
                    radius: 8
                    color: missionPanel.activeTab === modelData
                           ? GcsStyle.PanelStyle.primaryColor
                           : GcsStyle.PanelStyle.baseBackground

                    // Square off the bottom corners so only the top is rounded
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.radius
                        color: parent.color
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: missionPanel.activeTab === modelData
                               ? GcsStyle.PanelStyle.textPrimaryColor
                               : GcsStyle.PanelStyle.textSecondaryColor
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        font.family: GcsStyle.PanelStyle.fontFamily
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: missionPanel.activeTab = modelData
                    }
                }
            }
        }

        // ── Header ───────────────────────────────────────────────────────────
        // Shows "Mission Plan:" and the name of the currently selected drone.
        Item {
            Layout.fillWidth: true
            height: 56

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.topMargin: 8
                spacing: 2

                Text {
                    text: "Mission Plan:"
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium + 4
                    font.bold: true
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    font.family: GcsStyle.PanelStyle.fontFamily
                }
                Text {
                    text: activeDrone ? activeDrone.name : "No drone selected"
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    color: GcsStyle.PanelStyle.textSecondaryColor
                    font.family: GcsStyle.PanelStyle.fontFamily
                }
            }
        }

        // ── Empty state ───────────────────────────────────────────────────────
        // Shown when there are no user-placed waypoints.
        // Message changes depending on whether a drone is selected or not.
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: userWaypoints.length === 0

            Text {
                anchors.centerIn: parent
                text: !activeDrone
                      ? "Select a drone to\nplan a mission."
                      : "No waypoints yet.\nClick on the map to\nadd waypoints."
                horizontalAlignment: Text.AlignHCenter
                color: GcsStyle.PanelStyle.textSecondaryColor
                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                font.family: GcsStyle.PanelStyle.fontFamily
            }
        }

        // ── Waypoint list ─────────────────────────────────────────────────────
        // Each waypoint is a collapsible card. Cards start collapsed and animate
        // open to reveal lat/lon when the user clicks them.
        ListView {
            id: waypointListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: userWaypoints.length > 0
            model: userWaypoints
            spacing: 6
            topMargin: 4
            bottomMargin: 4

            delegate: Item {
                id: wpItem
                width: ListView.view.width

                property bool expanded: false

                // collapsed: 44px  |  expanded: header(44) + separator(1) + content + bottomPad(4)
                property int collapsedH: 44
                property int expandedH:  140
                height: expanded ? expandedH : collapsedH

                Behavior on height { NumberAnimation { duration: 130; easing.type: Easing.InOutQuad } }

                // ── Outer card ───────────────────────────────────────────────
                // Rounded card with 8px horizontal margin from the panel edge.
                // Border switches from subtle grey (collapsed) to aqua (expanded).
                Rectangle {
                    id: outerCard
                    x: 8
                    width: parent.width - 16
                    height: parent.height
                    radius: GcsStyle.PanelStyle.cornerRadius
                    color: GcsStyle.PanelStyle.cardBackground
                    clip: true

                    // Transparent border overlay rendered above all children so it
                    // is never covered by the header or content area backgrounds.
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: wpItem.expanded ? GcsStyle.PanelStyle.listItemSelectedBorderColor
                                                      : GcsStyle.panelStyle.defaultBorderColor
                        border.width: 1
                        z: 10
                    }

                    // ── Header row ───────────────────────────────────────────
                    // Always visible. Background turns aqua when expanded to
                    // visually distinguish it from the content area below.
                    Item {
                        id: headerCard
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: wpItem.collapsedH

                        Rectangle {
                            anchors.fill: parent
                            color: wpItem.expanded ? GcsStyle.PanelStyle.listItemSelectedColor
                                                   : GcsStyle.PanelStyle.cardBackground
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 6

                            Text {
                                text: (index + 1) + "."
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Waypoint"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Text {
                                text: wpItem.expanded ? "▲" : "▼"
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wpItem.expanded = !wpItem.expanded
                        }
                    }

                    // Aqua 1px separator between the header and expanded content
                    Rectangle {
                        visible: wpItem.expanded
                        anchors.top: headerCard.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: GcsStyle.PanelStyle.listItemSelectedBorderColor
                        opacity: wpItem.expanded ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                    }

                    // ── Expanded content ─────────────────────────────────────
                    // Shows lat/lon in read-only white text boxes (editable style
                    // matches Figma; write support requires backend API extension).
                    Rectangle {
                        id: contentArea
                        visible: wpItem.expanded
                        opacity: wpItem.expanded ? 1.0 : 0.0
                        anchors.top: headerCard.bottom
                        anchors.topMargin: 1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        radius: GcsStyle.PanelStyle.cornerRadius
                        color: GcsStyle.PanelStyle.primaryColor
                        clip: true

                        Behavior on opacity { NumberAnimation { duration: 100 } }

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 10
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 26
                                spacing: 8

                                Text {
                                    text: "Latitude:"
                                    color: GcsStyle.PanelStyle.textSecondaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                    font.family: GcsStyle.PanelStyle.fontFamily
                                    Layout.preferredWidth: 70
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 22
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 4
                                    color: "white"
                                    border.color: GcsStyle.panelStyle.defaultBorderColor
                                    border.width: GcsStyle.panelStyle.defaultBorderWidth

                                    TextInput {
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        anchors.rightMargin: 6
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: modelData.lat.toFixed(6)
                                        readOnly: true
                                        color: "#1D1D1F"
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 26
                                spacing: 8

                                Text {
                                    text: "Longitude:"
                                    color: GcsStyle.PanelStyle.textSecondaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                    font.family: GcsStyle.PanelStyle.fontFamily
                                    Layout.preferredWidth: 70
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 22
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 4
                                    color: "white"
                                    border.color: GcsStyle.panelStyle.defaultBorderColor
                                    border.width: GcsStyle.panelStyle.defaultBorderWidth

                                    TextInput {
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        anchors.rightMargin: 6
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: modelData.lon.toFixed(6)
                                        readOnly: true
                                        color: "#1D1D1F"
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Action buttons ────────────────────────────────────────────────────
        // Only visible when a drone is selected.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            Layout.bottomMargin: 12
            spacing: 6
            visible: activeDrone !== null

            // Sends the current waypoint queue to the drone via MissionManager.startMission()
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: GcsStyle.PanelStyle.buttonRadius
                color: saveHover ? Qt.rgba(0, 0.831, 1, 0.20) : GcsStyle.PanelStyle.listItemSelectedColor
                border.color: GcsStyle.PanelStyle.listItemSelectedBorderColor
                border.width: 1
                property bool saveHover: false

                Text {
                    anchors.centerIn: parent
                    text: "Save Route to Drone"
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    font.family: GcsStyle.PanelStyle.fontFamily
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.saveHover = true
                    onExited:  parent.saveHover = false
                    onClicked: { if (activeDrone) missionManager.startMission(activeDrone.xbeeAddress) }
                }
            }

            // Discards all waypoints for this drone via MissionManager.removeMission()
            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: GcsStyle.PanelStyle.buttonRadius
                color: clearHover ? GcsStyle.PanelStyle.buttonHoverColor : "transparent"
                border.color: GcsStyle.panelStyle.defaultBorderColor
                border.width: GcsStyle.panelStyle.defaultBorderWidth
                property bool clearHover: false

                Text {
                    anchors.centerIn: parent
                    text: "Clear Mission"
                    color: GcsStyle.PanelStyle.textSecondaryColor
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                    font.family: GcsStyle.PanelStyle.fontFamily
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.clearHover = true
                    onExited:  parent.clearHover = false
                    onClicked: { if (activeDrone) missionManager.removeMission(activeDrone.xbeeAddress) }
                }
            }
        }
    }
}
