import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    // This is the container element
    id: telemetryPanel
    height: isExpanded ? 199 : 90  // 2.21 : 1
    width: Math.min(parent.width * 0.5, 400)
    color: "#80000000"
    radius: GcsStyle.PanelStyle.cornerRadius

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 8

    property var activeDrone: null 
    property bool isExpanded: false

    property var fieldRows: [
        /*
        This is used to determine which piece of drone data to pull from the DroneClass object.
        (The DroneClass object is stored in the activeDrone var)
        */
        [
            { label: "SYS ID", unit: "" },
            { label: "COMP ID", unit: "" },
            { label: "Flight Time", unit: "" },
        ],
        [
            { label: "Yaw", unit: "°" },
            { label: "Pitch", unit: "°" },
            { label: "Latency", unit: "ms" }
        ],
        [
            { label: "Status", unit: "" },
            { label: "Mode", unit: "" },
            { label: "Fail Safe", unit: "" }
        ],
        [
            { label: "Latitude", unit: "" },
            { label: "Longitude", unit: "" },
            { label: "Altitude", unit: "m" }
        ],
        [
            { label: "Dist GCS", unit: "m" },
            { label: "Air Speed", unit: "m/s" },
            { label: "Gnd Speed", unit: "m/s" }
        ]
    ]

    MouseArea {
        anchors.fill: parent
        onClicked: {
            isExpanded = !isExpanded
        }
        cursorShape: Qt.PointingHandCursor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Top edge of panel
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#404040"
        }

        // Repeater for each row
        Repeater {
            model: telemetryPanel.fieldRows.length

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: index > 2 || isExpanded // permanently leave last 2 rows visible
                spacing: 4

                property var rowFields: telemetryPanel.fieldRows[index]
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // Left Edge of Panel
                    Rectangle {
                        width: 1
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: -4
                        anchors.bottomMargin: -4
                        color: "#404040"
                    }

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
                                    text: {
                                        if (activeDrone) {
                                            if (modelData.label === "Latitude") { activeDrone.latitude.toFixed(3) }
                                            else if (modelData.label === "Longitude") { activeDrone.longitude.toFixed(3) }
                                            else if (modelData.label === "SYS ID") { activeDrone.sysID }
                                            else if (modelData.label === "COMP ID") { activeDrone.compID }
                                            else if (modelData.label === "Flight Time") { "---" }
                                            else if (modelData.label === "Yaw") { "---" }
                                            else if (modelData.label === "Pitch") { "---" }
                                            else if (modelData.label === "Latency") { "---" }
                                            else if (modelData.label === "Fail Safe") { "---" }
                                            else if (modelData.label === "Status") { "---" }
                                            else if (modelData.label === "Mode") { "---" }
                                            else if (modelData.label === "Altitude") { activeDrone.altitude }
                                            else if (modelData.label === "Dist GCS") { "---" }
                                            else if (modelData.label === "Air Speed") { "---" }
                                            else if (modelData.label === "Gnd Speed") { "---" }
                                            else { "---" }
                                        } else { "---" }
                                    }
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
                                anchors.topMargin: -4
                                anchors.bottomMargin: -4
                                color: "#404040"
                            }
                        }
                    }
                }

                // Divider between rows
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#404040"
                }
            }
        }
    }

    function setActiveDrone(drone) {
        if (!drone) return;
        activeDrone = drone;
    }

    function clearActiveDrone() {
        activeDrone = null;
    }

    function toggleExpanded() {
        isExpanded = !isExpanded
    }
}

