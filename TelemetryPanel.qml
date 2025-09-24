import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: mainPanel
    color: "#80000000"
    radius: GcsStyle.PanelStyle.cornerRadius
    width: 600
    height: 260

    ListModel {
        id: activeDroneModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: GcsStyle.PanelStyle.defaultMargin
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: GcsStyle.PanelStyle.cornerRadius
            clip: true
            color: "transparent"

            ListView {
                id: droneListViewTop
                anchors.fill: parent
                clip: true
                model: activeDroneModel

                delegate: RowLayout {
                    width: ListView.view.width
                    height: 40
                    spacing: 10

                    Text {
                        text: "Longitude: " + longitude
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Latitude: " + latitude
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Altitude: " + altitude
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Airspeed: " + airspeed
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Battery: " + battery
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: GcsStyle.PanelStyle.cornerRadius
            clip: true
            color: "transparent"

            ListView {
                id: droneListViewBottom
                anchors.fill: parent
                clip: true
                model: activeDroneModel

                delegate: RowLayout {
                    width: ListView.view.width
                    height: 40
                    spacing: 10

                    Text {
                        text: "Pitch: "
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Yaw: "
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Groundspeed: "
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Status: " + status
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                    Text {
                        text: "Flight Time: "
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    }
                }
            }
        }
    }

    Connections {
        target: droneTrackingPanel
        onUpdateSelectedDroneSignal: populateActiveDroneModel(name, status, battery, latitude, longitude, altitude, airspeed)
    }

    function populateActiveDroneModel(name, status, battery, latitude, longitude, altitude, airspeed) {
        if (activeDroneModel.count > 0 && activeDroneModel.get(0).name === name) {
            mainPanel.visible = !mainPanel.visible;
        } else {
            activeDroneModel.clear();
            activeDroneModel.append({
                name: name,
                status: status,
                battery: battery,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                airspeed: airspeed
            });
            mainPanel.visible = true;
        }
    }
}
