import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    // This is the container element
    id: telemetryPanel
    height: isExpanded ? 166 : 88
    width: Math.min(parent.width * 0.5, 650)
    color: GcsStyle.PanelStyle.telemetryPanelBackgroundColor
    radius: GcsStyle.PanelStyle.cornerRadius

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 8

    property color borderColor: GcsStyle.PanelStyle.telemetryPanelBorderColor
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
            { label: "Mode", unit: "" },
            { label: "Fail Safe", unit: "" }
        ],
        [
            { label: "Yaw", unit: "°" },
            { label: "Pitch", unit: "°" },
            { label: "Roll", unit: "°" },
            { label: "N/A", unit: "N/A" },
        ],
        [
            { label: "Latitude", unit: "" },
            { label: "Longitude", unit: "" },
            { label: "Altitude", unit: "m" },
            { label: "Flight Time", unit: "" }
        ],
        [
            { label: "Dist GCS", unit: "m" },
            { label: "Air Speed", unit: "m/s" },
            { label: "Gnd Speed", unit: "m/s" },
            { label: "Status", unit: "" }
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

        // Repeater for each row
        Repeater {
            model: telemetryPanel.fieldRows.length

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: isExpanded || index >= (telemetryPanel.fieldRows.length - 2) // dynamically show last 2 rows when collapsed
                spacing: 4

                property var rowFields: telemetryPanel.fieldRows[index]
                
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
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: {
                                        if (activeDrone) {
                                            if (modelData.label === "Latitude") { activeDrone.latitude.toFixed(3) }
                                            else if (modelData.label === "Longitude") { activeDrone.longitude.toFixed(3) }
                                            // sysID and compID are no longer implemented. might be implemented in the future
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
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                    font.bold: true
                                }
                                
                                Text {
                                    text: modelData.unit || ""
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                    visible: !!modelData.unit
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    onActiveDroneChanged: {
        if (activeDrone === null) {
            telemetryPanel.visible = false;
        } else {
            telemetryPanel.visible = true;
        }
    }

    function toggleExpanded() {
        isExpanded = !isExpanded
    }
}
