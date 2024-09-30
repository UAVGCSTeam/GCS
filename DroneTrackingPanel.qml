import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: mainPanel
    width: 300
    height: 400
    color: "#f0f0f0"
    radius: 10

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left vertical bar
        Rectangle {
            Layout.fillHeight: true
            width: 50
            color: "#4CAF50"
            radius: 10
            clip: true

            Rectangle {
                anchors.right: parent.right
                width: parent.width / 2
                height: parent.height
                color: parent.color
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // Toggle button 1
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 40
                    height: 40
                    color: droneListView.visible ? "#45A049" : "transparent"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "🚁"
                        font.pixelSize: 24
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            droneListView.visible = true
                            settingsView.visible = false
                        }
                    }
                }

                // Toggle button 2
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 40
                    height: 40
                    color: settingsView.visible ? "#45A049" : "transparent"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "⚙️"
                        font.pixelSize: 24
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            droneListView.visible = false
                            settingsView.visible = true
                        }
                    }
                }
            }
        }

        // Right view
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#4CAF50"
                radius: 10
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
                    anchors.margins: 10
                    spacing: 0

                    Text {
                        text: "Drone Tracking"
                        font.pixelSize: 18
                        color: "white"
                    }
                    Text {
                        text: "4 drones in fleet : 3 active"
                        font.pixelSize: 12
                        color: "white"
                    }
                }
            }

            // Drone list view
            ListView {
                id: droneListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: true
                model: ListModel {
                    ListElement { name: "Drone #1"; status: "Flying"; battery: 93 }
                    ListElement { name: "Drone #2"; status: "Idle"; battery: 54 }
                    ListElement { name: "Drone #3"; status: "Flying"; battery: 42 }
                    ListElement { name: "Drone #4"; status: "Charging"; battery: 20 }
                }
                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: index % 2 == 0 ? "#ffffff" : "#f5f5f5"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            source: "qrc:/resources/droneSVG.svg"
                            sourceSize.width: 24
                            sourceSize.height: 24
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: name
                                color: "#333333"
                                font.pixelSize: 16
                            }
                            Text {
                                text: status
                                color: "#666666"
                                font.pixelSize: 12
                            }
                        }

                        Text {
                            text: battery + "%"
                            color: "#333333"
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // Settings view (placeholder)
            Rectangle {
                id: settingsView
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                visible: false
                radius: 10

                Text {
                    anchors.centerIn: parent
                    text: "Settings View"
                    font.pixelSize: 18
                    color: "#333333"
                }
            }
        }
    }
}
