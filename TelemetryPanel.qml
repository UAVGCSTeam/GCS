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

    property var activeDrone: null 
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
        border.width: GcsStyle.panelStyle.defaultBorderWidth
        border.color: GcsStyle.panelStyle.defaultBorderColor

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
        }



        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: flow.implicitHeight

            property int horizontalSpacing: 20
            property int verticalSpacing: 20
            property int minCellWidth: 160
            property int cellHeight: 120
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
            Rectangle {
                id: flickContent
                width: flick.width
                height: flow.implicitHeight
                color: "transparent"

                Flow {
                    id: flow
                    width: flickContent.width - flick.anchors.margins * 2
                    spacing: flick.horizontalSpacing
                    flow: Flow.LeftToRight
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 0
                    padding: 0

                    Repeater {
                        model: fieldsModel

                        delegate: Rectangle {
                            property int columns: Math.max(1, Math.floor((flow.width + flow.spacing) / (flick.minCellWidth + flow.spacing)))

                            width: {
                                const totalSpacing = (columns - 1) * flow.spacing
                                const availableWidth = flow.width - totalSpacing
                                return availableWidth / columns
                            }

                            height: flick.cellHeight
                            color: "transparent"
                            clip: true

                            property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)
                            property var value: (row && row[key] !== undefined) ? row[key] : ""

                            Text { // telemetry label
                                text: label
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "white"
                                font.pixelSize: 18
                                wrapMode: Text.WordWrap
                            }

                            Text { // telemetry value
                                text: value
                                anchors.centerIn: parent
                                width: parent.width - 12
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                font.pixelSize: 24
                                font.bold: true
                                color: "white"
                            }
                        }
                    }
                }
            }

            // vertical scrollbar for flickable container
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                interactive: true
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Rectangle {
                    implicitWidth: 8
                    radius: width
                    color: "#CCCCCC"
                }
            }
        }
    }

    Connections {
        target: droneController
        onDroneStateChanged: function(drone) {
            // console.log("[The drone Obj: ]", drone)
            // console.log("[The drone name: ]", drone.name)
            populateActiveDroneModel(drone)
        }
    }


    function populateActiveDroneModel(drone) {
        if (!drone) return;
        activeDrone = drone;

        activeDroneModel.clear();
        activeDroneModel.append({
            name: drone.name ? drone.name : "",
            status: drone.status ? drone.status : "",
            battery: drone.battery ? drone.battery : "",
            latitude: drone.latitude ? drone.latitude : "",
            longitude: drone.longitude ? drone.longitude : "",
            altitude: drone.altitude ? drone.altitude : "",
            airspeed: drone.airspeed ? drone.airspeed : ""
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

        onPressed: function(mouse) {
            startWidth = telemMain.width
            startHeight = telemMain.height

            var gap = GcsStyle.PanelStyle.applicationBorderMargin
            maxHAtPress = telemMain.parent.parent.height - statusHeight - (3 * gap)
            maxWAtPress = telemMain.parent.parent.width - trackingWidth - (3 * gap)

            pressX = mouse.x
            pressY = mouse.y
            dragging = true
        }

        onPositionChanged: function(mouse) {
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
                function onDraggingChanged() {
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

