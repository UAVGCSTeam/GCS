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
                        text: "1800000000000" // to see if it overflows
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
}





// Rectangle {
//     id: mainPanel
//     color: "#80000000"
//     radius: GcsStyle.PanelStyle.cornerRadius
//     width: 600
//     height: 260



//     ColumnLayout {
//         anchors.fill: parent
//         anchors.margins: GcsStyle.PanelStyle.defaultMargin
//         spacing: 12

//         Rectangle {
//             Layout.fillWidth: true
//             Layout.fillHeight: true
//             radius: GcsStyle.PanelStyle.cornerRadius
//             clip: true
//             color: "transparent"

//             ListView {
//                 id: droneListViewTop
//                 anchors.fill: parent
//                 clip: true
//                 model: activeDroneModel

//                 delegate: RowLayout {
//                     width: ListView.view.width
//                     height: 40
//                     spacing: 10

//                     Text {
//                         text: "Longitude: " + longitude
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Latitude: " + latitude
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Altitude: " + altitude
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Airspeed: " + airspeed
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Battery: " + battery
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                 }
//             }
//         }

//         Rectangle {
//             Layout.fillWidth: true
//             Layout.fillHeight: true
//             radius: GcsStyle.PanelStyle.cornerRadius
//             clip: true
//             color: "transparent"

//             ListView {
//                 id: droneListViewBottom
//                 anchors.fill: parent
//                 clip: true
//                 model: activeDroneModel

//                 delegate: RowLayout {
//                     width: ListView.view.width
//                     height: 40
//                     spacing: 10

//                     Text {
//                         text: "Pitch: "
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Yaw: "
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Groundspeed: "
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Status: " + status
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                     Text {
//                         text: "Flight Time: "
//                         Layout.fillWidth: true
//                         horizontalAlignment: Text.AlignHCenter
//                         color: "white"
//                         font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
//                     }
//                 }
//             }
//         }
//     }


// }
