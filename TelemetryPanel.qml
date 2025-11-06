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
    property var activeIndex: -1
    property bool isExpanded: false

    property var fieldRows: [
        /*
        This is used to determine which piece of drone data to pull from the DroneClass object.
        (The DroneClass object is stored in the activeDrone var)
        */
        [
            { label: "Climb Rt", unit: "m/s" },
            { label: "Flight Time", unit: "" },
            { label: "SatCount", unit: "" }
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
        spacing: 0

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
                spacing: 0

                property var rowFields: telemetryPanel.fieldRows[index]
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // Left Edge of Panel
                    Rectangle {
                        width: 1
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillHeight: true
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
                                        if (activeIndex === -1) {
                                            if (modelData.label === "Latitude") { activeDrone.latitude.toFixed(3) }
                                            else if (modelData.label === "Longitude") { activeDrone.longitude.toFixed(3) }
                                            else if (modelData.label === "SatCount") { "---" }
                                            else if (modelData.label === "Yaw") { "---" }
                                            else if (modelData.label === "Pitch") { "---" }
                                            else if (modelData.label === "Latency") { "---" }
                                            else if (modelData.label === "Status") { "---" }
                                            else if (modelData.label === "Mode") { "---" }
                                            else if (modelData.label === "Fail Safe") { "---" }
                                            else if (modelData.label === "Altitude") { "---" }
                                            else if (modelData.label === "Climb Rate") { "---" }
                                            else if (modelData.label === "Flight Time") { "---" }
                                            else if (modelData.label === "Distance GCS") { "---" }
                                            else if (modelData.label === "Air Speed") { "---" }
                                            else if (modelData.label === "Gnd Speed") { "---" }
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

    function setActiveDrone(drone, index) {
        if (!drone) return;
        activeDrone = drone
        activeIndex = index

        console.log("activeDrone: ", activeDrone)
        console.log("activeIndex: ", activeIndex)
    }

    function toggleExpanded() {
        isExpanded = !isExpanded
    }
}

