import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: mainPanel
    height: 600
    width: 260
    color: "red"
    visible: false
    // anchors.right: parent.right
    // anchors.bottom: parent.bottom
    clip: false

    Rectangle {
        id: telemeMain
        color: "#80000000"
        radius: GcsStyle.PanelStyle.cornerRadius
        width: 600
        height: 400
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
            ListElement { label: "FailSafeTriggered";          key: "FailSafeTriggered" }
            ListElement { label: "Climb Rate";    key: "climbRate" }
            ListElement { label: "GPS Sats";      key: "satCount" }
            ListElement { label: "Mode";          key: "mode" }
        }


        GridView {
            id: grid
            anchors.fill: parent
            anchors.margins: 10
            model: fieldsModel
            cellWidth: 120
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

                // if our model has more than 0 entries place in row otherwise dont
                property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)
                // show an emptry string if do not have row[key] in our fieldsmodel
                property var value: (row && row[key] !== undefined) ? row[key] : ""

                Text { // telemetry
                    text: label
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    font.pixelSize: 18
                    wrapMode: Text.WordWrap
                }

                Text { // value of the telemetry
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

    Connections {
        target: droneTrackingPanel
        onUpdateSelectedDroneSignal: populateActiveDroneModel(name, status, battery, latitude, longitude, altitude, airspeed)
        onDroneClicked: populateActiveDroneModel(drone)
    }

    property var activeDrone: null

    function populateActiveDroneModel(drone) {
        if (!drone) return;
        activeDrone = drone; // store reference to currently active drone

        // Update model (same as before)
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

    property int minPanelWidth: 320
    property int minPanelHeight: 200
    property int resizeHandleSize: 20
    property int statusHeight: 0

    function setStatusHeight(h) {
        statusHeight = h
    }

    MouseArea {
        id: topLeftResizeHandle
        width: resizeHandleSize
        height: resizeHandleSize
        anchors.left: telemeMain.left
        anchors.top: telemeMain.top
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor

        property real startWidth: 0
        property real startHeight: 0
        property real pressX: 0
        property real pressY: 0
        property real maxHAtPress: 0

        onPressed: {
            startWidth = telemeMain.width
            startHeight = telemeMain.height

            var gap = 12
            var bottomMargin = telemeMain.anchors.bottomMargin || 0
            maxHAtPress = telemeMain.parent.height - statusHeight - gap - bottomMargin
            // if (maxHAtPress < minPanelHeight)
            //     maxHAtPress = minPanelHeight

            pressX = mouse.x
            pressY = mouse.y
        }

        onPositionChanged: {
            if (!(mouse.buttons & Qt.LeftButton)) return;

            var dx = mouse.x - pressX;
            var dy = mouse.y - pressY;

            var newW = startWidth  - dx;
            var newH = startHeight - dy;

            if (newW < minPanelWidth)
                newW = minPanelWidth;

            if (newH < minPanelHeight)
                newH = minPanelHeight;

            // if (newH > maxHAtPress) // what the flip. idk how this makes sense
            //     newH = maxHAtPress;

            telemeMain.width  = newW;
            telemeMain.height = newH;
        }

        onReleased: {
            mainPanel.height = telemeMain.height
            mainPanel.width = telemeMain.width
            // anchors.left = telemeMain.left
            // anchors.top = telemeMain.top
        }
    }
}
