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

        ListModel {
            id: fieldsModel
            ListElement { label: "Longitude";     key: "longitude" }
            ListElement { label: "Latitude";      key: "latitude" }
            ListElement { label: "Altitude";      key: "altitude" }
            ListElement { label: "Airspeed";      key: "airspeed" }
            ListElement { label: "Battery";       key: "battery" }
            ListElement { label: "Pitch";         key: "pitch" }
            ListElement { label: "Yaw";           key: "yaw" }
            ListElement { label: "Groundspeed";   key: "groundspeed" }
            ListElement { label: "Status";        key: "status" }
            ListElement { label: "Flight Time";   key: "flightTime" }
            // default values to fill space
            ListElement { label: "Latency";       key: "Latency" }
            ListElement { label: "FailSafeTriggered"; key: "FailSafeTriggered" }
            ListElement { label: "Climb Rate";    key: "climbRate" }
            ListElement { label: "GPS Sats";      key: "satCount" }
            ListElement { label: "Mode";          key: "mode" }
        }

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
        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 8
            clip: true
            interactive: false
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: flow.implicitHeight

            property int columns: 3
            property int rowSpacing: 6
            property int colSpacing: 10

            // GridLayout
            Item {
                id: content
                width: flick.width
                height: grid.implicitHeight

                property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)

                GridLayout {
                    id: grid
                    anchors.fill: parent
                    columns: flick.columns
                    rowSpacing: flick.rowSpacing
                    columnSpacing: flick.colSpacing

                    Repeater {
                        model: fieldsModel

                        delegate: TelemetryItem {
                            label: model.label

                            value: {
                                const r = content.row
                                if (!r) return ""
                                const k = model.key
                                return (r[k] !== undefined && r[k] !== null && r[k] !== "") ? r[k] : ""
                            }

                            // contexual coloring
                            valueColor: {
                                const k = model.key
                                const v = value ? value.toString() : ""
                                if (k === "battery") {
                                    var n = parseFloat(v.replace('%',''))
                                    if (isNaN(n)) return "white"
                                    if (n < 20) return "red"
                                    if (n < 40) return "yellow"
                                    return "green"
                                }
                                if (k === "FailSafeTriggered") {
                                    const s = v.toLowerCase()
                                    return (s === "true" || s === "triggered" || s === "1") ? "red" : "white"
                                }
                                return "white"
                            }

                            Layout.fillWidth: true
                        }
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
        implicitHeight: 48
        implicitWidth: 120

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 1

            Text {
                text: label
                color: "white"
                font.pixelSize: 16
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: value || "-"
                color: value ? valueColor : "white"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                elide: Text.ElideRight
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
            airspeed: drone.airspeed
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

