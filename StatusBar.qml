import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

// small status bar centered at the bottom of the GCS that shows
// the most important telemetry data
// eg. climbing speed, air speed, flight time, altitude, distance from GCS

Rectangle {
    id: mainPanel
    height: 60
    width: Math.min(parent.width * 0.5, 600)
    color: "black"
    radius: 4

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 8

    property var activeDrone: null

    ListModel { id: activeDroneModel }

    ListModel {
        id: topRowFields

        // Uncomment or add the fields you want to display:
        ListElement { icon: "↑"; key: "altitude"; unit: "m" }
        ListElement { icon: "↕"; key: "climbRate"; unit: "m/s" }
        ListElement { icon: "⏱"; key: "flightTime"; unit: "" }
        // ListElement { icon: "↔"; key: "distanceFromGCS"; unit: "m" }
        // ListElement { icon: "→"; key: "airspeed"; unit: "m/s" }
        // ListElement { icon: "✈"; key: "relativeAltitude"; unit: "m" }

        // ListElement { icon: "⚡"; key: "battery"; unit: "%" }
        // ListElement { icon: "🧭"; key: "heading"; unit: "°" }
        // ListElement { icon: "📡"; key: "satCount"; unit: "" }
        // ListElement { icon: "⚠"; key: "status"; unit: "" }
        // ListElement { icon: "🎯"; key: "groundspeed"; unit: "m/s" }
        // ListElement { icon: "📍"; key: "latitude"; unit: "" }
        // ListElement { icon: "📍"; key: "longitude"; unit: "" }
        // ListElement { icon: "↻"; key: "yaw"; unit: "°" }
        // ListElement { icon: "↗"; key: "pitch"; unit: "°" }
        // ListElement { icon: "🔧"; key: "mode"; unit: "" }
    }

    ListModel {
        id: bottomRowFields
        // Uncomment or add the fields you want to display:
        // ListElement { icon: "↑"; key: "altitude"; unit: "m" }
        // ListElement { icon: "↕"; key: "climbRate"; unit: "m/s" }
        // ListElement { icon: "⏱"; key: "flightTime"; unit: "" }
        ListElement { icon: "↔"; key: "distanceFromGCS"; unit: "m" }
        ListElement { icon: "→"; key: "airspeed"; unit: "m/s" }
        ListElement { icon: "✈"; key: "relativeAltitude"; unit: "m" }

        // ListElement { icon: "⚡"; key: "battery"; unit: "%" }
        // ListElement { icon: "🧭"; key: "heading"; unit: "°" }
        // ListElement { icon: "📡"; key: "satCount"; unit: "" }
        // ListElement { icon: "⚠"; key: "status"; unit: "" }
        // ListElement { icon: "🎯"; key: "groundspeed"; unit: "m/s" }
        // ListElement { icon: "📍"; key: "latitude"; unit: "" }
        // ListElement { icon: "📍"; key: "longitude"; unit: "" }
        // ListElement { icon: "↻"; key: "yaw"; unit: "°" }
        // ListElement { icon: "↗"; key: "pitch"; unit: "°" }
        // ListElement { icon: "🔧"; key: "mode"; unit: "" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)

        // Top row
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Repeater {
                model: topRowFields

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: icon
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            property var droneRow: parent.parent.parent.parent.parent.row
                            text: (droneRow && droneRow[key] !== undefined) ? droneRow[key] : "---"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Text {
                            text: unit
                            color: "#b0b0b0"
                            font.pixelSize: 14
                            visible: unit !== ""
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 6
                        anchors.bottomMargin: 6
                        color: "#404040"
                        visible: index < displayFields.count - 1
                    }
                }
            }
        }

        // Horizontal Divider between two rows
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#404040"
            Layout.leftMargin: 10
            Layout.rightMargin: 10
        }

        // Bottom Row
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Repeater {
                model: bottomRowFields

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: icon
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            property var droneRow: parent.parent.parent.parent.row
                            text: (droneRow && droneRow[key] !== undefined) ? droneRow[key] : "---"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Text {
                            text: unit
                            color: "#b0b0b0"
                            font.pixelSize: 14
                            visible: unit !== ""
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 6
                        anchors.bottomMargin: 6
                        color: "#404040"
                        visible: index < displayFields.count - 1
                    }
                }
            }
        }
    }

    function populateActiveDroneModel(drone) {
        if (!drone) return;
        activeDrone = drone;

        activeDroneModel.clear()
        activeDroneModel.append({
            // Position & Navigation
            altitude: drone.altitude,
            relativeAltitude: drone.relativeAltitude,
            latitude: drone.latitude,
            longitude: drone.longitude,
            distanceFromGCS: drone.distanceFromGCS,
            heading: drone.heading,

            // Speed & Movement
            airspeed: drone.airspeed,
            groundspeed: drone.groundspeed,
            climbRate: drone.climbRate,

            // Orientation
            pitch: drone.pitch,
            yaw: drone.yaw,

            // System Status
            battery: drone.battery,
            flightTime: drone.flightTime,
            satCount: drone.satCount,
            status: drone.status,
            mode: drone.mode
        })
    }
}
