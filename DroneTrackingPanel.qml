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
    width: 300
    height: 600
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius

    signal updateSelectedDroneSignal(string name, string status, string battery, string lattitude, string longitude, string altitude, string airspeed)

    // Storing the full list of drones allows filtering
    property var fullDroneList: []

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
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: GcsStyle.PanelStyle.sidebarTopMargin
                spacing: GcsStyle.PanelStyle.buttonSpacing // Small space between buttons

                // Toggle button 1
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
                            droneListView.visible = true
                            fireView.visible = false
                        }
                    }
                }

                // Toggle button 2
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
                            droneListView.visible = false
                            fireView.visible = true
                        }
                    }
                }
                Item { Layout.fillHeight: true } // Bottom spacer to push buttons up
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
                    }
                    Text {
                        text: "4 drones in fleet : 3 active"
                        font.pixelSize: GcsStyle.PanelStyle.subHeaderFontSize
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                    }
                }
            }

            // Search Bar filters displayed drones in real time
            TextField {
                id: searchField
                placeholderText: "Search by drone name"
                Layout.fillWidth: true
                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                onTextChanged: filterDroneList(text)
            }

            // Drone list view
            ListView {
                id: droneListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: true
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

                model: droneListModel

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
                            updateSelectedDroneSignal(model.name, model.status, model.battery, model.lattitude, model.longitude, model.altitude, model.airspeed)
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
                                text: model.name
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            }
                            Text {
                                text: model.status
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            }
                        }

                        Text {
                            text: model.battery + "%"
                            color: model.battery > 70 ? GcsStyle.PanelStyle.batteryHighColor :
                                                        model.battery > 30 ? GcsStyle.PanelStyle.batteryMediumColor :
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

    // Function to populate the ListModel with the full list of drones (fetched from main.qml)
    function populateListModel(droneList) {
        fullDroneList = droneList
        updateDroneListModel(fullDroneList) // Initially display all drones
    }

    // Function to update the displayed ListModel based on a filtered list
    function updateDroneListModel(filteredList) {
        droneListModel.clear()
        filteredList.forEach(drone => {
            droneListModel.append({ name: drone.name, status: drone.status, battery: drone.battery,
                                    lattitude: drone.lattitude, longitude: drone.longitude, altitude: drone.altitude,
                                    airspeed: drone.airspeed})
        })
    }

    // Function to filter drones by search text
    function filterDroneList(searchText) {
        if (searchText === "") {
            // Display all drones if search text is empty
            updateDroneListModel(fullDroneList)
        } else {
            // Filter and display drones matching search text
            var filteredList = fullDroneList.filter(drone => drone.name.toLowerCase().includes(searchText.toLowerCase()))
            updateDroneListModel(filteredList)
        }
    }
}
