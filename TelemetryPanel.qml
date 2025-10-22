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
    height: 140
    width: 340
    color: "transparent"
    visible: false
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    property var activeDrone: null // updated by the updateSelectedDroneModel function
    property int minPanelWidth: 380
    property int minPanelHeight: 140
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

        // invisible wheel-blocker to prevent map scrolling when over the telemetry panel
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: false
            onWheel: wheel.accepted = true
            z: 0
        }

        // double-tap handler for expand/shrink
        Item {
            anchors.fill: parent
            z: 999

            TapHandler {
                acceptedDevices: PointerDevice.Mouse
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

        GridView {
            id: grid
            anchors.fill: parent
            anchors.margins: 10
            model: fieldsModel

            property int horizontalSpacing: 20
            property int verticalSpacing: 20
            property int minCellWidth: 160
            property int columns: 1

            onWidthChanged: {
                const availableWidth = width - anchors.margins * 2
                const newColumns = Math.max(1, Math.floor((availableWidth + horizontalSpacing) / (minCellWidth + horizontalSpacing)))
                if (newColumns !== columns)
                    columns = newColumns
            }
            cellWidth: {
                const availableWidth = width - anchors.margins * 2
                const totalSpacing = (columns - 1) * horizontalSpacing
                return (availableWidth - totalSpacing) / columns
            }

            cellHeight: 120
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            highlightFollowsCurrentItem: false
            clip: true

            // vertical scrollbar
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                interactive: true

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Rectangle {
                    implicitWidth: 8
                    radius: width
                    color: "#CCCCCC"
                }
            }

            delegate: Rectangle {
                width: grid.cellWidth
                height: grid.cellHeight
                color: "transparent"
                clip: true // clip overflowed text

                property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)
                property var value: (row && row[key] !== undefined) ? row[key] : ""

                Text { // telemetry
                    text: label
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    font.pixelSize: 18
                    wrapMode: Text.WordWrap
                }

                Text { // value
                    text: value
                    width: parent.width - 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24
                    font.bold: true
                    color: "white"
                }
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

    function setStatusHeight(h) {
        statusHeight = h
    }

    function setTrackingWidth(w) {
        trackingWidth = w
    }

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

            if (newW < minPanelWidth)
                newW = minPanelWidth;
            if (newW > maxWAtPress)
                newW = maxWAtPress;
            if (newH < minPanelHeight)
                newH = minPanelHeight;
            if (newH > maxHAtPress)
                newH = maxHAtPress;

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
