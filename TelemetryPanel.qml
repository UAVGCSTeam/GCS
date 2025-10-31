import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    // This is the container element
    id: statusBar
    height: 45
    width: Math.min(parent.width * 0.5, 400)
    color: "#80000000"
    radius: GcsStyle.PanelStyle.cornerRadius

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 8

    property var activeDrone: null 
    property bool isExpanded: false

    ListModel { id: activeDroneModel }

    ListModel {
        id: topRowFields
        ListElement { label: "Altitude"; key: "altitude"; unit: "m" }
        ListElement { label: "Climb Rate"; key: "climbRate"; unit: "m/s" }
        ListElement { label: "Flight Time"; key: "flightTime"; unit: "" }
    }

    ListModel {
        id: bottomRowFields
        ListElement { label: "Distance From GCS"; key: "distanceFromGCS"; unit: "m" }
        ListElement { label: "Air Speed"; key: "airspeed"; unit: "m/s" }
        ListElement { label: "Ground Speed"; key: "groundspeed"; unit: "m/s" }
    }

    ListModel {
        id: expandedFields
        ListElement { label: "Latitude"; key: "latitude"; unit: "" }
        ListElement { label: "Longitude"; key: "longitude"; unit: "" }
        ListElement { label: "SatCount"; key: "satCount"; unit: "" }
        
        ListElement { label: "Yaw"; key: "yaw"; unit: "°" }
        ListElement { label: "Pitch"; key: "pitch"; unit: "°" }
        ListElement { label: "Latency"; key: "latency"; unit: "" }
        
        ListElement { label: "Status"; key: "status"; unit: "" }
        ListElement { label: "Mode"; key: "mode"; unit: "" }
        ListElement { label: "Fail Safe"; key: "FailSafe"; unit: "" }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            isExpanded = !isExpanded
        }
        cursorShape: Qt.PointingHandCursor
    }

    // Expanded Panel
    Rectangle {
        // Expanded panel that appears above status bar
        id: expandedPanel
        color: "#80000000"
        radius: GcsStyle.PanelStyle.cornerRadius
        width: parent.width
        height: 80
        visible: isExpanded
        anchors.bottom: parent.top
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        
        border.color: GcsStyle.panelStyle.defaultBorderColor

        Item {
            anchors.fill: parent
            anchors.margins: 8
            anchors.bottomMargin: 0

            property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)

            GridLayout {
                anchors.fill: parent
                columns: 3
                rowSpacing: 12
                columnSpacing: 15

                Repeater {
                    model: expandedFields

                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: label
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
                        }

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
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)

        // Top Row
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
                        spacing: 4

                        Text {
                            text: label
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

                        // add unit
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
                            text: label
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

                        // add unit
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

    // Rectangle {
    //     id: statusBars
    //     width: parent.width
    //     height: parent.height
    //     color: black
    //     radius: GcsStyle.PanelStyle.cornerRadius
    //     visible: true
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: parent.bottomMargin

    //     Item {
    //         anchors.fill: parent
    //         anchors.margins: 15
    //         anchors.bottomMargin: 64

    //         property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)

    //         GridLayout {
    //             anchors.fill: parent
    //             columns: 2
    //             rowSpacing: 12
    //             columnSpacing: 15

    //             Repeater {
    //                 model: statusBarFields

    //                 delegate: TelemetryItem {
    //                     label: model.label
    //                     value: {
    //                         var droneRow = parent.parent.row
    //                         return (droneRow && droneRow[key] !== undefined) ? droneRow[key] : ""
    //                     }
    //                     valueColor: {
    //                         return "white"
    //                     }
    //                     Layout.fillWidth: true
    //                 }
    //             }
    //         }
    //     }
    // }

    component TelemetryItem: Rectangle {
        property string label: ""
        property string value: "#b0b0b0"
        property color valueColor: "white"

        color: transparent
        implicitHeight: 52

        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            Text {
                text: label
                color: "white"
                font.pixelSize: 18
                font.weight: Font.Normal
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: value || "---"
                color: value ? valueColor : "white"
                font.pixelSize: 24
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
            }
        }
    }

    function populateActiveDroneModel(drone) {
        if (!drone) return;
        activeDrone = drone;

        activeDroneModel.clear();
        activeDroneModel.append({
            // Position & Navigation
            altitude: drone.altitude,
            latitude: drone.latitude,
            longitude: drone.longitude,
            distanceFromGCS: drone.distanceFromGCS,

            // Speed & Movement
            airspeed: drone.airspeed,
            groundspeed: drone.groundSpeed,
            climbRate: drone.climbRate,

            // Orientation
            pitch: drone.pitch,
            yaw: drone.yaw,

            // System Settings
            flightTime: drone.flightTime,
            satCount: drone.satCount,
            latency: drone.latency,
            status: drone.status,
            mode: drone.mode,
            failSafe: drone.failSafe
        });
    }

    function toggleExpanded() {
        isExpanded = !isExpanded
    }
}

