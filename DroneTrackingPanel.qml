import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

/*
  Welcome to the wild west....
  We say GcsStyle.PanelStyle because that is how it is defined as a singleton
  Our singleton definition is in /gcsStyle/qmldir
  This might be some of the nastiest code ever written... CSS/QSS is hell
*/

Rectangle {
    id: mainPanel
    width: 50
    height: 600
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius

    signal updateSelectedDroneSignal(string name, string status, int battery)

    // property var droneArray: [["Drone 1", "Charging", "10%"], ["Drone 2", "Flying", "70%"]]
    // property var droneArray: [droneObject1, droneObject2]
    property var droneObject1: { "name": "Drone1", "status": "Active", "battery": 10}
    property var droneObject2: { "name": "Drone2", "status": "Active", "battery": 10}

    // Function to update layout based on visibility of fireView and droneListView
    function updateRightPanelLayout() {
        if (droneListView.visible || fireView.visible) {
            rightPanel.width = 300 // Set fixed with for rightPanel when visible
            rightPanel.Layout.fillWidth = false
        }
        else {
            rightPanel.width = 0 // Set width to 0 when both are hidden / not visible
            rightPanel.Layout.fillWidth = true
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left vertical bar
        Rectangle {
            Layout.fillHeight: true
            width: GcsStyle.PanelStyle.sidebarWidth
            color: GcsStyle.PanelStyle.primaryColor
            radius: GcsStyle.PanelStyle.cornerRadius
            clip: true

            Rectangle {
                anchors.right: parent.right
                width: parent.width / 2
                height: parent.height
                color: parent.color
                visible: false
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: GcsStyle.PanelStyle.sidebarTopMargin
                spacing: GcsStyle.PanelStyle.buttonSpacing // Small space between buttons

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: GcsStyle.PanelStyle.buttonSize
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize
                    color: GcsStyle.PanelStyle.buttonColor
                    radius: GcsStyle.PanelStyle.buttonRadius
            }

                // Drone List View Toggle Button
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: GcsStyle.PanelStyle.buttonSize
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize
                    color: droneListView.visible ? GcsStyle.PanelStyle.buttonActiveColor : GcsStyle.PanelStyle.buttonColor
                    radius: GcsStyle.PanelStyle.buttonRadius

                    Image {
                        anchors.right: parent.right
                        anchors.rightMargin: GcsStyle.PanelStyle.iconRightMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/resources/droneSVG.svg"
                        sourceSize.width: GcsStyle.PanelStyle.iconSize
                        sourceSize.height: GcsStyle.PanelStyle.iconSize
                    }

                    MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                droneListView.visible = !droneListView.visible  // Toggle visibility
                                if (droneListView.visible) {
                                    fireView.visible = false  // Hide fireView when droneListView is visible
                                }
                                updateRightPanelLayout()
                            }
                        }
                }

                // Fire View Toggle Button
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: GcsStyle.PanelStyle.buttonSize
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize
                    color: fireView.visible ? GcsStyle.PanelStyle.buttonActiveColor : GcsStyle.PanelStyle.buttonColor
                    radius: GcsStyle.PanelStyle.buttonRadius

                    Image {
                        anchors.right: parent.right
                        anchors.rightMargin: GcsStyle.PanelStyle.iconRightMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/resources/fireSVG.svg"
                        sourceSize.width: GcsStyle.PanelStyle.iconSize
                        sourceSize.height: GcsStyle.PanelStyle.iconSize
                    }

                    MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                fireView.visible = !fireView.visible  // Toggle visibility
                                if (fireView.visible) {
                                    droneListView.visible = false  // Hide fireView when droneListView is visible
                                }
                                updateRightPanelLayout()
                            }
                        }
                }
                Item { Layout.fillHeight: true } // Bottom spacer to push buttons up
            }
        }

        // Right view
        ColumnLayout {
            id: rightPanel
            Layout.fillHeight: true
            spacing: 0
            Layout.preferredWidth: (droneListView.visible || fireView.visible) ? 300 : 0 // Dynamically adjust width

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
                        text: "Drone Tracking"
                        font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                        visible: droneListView.visible || fireView.visible // Only show header when either view is visible
                    }
                    Text {
                        text: "4 drones in fleet : 3 active"
                        font.pixelSize: GcsStyle.PanelStyle.subHeaderFontSize
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                        visible: droneListView.visible || fireView.visible // Only show subheader when either view is visible
                    }
                }
            }

            /*
              TODO:
                    Search Bar goes HERE
                    It needs to be able to quickly go through our list of current fleet drones
                    Then filter and show ONLY that one
            */

            // Drone list view
            ListView {
                id: droneListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: false
                model: droneListModel
                /*
                  Eventually this will read from our cpp list of drones
                  We will be able to dynamically read this list and create what we need

                  TODO:
                        Based on read in data of the drones, create it so it updates the
                        numbers like charge amount etc.
                        This is as much as I could do right now without proper data
                        or even drone connection.

                        Make drone list item selectable and display real data.

                        Make fire page as well-we need real time fire data for this page.

                        Make header allocate those numbers dynamically.

                        Make drone symbols update based on status.
                */
                ListModel {
                    // This ListModel gets its data from the fetch() JS function in main.qml
                    id: droneListModel
                }

                delegate: Rectangle {
                    width: parent.width
                    height: GcsStyle.PanelStyle.listItemHeight
                    color: index % 2 == 0 ? GcsStyle.PanelStyle.listItemEvenColor : GcsStyle.PanelStyle.listItemOddColor

                    MouseArea {
                        id: droneItem
                        anchors.fill: parent
                        onClicked: {
                            // ideally this would capture the clicked drone as an OBJECT, not individual properties
                            // passActiveDrone(model.name, model.status, model.battery)
                            updateSelectedDroneSignal(name, status, battery)
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: GcsStyle.PanelStyle.defaultMargin
                        spacing: GcsStyle.PanelStyle.defaultSpacing

                        Image {
                            source: "qrc:/resources/droneStatusSVG.svg"
                            sourceSize.width: GcsStyle.PanelStyle.statusIconSize
                            sourceSize.height: GcsStyle.PanelStyle.statusIconSize
                            Layout.preferredWidth: GcsStyle.PanelStyle.statusIconSize
                            Layout.preferredHeight: GcsStyle.PanelStyle.statusIconSize
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: name
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            }
                            Text {
                                text: status
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            }
                        }

                        Text {
                            text: battery + "%"
                            color: battery > 70 ? GcsStyle.PanelStyle.batteryHighColor :
                                                  battery > 30 ? GcsStyle.PanelStyle.batteryMediumColor :
                                                                 GcsStyle.PanelStyle.batteryLowColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                        }
                    }
                }
            }
            // Fire view (placeholder)
            Rectangle {
                id: fireView
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: GcsStyle.PanelStyle.secondaryColor
                visible: false
                radius: GcsStyle.PanelStyle.cornerRadius

                Text {
                    anchors.centerIn: parent
                    text: "Fire View"
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeLarge
                    color: GcsStyle.PanelStyle.textPrimaryColor
                }
            }
        }
    }

    // In the future in function might pull from a C++ file of the active drones.
    function populateListModel(droneList) {
        droneList.forEach(drone => {
                              droneListModel.append({ name: drone.name,
                                                        status: drone.status,
                                                        battery: drone.battery
                                                    }
                                                    )
                          })
    }
}
