import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle


Rectangle {
    id: mainPanel
    width: 300
    height: 600
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius


    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Right view
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                height: GcsStyle.PanelStyle.headerHeight
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height / 2
                    color: parent.color
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 0

                    Text {
                        text: "Drone Status"
                        font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                    }
                }
            }

            ListModel {
                id: activeDroneModel
            }

            ListView {
                id: droneListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: true
                model: activeDroneModel

                delegate: Rectangle {
                    width: parent.width
                    height: GcsStyle.PanelStyle.listItemHeight

                    ColumnLayout {
                        anchors.fill: parent
                        Layout.fillWidth: true
                        anchors.margins: 20
                        spacing: 20

                        Text {
                            text: name
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: status
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: battery + "%"
                            color: battery > 70 ? GcsStyle.PanelStyle.batteryHighColor :
                                                  battery > 30 ? GcsStyle.PanelStyle.batteryMediumColor :
                                                                 GcsStyle.PanelStyle.batteryLowColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: "Lattitude: " + lattitude
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: "Longitude: " + longitude
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: "Altitude: " + altitude
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: "Airspeed: " + airspeed
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                    }
                }
            }
            // Emergency Buttons (currently have no actual function on click)
            Button {
                text: "Emergency Shutdown"
                Layout.fillWidth: true
                Layout.margins: GcsStyle.PanelStyle.defaultMargin
                onClicked: {
                }
            }
            Button {
                text: "Emergency Land"
                Layout.fillWidth: true
                Layout.margins: GcsStyle.PanelStyle.defaultMargin
                onClicked: {
                }
            }
        }
    }

    Connections {
        target: droneTrackingPanel
        onUpdateSelectedDroneSignal: populateActiveDroneModel(name, status, battery, lattitude, longitude, altitude, airspeed)
    }

    // In this future this would be updated by a pointer: (drone1 -> activeDrone)
    function populateActiveDroneModel(name, status, battery, lattitude, longitude, altitude, airspeed) {
        if (activeDroneModel.count > 0 && activeDroneModel.get(0).name === name) {
            // If the same drone is clicked again, toggle visibility
            mainPanel.visible = !mainPanel.visible;
        } else {
            // Update model and ensure the panel is visible
            activeDroneModel.clear();
            activeDroneModel.append({name: name,
                                        status: status,
                                        battery: battery,
                                        lattitude: lattitude,
                                        longitude: longitude,
                                        altitude: altitude,
                                        airspeed: airspeed            });
            mainPanel.visible = true;
        }
    }
}
