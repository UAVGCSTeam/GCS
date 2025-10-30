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
    border.color: GcsStyle.panelStyle.defaultBorderColor
    border.width: GcsStyle.panelStyle.defaultBorderWidth

    signal droneClicked(var drone)

    // Storing the full list of drones allows filtering
    property var fullDroneList: []

    Connections {
        target: droneController

        function onDroneStateChanged(droneName) {
            // Update the full drone list with latest data
            var updatedDrones = droneController.getAllDrones();
            fullDroneList = updatedDrones;
            updateDroneListModel(fullDroneList);
        }
        function onDronesChanged() { 
            // Update the full drone list with latest data
            var updatedDrones = droneController.getAllDrones();
            fullDroneList = updatedDrones;
            updateDroneListModel(fullDroneList);
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        anchors.margins: parent.border.width

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
                // anchors.margins: 2
                Layout.margins: 7
                // Layout.alignment: horizontalCenter
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search by drone name"
                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                onTextChanged: filterDroneList(text)

                background: Rectangle { 
                    color: "white" 
                    radius: 7
                    border.width: GcsStyle.panelStyle.defaultBorderWidth
                    border.color: GcsStyle.panelStyle.defaultBorderColor
                }
            }

            // Drone list view
            ListView {
                id: droneListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: true
                currentIndex: -1 //Sets currentIndex to -1 so that no item in the index is initially selected
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
                    width: parent ? parent.width : 0
                    height: GcsStyle.PanelStyle.listItemHeight

                    // local UI state
                    property bool hovered: false
                    property bool selected: ListView.isCurrentItem //false

                    // dynamic background color rule:
                    // selected > hovered > alternating row color (unchanged)
                    color: selected
                           ? GcsStyle.PanelStyle.listItemSelectedColor
                           : (hovered
                              ? GcsStyle.PanelStyle.listItemHoverColor
                              : (index % 2 === 0
                                 ? GcsStyle.PanelStyle.listItemEvenColor
                                 : GcsStyle.PanelStyle.listItemOddColor))

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered:  parent.hovered = true
                        onExited:   parent.hovered = false

                        onClicked: {
                            // mark this delegate as the selected one in the ListView
                            droneListView.currentIndex = index

                            // keep your existing behavior (open/update the right panel)
                            var droneObj = model
                            droneClicked(droneObj)
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: GcsStyle.PanelStyle.defaultSpacing
                        anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                        anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

                        Image {
                            id: statusIcon
                            source: "qrc:/resources/droneStatusSVG.svg"
                            sourceSize.width:  GcsStyle.PanelStyle.statusIconSize
                            sourceSize.height: GcsStyle.PanelStyle.statusIconSize
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: GcsStyle.PanelStyle.defaultMargin
                            spacing: 2

                            Text {
                                text: model.name
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            }
                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: model.battery
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            }
                        }

                        Item { Layout.fillWidth: true } // spacer to push 
                                                // items to right and column layout to left

                        Text { 
                            // This is where we can put the situation status icons
                            text: "LOL"
                        }
                    }
                }


            }

            // Add Drone Button
            Button {
                text: "Add Drone"
                Layout.fillWidth: true
                Layout.margins: GcsStyle.PanelStyle.defaultMargin

                MouseArea {
                    // This mouse area gives us the ability to add a pointer hand when the button is hovered
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: parent.clicked()
                }

                background: Rectangle {
                    // Sets a fixed background color for the button
                    color: GcsStyle.PanelStyle.buttonColor2
                    radius: 5
                    border.width: GcsStyle.panelStyle.defaultBorderWidth
                    border.color: GcsStyle.panelStyle.defaultBorderColor
                }

                contentItem: Text {
                    // This button is special because of this code.
                    // The idea is that the font has a specific color now. The issue was that for
                    // systems that use dynamic light/dark mode, the font disappeared in dark mode.
                    text: parent.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    font.pointSize: 12
                }

                onClicked: {
                    var component = Qt.createComponent("manageDroneWindow.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(null)
                        if (window !== null) {
                            window.show()
                        } else {
                            console.error("Error creating object:", component.errorString());
                        }
                    } else {
                        console.error("Component not ready:", component.errorString());
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

    function populateListModel(droneList) {
        fullDroneList = droneList
        updateDroneListModel(fullDroneList) // Initially display all drones
    }

    // Function to update the displayed ListModel based on a filtered list
    function updateDroneListModel(filteredList) {
        droneListModel.clear()
        filteredList.forEach(drone => {
            droneListModel.append({ name: drone.name, status: drone.status, battery: drone.battery,
                                    latitude: drone.latitude, longitude: drone.longitude, altitude: drone.altitude,
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

    // Function to clear current selection highlight
    function clearSelection() {
        droneListView.currentIndex = -1
    }
    
    // this ties into the telemetry panel to control maximum width of the panel         
    signal trackingWidthReady(int w)
    function publishTrackingWidth() {
        trackingWidthReady(width)
    }
}
