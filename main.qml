import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Qt.labs.platform
import "./components" as Components
import "qrc:/gcsStyle" as GcsStyle

/*
  Our entry point for UI/GUI
  Displays all UI Components here
*/

Window {
    id: mainWindow
    width: 1280
    height: 720
    visible: true
    title: qsTr("GCS - Cal Poly Pomona")
    property var selectedDrones: [] // a list of DroneClass objects --- QML doesn't allow list<DroneClass>
    property var activeDrone: null // DroneClass type

    // Menu bar above the drone tracking panel
    DroneMenuBar {
        id: droneMenuBar
        activeDrone: mainWindow.activeDrone
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        z: 100
    }

    TelemetryPanel {
        id: telemetryPanel
        activeDrone: mainWindow.activeDrone
        anchors {
            bottom: parent.bottom
            margins: GcsStyle.PanelStyle.applicationBorderMargin
        }
    }

    Item {
        id: contentArea
        anchors {
            top: droneMenuBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                id: leftPanelColumn
                Layout.preferredWidth: 350
                Layout.minimumWidth: 350
                Layout.fillHeight: true

                DroneTrackingPanel {
                    id: droneTrackingPanel
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: messageLogPanel.top
                    }

                    onSelectionChanged: function(selected) { updateActiveDrone(selected) }
                    onActiveDroneChanged: function(activeDrone) { mainWindow.activeDrone = activeDrone }
                    onFollowRequested: function(drone) {
                        if (!drone) {
                            console.warn("Follow requested without a drone reference")
                            return
                        }
                        mapComponent.turnOffFollowDrone()
                        mapComponent.turnOnFollowDrone()
                    }
                }

                MessageLogPanel {
                    id: messageLogPanel
                    droneStatusPanel: leftPanelColumn
                    anchors {
                        left: leftPanelColumn.left
                        right: leftPanelColumn.right
                        bottom: leftPanelColumn.bottom
                    }
                    z: 100
                }

                Connections {
                    target: logger
                    function onLogReceived(type, message) {
                        messageLogPanel.appendLog(type, message)
                    }
                }
            }

            Item {
                id: mapArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                QmlMap {
                    id: mapComponent
                    anchors.fill: parent
                    activeDrone: mainWindow.activeDrone
                    selectedDrones: mainWindow.selectedDrones // Not yet implemented. But will be like this
                    onZoomScaleChanged: function(coord1, coord2, pixelLength) {
                        mapScaleBar.updateScaleBar(coord1, coord2, pixelLength)
                    }
                    onMapInitialized: function(coord1, coord2, pixelLength) {
                        mapScaleBar.updateScaleBar(coord1, coord2, pixelLength)
                    }
                }

                MapScaleBarIndicator {
                    id: mapScaleBar
                    anchors {
                        bottom: parent.bottom
                        left: mapTypeButton.right
                        margins: GcsStyle.PanelStyle.applicationBorderMargin
                    }
                }

                MapDisplayTypeButton {
                    id: mapTypeButton
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        leftMargin: GcsStyle.PanelStyle.applicationBorderMargin
                        bottomMargin: GcsStyle.PanelStyle.applicationBorderMarginBottom
                    }
                }

                DroneCommandPanel {
                    id: droneCommandPanel
                    waypointManager: mapComponent.waypointManagerRef
                    activeDrone: mainWindow.activeDrone
                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: GcsStyle.PanelStyle.applicationBorderMargin
                    }
                    visible: false
                    allowAutoShow: droneTrackingPanel.activePanel === "drones"

                    Connections {
                        target: droneTrackingPanel
                        function onActivePanelChanged() {
                            if (droneTrackingPanel.activePanel !== "drones")
                                droneCommandPanel.visible = false
                        }
                    }
                }

                MissionPlanPanel {
                    id: missionPlanPanel
                    activeDrone: mainWindow.activeDrone
                    visible: droneTrackingPanel.activePanel === "mission"
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                    }
                }

                TrackingPanelQuickCommands {
                    anchors {
                        top: parent.top
                        left: parent.left
                        topMargin: 8
                        leftMargin: 8
                    }
                    visible: droneTrackingPanel.activePanel === "drones"
                    commandDrone: mainWindow.activeDrone
                    z: 200
                }
            }
        }
    }

    // Shortcut for toggling follow functionality (cmd + f or ctrl + f)
    Shortcut {
        sequence: StandardKey.Find
        onActivated: mapComponent.toggleFollowDrone()
    }

    // Shortcut to open Settings window (Ctrl+. on Windows / Cmd+. on Mac)
    Shortcut {
        sequence: "Ctrl+."
        onActivated: openSettingsWindow()
    }

    // Command ACK toast notification listener
    // TODO: have drone class handle its own notifications
    Connections {
        target: droneController
        function onCommandAcknowledged(message, success) {
            toastNotification.show(message, success)
        }
    }

    // Toast notification
    Components.ToastNotification {
        id: toastNotification
        anchors {
            top: droneMenuBar.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 12
        }
    }


    // Settings window
    Loader {
        id: settingsLoader
        source: "qrc:/settingsWindow.qml"
    }

    function openSettingsWindow() {
        settingsLoader.item.show()
        settingsLoader.item.raise()
    }

    // Save map state when app closes (for "leave at last location" settings feature)
    onClosing: {
        settingsManager.lastMapLat = mapComponent.latitude
        settingsManager.lastMapLong = mapComponent.longitude
        settingsManager.lastMapZoom = mapComponent.zoomLevel
    }

    Component.onCompleted: {
        droneController.openUDP(14550, "127.0.0.1", 14550)
        // droneController.openUART("/dev/ttys005", 57600)
        // droneController.openUART("/dev/cu.usbserial-AQ015EBI", 57600)
    }

    function updateActiveDrone(selected) {
        if (selected.length < 1) activeDrone = null
        selectedDrones = selected
    }
}
