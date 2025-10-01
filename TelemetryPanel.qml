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

    GridLayout {
        columns: 5
        anchors.centerIn: parent
        rowSpacing: 10
        columnSpacing: 10

        ListModel {
            id: activeDroneModel
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false // to make the list static
                //clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Longitude"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: longitude
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"

                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Latitude"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: latitude
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Altitude"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: altitude
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Airspeed"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: airspeed
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Battery"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: battery
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Pitch"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: pitch
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Yaw"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: yaw
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Groundspeed"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: groundspeed
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Status"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: status
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }
        Rectangle {
            width: 120
            height: 120
            color: "transparent"

            ListView {
                anchors.fill: parent
                interactive: false
                clip: true
                model: activeDroneModel

                delegate: Item {
                    width: ListView.view.width
                    height: ListView.view.height

                    Text {
                        text: "Flight Time"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 14
                    }

                    Text {
                        text: flightTime
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }
    }

    Connections {
        target: droneTrackingPanel
        onUpdateSelectedDroneSignal: populateActiveDroneModel(name, status, battery, latitude, longitude, altitude, airspeed)
        onDroneClicked: populateActiveDroneModel(drone)
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

    property int minPanelWidth: 320
    property int minPanelHeight: 200
    property int resizeHandleSize: 20

    MouseArea {
        id: topLeftResizeHandle
        width: resizeHandleSize
        height: resizeHandleSize
        anchors.left: parent.left
        anchors.top: parent.top
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        property real startWidth: 0
        property real startHeight: 0
        property real pressX: 0
        property real pressY: 0

        onPressed: {
            startWidth = mainPanel.width
            startHeight = mainPanel.height
            pressX = mouse.x
            pressY = mouse.y
        }

        onPositionChanged: {
            if (!(mouse.buttons & Qt.LeftButton)) return;

            var dx = mouse.x - pressX;
            var dy = mouse.y - pressY;

            var newW = startWidth  - dx;
            var newH = startHeight - dy;

            if (newW < minPanelWidth)  {
                newW = minPanelWidth;
            }
            if (newH < minPanelHeight){
                newH = minPanelHeight;
            }
            mainPanel.width  = newW;
            mainPanel.height = newH;
        }
    }
}


