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
                            text: "Latitude: " + latitude
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
        }
    }


    property var activeDrone: null
    
    function populateActiveDroneModel(drone) {
        if (!drone) return;

        activeDrone = drone; // store reference to currently active drone

        // Update model
        activeDroneModel.clear();
        activeDroneModel.append({name: drone.name,
                                    status: drone.status,
                                    battery: drone.battery,
                                    latitude: drone.latitude,
                                    longitude: drone.longitude,
                                    altitude: drone.altitude,
                                    airspeed: drone.airspeed            });
    }
}

