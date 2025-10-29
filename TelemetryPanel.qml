import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

/**
This telemetry panel works by making a container, and a visible telemetry window.
This is necessary in order to have window scaling. When getting the mouse.x and mouse.y positions within MouseArea,
those positions are relative to the coordinate system of the MouseArea. This means that when the
MouseArea is moved, the coordinates of the user's mouse is affected.

To get around this scaling issue, we've implemented a container around the visible telem panel.
Now when scaling the panel, the mouse area stays static --- until the user releases the mouse.
When the user releases the mouse, the container is resized to fit the visible telem panel.
**/

Rectangle {
    // This is the container element
    id: mainPanel
    height: 320
    width: 420
    color: "transparent"
    visible: false
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    property var activeDrone: null // updated by the updateSelectedDroneModel function
    property int minPanelWidth: 420
    property int minPanelHeight: 320
    property int resizeHandleSize: 20
    property int statusHeight: 0
    property int trackingWidth: 0

    Rectangle {
        // This is the visible telem container element
        id: telemMain
        color: "#80000000"
        radius: GcsStyle.PanelStyle.cornerRadius
        width: parent.width
        height: parent.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        border.color: "#22FFFFFF"
        border.width: 1

        ListModel { id: activeDroneModel }

        // Prevent wheel from bubbling to map behind
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: false
            onWheel: wheel.accepted = true
        }

        // Double-click handler
        Item {
            anchors.fill: parent
            TapHandler {
                acceptedDevices: PointerDevice.Mouse // listens for mouse taps
                grabPermissions: PointerHandler.TakeOverForbidden

                onDoubleTapped: (eventPoint) => {
                    const localPos = eventPoint.position;
                    const handleSize = topLeftResizeHandle.width;

                    if (localPos.x < handleSize && localPos.y < handleSize)
                        return;

                    const gap = GcsStyle.PanelStyle.applicationBorderMargin;
                    const maxW = telemMain.parent.parent.width - trackingWidth - (3 * gap);
                    const maxH = telemMain.parent.parent.height - statusHeight - (3 * gap);
                    const minW = mainPanel.minPanelWidth;
                    const minH = mainPanel.minPanelHeight;

                    const midW = (minW + maxW) / 2;
                    const midH = (minH + maxH) / 2;

                    if (telemMain.width > midW || telemMain.height > midH) {
                        telemMain.width = minW;
                        telemMain.height = minH;
                        mainPanel.width = minW;
                        mainPanel.height = minH;
                    } else {
                        telemMain.width = maxW;
                        telemMain.height = maxH;
                        mainPanel.width = maxW;
                        mainPanel.height = maxH;
                    }
                }
            }
        }

        // Main Content

        Item {
            anchors.fill: parent
            anchors.margins: 15
            anchors.topMargin: 25

            property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)

            // Organized Grid Layout
            GridLayout {
                anchors.fill: parent
                columns: 3
                rowSpacing: 12
                columnSpacing: 15

                // Position Section
                TelemetryItem {
                    label: "Latitude"
                    value: parent.parent.row ? (parent.parent.row.latitude || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "Longitude"
                    value: parent.parent.row ? (parent.parent.row.longitude || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "Altitude"
                    value: parent.parent.row ? (parent.parent.row.altitude || "") : ""
                    Layout.fillWidth: true
                }

                // Speed Section
                TelemetryItem {
                    label: "Airspeed"
                    value: parent.parent.row ? (parent.parent.row.airspeed || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "Groundspeed"
                    value: parent.parent.row ? (parent.parent.row.groundspeed || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "Climb Rate"
                    value: parent.parent.row ? (parent.parent.row.climbRate || "") : ""
                    Layout.fillWidth: true
                }

                // Orientation Section
                TelemetryItem {
                    label: "Pitch"
                    value: parent.parent.row ? (parent.parent.row.pitch || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "Yaw"
                    value: parent.parent.row ? (parent.parent.row.yaw || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "GPS Sats"
                    value: parent.parent.row ? (parent.parent.row.satCount || "") : ""
                    Layout.fillWidth: true
                }

                // Status Section
                TelemetryItem {
                    label: "Battery"
                    value: parent.parent.row ? (parent.parent.row.battery || "") : ""
                    Layout.fillWidth: true
                    valueColor: {
                        if (!parent.parent.row || !parent.parent.row.battery) return "white"
                        var batteryStr = parent.parent.row.battery.toString()
                        var batteryNum = parseFloat(batteryStr.replace('%', ''))
                        if (batteryNum < 20) return "#ff4444"
                        if (batteryNum < 40) return "#ffaa00"
                        return "#44ff44"
                    }
                }
                TelemetryItem {
                    label: "Status"
                    value: parent.parent.row ? (parent.parent.row.status || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "Mode"
                    value: parent.parent.row ? (parent.parent.row.mode || "") : ""
                    Layout.fillWidth: true
                }

                // System Section
                TelemetryItem {
                    label: "Flight Time"
                    value: parent.parent.row ? (parent.parent.row.flightTime || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "Latency"
                    value: parent.parent.row ? (parent.parent.row.Latency || "") : ""
                    Layout.fillWidth: true
                }
                TelemetryItem {
                    label: "FailSafe"
                    value: parent.parent.row ? (parent.parent.row.FailSafeTriggered || "") : ""
                    Layout.fillWidth: true
                    valueColor: {
                        if (!parent.parent.row || !parent.parent.row.FailSafeTriggered) return "white"
                        var val = parent.parent.row.FailSafeTriggered.toString().toLowerCase()
                        return (val === "true" || val === "triggered") ? "" : "white"
                    }
                }
            }
        }
    }

    component TelemetryItem: Rectangle {
        property string label: ""
        property string value: ""
        property color valueColor: "white"

        color: "transparent"
        implicitHeight: 52

        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            Text {
                text: label
                color: "#b0b0b0"
                font.pixelSize: 12
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: value || "-"
                color: value ? valueColor : "#606060"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
            }
        }
    }

    function populateActiveDroneModel(drone) {
        if (!drone) return;
        activeDrone = drone;

        activeDroneModel.clear();
        activeDroneModel.append({
            name: drone.name,
            status: drone.status,
            battery: drone.battery,
            latitude: drone.latitude,
            longitude: drone.longitude,
            altitude: drone.altitude,
            airspeed: drone.airspeed,
            groundspeed: drone.groundspeed,
            pitch: drone.pitch,
            yaw: drone.yaw,
            climbRate: drone.climbRate,
            satCount: drone.satCount,
            mode: drone.mode,
            flightTime: drone.flightTime,
            Latency: drone.Latency,
            FailSafeTriggered: drone.FailSafeTriggered
        });
    }

    // function setStatusHeight(h) {
    //     statusHeight = h
    // }

    // function setTrackingWidth(w) {
    //     trackingWidth = w
    // }

    MouseArea {
        id: topLeftResizeHandle
        width: resizeHandleSize
        height: resizeHandleSize
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor

        property real startWidth: 0
        property real startHeight: 0
        property real pressX: 0
        property real pressY: 0
        property real maxHAtPress: 0
        property real maxWAtPress: 0
        property bool dragging: false

        onPressed: {
            startWidth = telemMain.width
            startHeight = telemMain.height

            var gap = GcsStyle.PanelStyle.applicationBorderMargin
            maxHAtPress = telemMain.parent.parent.height - statusHeight - (3 * gap)
            maxWAtPress = telemMain.parent.parent.width - trackingWidth - (3 * gap)

            pressX = mouse.x
            pressY = mouse.y
            dragging = true
        }

        onPositionChanged: {
            if (!(mouse.buttons & Qt.LeftButton)) return;

            var dx = mouse.x - pressX;
            var dy = mouse.y - pressY;

            var newW = startWidth - dx;
            var newH = startHeight - dy;

            if (newW < minPanelWidth) newW = minPanelWidth;
            if (newW > maxWAtPress) newW = maxWAtPress;
            if (newH < minPanelHeight) newH = minPanelHeight;
            if (newH > maxHAtPress) newH = maxHAtPress;

            telemMain.width = newW;
            telemMain.height = newH;
        }

        onReleased: {
            mainPanel.height = telemMain.height
            mainPanel.width = telemMain.width
            dragging = false
        }

        Text {
            id: chevron
            text: "≪"
            color: "white"
            font.pixelSize: 16
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 5
            rotation: 45
            visible: true
            opacity: 0.6

            Connections {
                target: topLeftResizeHandle
                onDraggingChanged: {
                    if (topLeftResizeHandle.dragging) {
                        chevron.visible = false
                    } else {
                        chevron.visible = true
                        chevron.opacity = 0.6
                    }
                }
            }
        }
    }
}

