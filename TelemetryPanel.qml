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

    property color borderColor: "#404040"
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
            { label: "Roll", unit: "°" }
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

    function setAttitudeWidth(w) {
        attitudeWidth = w
    }

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
            color: borderColor
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

                    Item {
                        // Using an Item so that we can use the anchor 
                        // system on the Rectangle. This also matches the vertical
                        // bars on the right side 
                        Layout.fillHeight: true
                        width: 1
                        Rectangle {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: -4
                            anchors.bottomMargin: -4
                            width: 1
                            color: borderColor
                        }
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
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: {
                                        if (activeDrone) {
                                            if (modelData.label === "Latitude") { activeDrone.latitude.toFixed(3) }
                                            else if (modelData.label === "Longitude") { activeDrone.longitude.toFixed(3) }
                                            // else if (modelData.label === "SYS ID") { activeDrone.sysID }
                                            // else if (modelData.label === "COMP ID") { activeDrone.compID }
                                            else if (modelData.label === "Flight Time") { "---" }
                                            else if (modelData.label === "Yaw") { activeDrone.orientation.z.toFixed(3) }
                                            else if (modelData.label === "Pitch") { activeDrone.orientation.y.toFixed(3) }
                                            else if (modelData.label === "Roll") {  activeDrone.orientation.x.toFixed(3) }
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
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                    font.bold: true
                                }
                                
                                Text {
                                    text: modelData.unit || ""
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
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
                                color: borderColor
                            }
                        }
                    }
                }

                // Divider between rows
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: borderColor
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
