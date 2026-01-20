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
    width: 250
    height: 600
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius
    border.color: GcsStyle.panelStyle.defaultBorderColor
    border.width: GcsStyle.panelStyle.defaultBorderWidth

    signal selectionChanged(var selectedDrones)     // Broadcast the current selection so other components (telemetry, commands, etc.) stay in sync
    signal activeDroneChanged(var anchor)     // Broadcast the current anchor which will be used as the active drone
    signal followRequested(var drone)     // Dedicated signal for the "follow" shortcut so main.qml can toggle map following

    property var selectedIndexes: [] // Stores which rows are selected
    property int lastSelectedIndex: -1 // Remembers last drone the user clicked (so Shift-click knows where to start)
    property int selectionAnchorIndex: -1 // Anchor index used for Shift-range selections
    property bool multiSelectActive: selectedIndexes.length > 1 


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
                        source: "qrc:/resources/droneSVGDarkMode.svg"
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
                        source: "qrc:/resources/fireSVGDarkMode.svg"
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
                        text: {droneController ? droneController.drones.length + " drones in fleet" : "0 drones in fleet"}
                        font.pixelSize: GcsStyle.PanelStyle.subHeaderFontSize
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
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
                currentIndex: -1 //Sets currentIndex to -1 so that no item in the index is initially selected
                /* 
                    This drone list should be dynamic because it uses the 
                    dronecontroller.drones as the model for the drones 
                    instead of copied one-time data. 
                */
                /*
                  TODO:
                        Make drone list item selectable and display real data.
                        Make fire page as well-we need real time fire data for this page.
                        Make drone symbols update based on status.
                */

                model: droneController.drones

                delegate: Rectangle {
                    width: parent ? parent.width : 0
                    height: GcsStyle.PanelStyle.listItemHeight

                    // local UI state
                    property bool hovered: false
                    property bool selected: mainPanel.isIndexSelected(index)

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

                        onClicked: (mouse) => {
                            // Check to see if the user is holding cmd/ctrl/shift key
                            const isShift = mouse.modifiers & Qt.ShiftModifier
                            const isCmd = mouse.modifiers & Qt.MetaModifier      // Command key (macOS)
                            const isCtrl = mouse.modifiers & Qt.ControlModifier  // Control key (Windows/Linux)
                            const ctrlOrCmd = isCmd || isCtrl                    // ctrl and cmd need to be written in this combination
                                                                                 // or the single selection won't work for some reason
                            const hasModifier = isShift || ctrlOrCmd

                            // If drone is already selected, clear the selection (same behavior as e-mail clients)
                            const alreadySelected = !hasModifier
                                                    && mainPanel.selectedIndexes.length === 1
                                                    && mainPanel.selectedIndexes[0] === index
                            if (alreadySelected) {
                                mainPanel.clearSelection()
                                return
                            }

                            if (isShift && ctrlOrCmd) {
                                // Ctrl/Cmd + Shift + Click: single-select and request follow
                                mainPanel.setSingleSelection(index)
                                mainPanel.emitSelectionChanged()
                                mainPanel.followRequested(modelData)
                                return
                            }

                            // Checks for click modifiers and runs its respective helper function
                            if (isShift) {
                                var anchor = mainPanel.selectionAnchorIndex
                                if (anchor === -1) {
                                    if (mainPanel.selectedIndexes.length > 0) {
                                        anchor = mainPanel.selectedIndexes[0]
                                    } else if (mainPanel.lastSelectedIndex !== -1) {
                                        anchor = mainPanel.lastSelectedIndex
                                    } else {
                                        anchor = index
                                    }
                                    mainPanel.selectionAnchorIndex = anchor
                                }
                                mainPanel.selectRange(anchor, index)
                            } else if (ctrlOrCmd) {
                                mainPanel.toggleSelection(index)
                            } else {
                                mainPanel.setSingleSelection(index)
                            }

                            mainPanel.emitSelectionChanged()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: GcsStyle.PanelStyle.defaultSpacing
                        anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                        anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

                        Image {
                            id: statusIcon
                            source: { 
                                    modelData.altitude > 0.05 ? "qrc:/resources/droneStatusSVG.svg" : "qrc:/resources/grounded.png"
                            }
                            sourceSize.width:  GcsStyle.PanelStyle.statusIconSize
                            sourceSize.height: GcsStyle.PanelStyle.statusIconSize
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: GcsStyle.PanelStyle.defaultMargin
                            spacing: 2

                            Text {
                                text: modelData.name
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            }
                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: modelData.batteryLevel ? modelData.batteryLevel + "%" : "Battery Not Found"
                                color: modelData.batteryLevel < 70 ? "red" : GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            }
                        }

                        Item { Layout.fillWidth: true } // spacer to push 
                                                // items to right and column layout to left

                        Image {
                            id: warningIcon
                            source: {
                                modelData.batteryLevel < 70 ? "qrc:/resources/warning.png" : ""
                            }
                            sourceSize.width:  GcsStyle.PanelStyle.statusIconSize
                            sourceSize.height: GcsStyle.PanelStyle.statusIconSize
                            Layout.alignment: Qt.AlignVCenter
                         }
                    }
                }
                Connections {
                    target: droneController
                    function onDronesChanged() {
                        // TODO: check to see if telemetry data populates during simulation with ardupilot
                        droneListView.model = droneController ? droneController.drones : [] 
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

//Helper Functions for drone selection
    // Function to clear current selection highlight
    function clearSelection() {
        updateSelection([], -1)
        selectionAnchorIndex = -1
        emitSelectionChanged()
    }

    // Select exactly one row (used for normal clicks and follow shortcut)
    function setSingleSelection(idx) {
        updateSelection([idx], idx)
        selectionAnchorIndex = idx
    }

    // Add/remove a row from the current selection while preserving order
    function toggleSelection(idx) {
        var newSelection = selectedIndexes.slice()
        var existing = newSelection.indexOf(idx)

        if (existing === -1) {
            newSelection.push(idx)
            updateSelection(newSelection, idx)
            selectionAnchorIndex = idx
        } else {
            newSelection.splice(existing, 1)
            var nextLast = newSelection.length > 0 ? newSelection[newSelection.length - 1] : -1
            updateSelection(newSelection, nextLast)
            if (selectionAnchorIndex === idx) {
                selectionAnchorIndex = nextLast
            }
        }
    }

    // Build a contiguous selection between two indexes (shift-click behavior)
    function selectRange(startIdx, endIdx) {
        if (startIdx === -1) {
            setSingleSelection(endIdx)
            return
        }

        var from = Math.min(startIdx, endIdx)
        var to = Math.max(startIdx, endIdx)
        var rangeSelection = []

        for (var i = from; i <= to; ++i) {
            rangeSelection.push(i)
        }

        updateSelection(rangeSelection, endIdx)
    }

    // Normalize, de-duplicate, and store the new selection state
    function updateSelection(selectionArray, lastIndex) {
        var sorted = selectionArray.slice().sort(function(a, b) { return a - b })
        var deduped = []

        for (var i = 0; i < sorted.length; ++i) {
            if (deduped.length === 0 || deduped[deduped.length - 1] !== sorted[i]) {
                deduped.push(sorted[i])
            }
        }

        selectedIndexes = deduped
        lastSelectedIndex = lastIndex
        syncCurrentIndex()
    }

    // Keep ListView's built-in currentIndex aligned with our selection rules
    function syncCurrentIndex() {
        if (selectedIndexes.length === 1) {
            droneListView.currentIndex = selectedIndexes[0]
        } else {
            droneListView.currentIndex = -1
        }
    }

    function isIndexSelected(idx) {
        return selectedIndexes.indexOf(idx) !== -1
    }

    // Turn selected indexes into real drone objects and emit the public signal
    function emitSelectionChanged() {
        var selected = []
        var model = droneListView.model

        for (var i = 0; i < selectedIndexes.length; ++i) {
            var idx = selectedIndexes[i]
            if (idx >= 0 && idx < droneListView.count) {
                var droneData = model && model[idx] !== undefined ? model[idx] : null
                if (droneData) {
                    selected.push(droneData)
                }
            }
        }

        selectionChanged(selected)
    }

    // Whenever the selection changes, the active drone has a chance of also changing
    // This will let main.qml know the active drone is updated
    onSelectionChanged: function(selected) {
        var idx = selectionAnchorIndex
        if (idx < 0 || idx >= droneListView.count)
            return

        var model = droneListView.model
        var drone = model ? model[idx] : null

        activeDroneChanged(drone)
    }
}
