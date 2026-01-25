import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    // This is the container element
    id: telemetryPanel
    height: isExpanded ? 166 : 88
    width: Math.min(parent.width * 0.5, 650)
    color: GcsStyle.PanelStyle.primaryColor
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
            { label: "MODE", unit: "" },
            { label: "FAIL SAFE", unit: "" }
        ],
        [
            { label: "YAW", unit: "°" },
            { label: "PITCH", unit: "°" },
            { label: "ROLL", unit: "°" },
            { label: "N/A", unit: "N/A" },
        ],
        [
            { label: "LAT", unit: "" },
            { label: "LON", unit: "" },
            { label: "ALT", unit: "m" },
            { label: "FLT TIME", unit: "" }
        ],
        [
            { label: "DIST GCS", unit: "m" },
            { label: "AIR SPD", unit: "m/s" },
            { label: "GND SPD", unit: "m/s" },
            { label: "STAT", unit: "" }
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
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: {
                                        if (activeDrone) {
                                            if (modelData.label === "LAT") { activeDrone.latitude.toFixed(3) }
                                            else if (modelData.label === "LON") { activeDrone.longitude.toFixed(3) }
                                            // sysID and compID are no longer implemented. might be implemented in the future
                                            // else if (modelData.label === "SYS ID") { activeDrone.sysID }
                                            // else if (modelData.label === "COMP ID") { activeDrone.compID }
                                            else if (modelData.label === "FLT TIME") { "---" }
                                            else if (modelData.label === "YAW") { activeDrone.orientation.z.toFixed(3) }
                                            else if (modelData.label === "PITCH") { activeDrone.orientation.y.toFixed(3) }
                                            else if (modelData.label === "ROLL") {  activeDrone.orientation.x.toFixed(3) }
                                            else if (modelData.label === "FAIL SAFE") { "---" }
                                            else if (modelData.label === "STAT") { "---" }
                                            else if (modelData.label === "MODE") { "---" }
                                            else if (modelData.label === "ALT") { activeDrone.altitude }
                                            else if (modelData.label === "DIST GCS") { "---" }
                                            else if (modelData.label === "AIR SPD") { "---" }
                                            else if (modelData.label === "GND SPD") { "---" }
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
