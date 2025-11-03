import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    // This is the container element
    id: statusBar
    height: isExpanded ? 225 : 90
    width: Math.min(parent.width * 0.5, 400)
    color: "#80000000"
    radius: GcsStyle.PanelStyle.cornerRadius

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 8

    property var activeDrone: null 
    property var row: (activeDroneModel.count > 0 ? activeDroneModel.get(0) : null)
    property bool isExpanded: false

    ListModel { id: activeDroneModel }

    property var fieldRows: [
        [
            { label: "Latitude",    key: "latitude",    unit: "" },
            { label: "Longitude",   key: "longitude",   unit: "" },
            { label: "SatCount",    key: "satCount",    unit: "" }
        ],
        [
            { label: "Yaw", key: "yaw", unit: "°" },
            { label: "Pitch", key: "pitch", unit: "°" },
            { label: "Latency", key: "latency", unit: "ms" }
        ],
        [
            { label: "Status", key: "status", unit: "" },
            { label: "Mode", key: "mode", unit: "" },
            { label: "Fail Safe", key: "failSafe", unit: "" }
        ],
        [
            { label: "Altitude", key: "altitude", unit: "m" },
            { label: "Climb Rate", key: "climbRate", unit: "m/s" },
            { label: "Flight Time", key: "flightTime", unit: "" }
        ],
        [
            { label: "Distance From GCS", key: "distanceFromGCS", unit: "m" },
            { label: "Air Speed", key: "airspeed", unit: "m/s" },
            { label: "Ground Speed", key: "groundspeed", unit: "m/s" }
        ]
    ]

    Component.onCompleted: {
        rowsModel.append({ fields: row1Fields })
        rowsModel.append({ fields: row2Fields })
        rowsModel.append({ fields: row3Fields })
        rowsModel.append({ fields: row4Fields })
        rowsModel.append({ fields: row5Fields })
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            isExpanded = !isExpanded
        }
        cursorShape: Qt.PointingHandCursor
    }

    // Repeater for each row
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Bar at top of panel
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#404040"
        }

        Repeater {
            model: statusBar.fieldRows.length

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: index > 2 || isExpanded // permanently leave last 2 rows visible
                spacing: 4

                property var rowFields: statusBar.fieldRows[index]
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // Repeater for each field in row
                    Repeater {
                        model: rowFields

                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: modelData.label
                                    color: "white"
                                    font.pixelSize: 10
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: (statusBar.row && statusBar.row[modelData.key] !== undefined) 
                                        ? statusBar.row[modelData.key] : "---"
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                
                                Text {
                                    text: modelData.unit || ""
                                    color: "white"
                                    font.pixelSize: 14
                                    visible: !!modelData.unit
                                }
                            }

                            // Separator between columns
                            Rectangle {
                                width: 1
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.topMargin: 6
                                anchors.bottomMargin: 6
                                color: "#404040"
                                visible: index < fields.length - 1
                            }
                        }
                    }
                }

                // Divider between rows
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    height: 1
                    color: "#404040"
                    visible: index < rowsModel.count - 1 && (index < 1 || isExpanded)
                }
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

