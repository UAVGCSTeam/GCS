import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle
import "./components"
import "./components" as Components

/*
  Welcome to the wild west....
  We say GcsStyle.PanelStyle because that is how it is defined as a singleton
  Our singleton definition is in /gcsStyle/qmldir
  This might be some of the nastiest code ever written... CSS/QSS is hell
*/

Rectangle {
    id: mainPanel
    width: 350
    color: GcsStyle.PanelStyle.surfaceBackground
    border.color: GcsStyle.panelStyle.defaultBorderColor
    border.width: 0  // remove the border

    signal selectionChanged(var selectedDrones)     // Broadcast the current selection so other components (telemetry, commands, etc.) stay in sync
    signal activeDroneChanged(var anchor)     // Broadcast the current anchor which will be used as the active drone
    signal followRequested(var drone)     // Dedicated signal for the "follow" shortcut so main.qml can toggle map following

    property var selectedIndexes: [] // Stores which rows are selected
    property int lastSelectedIndex: -1 // Remembers last drone the user clicked (so Shift-click knows where to start)
    property int selectionAnchorIndex: -1 // Anchor index used for Shift-range selections
    property bool multiSelectActive: selectedIndexes.length > 1 
    property string activePanel: "drones"   // "drones", "discovery"

    RowLayout {
        anchors.fill: parent
        spacing: 0
        anchors.margins: parent.border.width

        // Left vertical bar
        Rectangle {
            Layout.fillHeight: true
            width: 65
            // GcsStyle.PanelStyle.sidebarWidth
            color: GcsStyle.PanelStyle.baseBackground
            // radius: GcsStyle.PanelStyle.cornerRadius
            clip: true
            border.color: GcsStyle.panelStyle.defaultBorderColor
            border.width: GcsStyle.panelStyle.defaultBorderWidth

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: GcsStyle.PanelStyle.sidebarTopMargin
                spacing: GcsStyle.PanelStyle.buttonSpacing // Small space between buttons

                // Toggle button 1
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: GcsStyle.PanelStyle.buttonSize
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize
                    
                    property bool hovered: false
                    
                    color: mainPanel.activePanel === "drones" ? GcsStyle.PanelStyle.buttonActiveColor 
                        : (hovered ? GcsStyle.PanelStyle.hoverBackground : GcsStyle.PanelStyle.buttonColor)

                    border.color: mainPanel.activePanel === "drones" ? GcsStyle.PanelStyle.listItemSelectedBorderColor : "transparent"
                    border.width: mainPanel.activePanel === "drones" ? GcsStyle.PanelStyle.defaultBorderWidth : 0
                    radius: 8

                    Image {
                        anchors.right: parent.right
                        anchors.rightMargin: GcsStyle.PanelStyle.iconRightMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: GcsStyle.PanelStyle.isLightTheme ? "qrc:/resources/droneSVG.svg" : "qrc:/resources/droneStatusDarkMode.svg"
                        sourceSize.width: GcsStyle.PanelStyle.iconSize
                        sourceSize.height: GcsStyle.PanelStyle.iconSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true                        
                        onEntered: parent.hovered = true          
                        onExited: parent.hovered = false 
                        onClicked: {
                            mainPanel.activePanel = "drones"
                            droneController.rebuildVariant()
                        }
                    }
                }

                // Toggle button 2 - Mission Planning
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: GcsStyle.PanelStyle.buttonSize
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize
                    
                    property bool hovered: false
                    
                    color: mainPanel.activePanel === "mission" ? GcsStyle.PanelStyle.buttonActiveColor 
                        : (hovered ? GcsStyle.PanelStyle.hoverBackground : GcsStyle.PanelStyle.buttonColor)

                    border.color: mainPanel.activePanel === "mission" ? GcsStyle.PanelStyle.listItemSelectedBorderColor : "transparent"
                    border.width: mainPanel.activePanel === "mission" ? GcsStyle.PanelStyle.defaultBorderWidth : 0
                    radius: 8

                    Image {
                        anchors.right: parent.right
                        anchors.rightMargin: GcsStyle.PanelStyle.iconRightMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: GcsStyle.PanelStyle.isLightTheme ? "qrc:/resources/missionPlanningIcon.svg" : "qrc:/resources/missionPlanningIcon.svg"
                        sourceSize.width: GcsStyle.PanelStyle.iconSize
                        sourceSize.height: GcsStyle.PanelStyle.iconSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true                        
                        onEntered: parent.hovered = true          
                        onExited: parent.hovered = false 
                        onClicked: {mainPanel.activePanel = "mission"}
                    }
                }

                // Toggle button 3
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: GcsStyle.PanelStyle.buttonSize
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize
                    
                    property bool hovered: false

                    color: mainPanel.activePanel === "discovery" ? GcsStyle.PanelStyle.buttonActiveColor 
                        : (hovered ? GcsStyle.PanelStyle.hoverBackground : GcsStyle.PanelStyle.buttonColor)

                    border.color: mainPanel.activePanel === "discovery" ? GcsStyle.PanelStyle.listItemSelectedBorderColor : "transparent"
                    border.width: mainPanel.activePanel === "discovery" ? GcsStyle.PanelStyle.defaultBorderWidth : 0
                    radius: 8

                    Image {
                        anchors.right: parent.right
                        anchors.rightMargin: GcsStyle.PanelStyle.iconRightMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: GcsStyle.PanelStyle.isLightTheme ? "qrc:/resources/discoveryPanelIcon.svg" : "qrc:/resources/discoveryPanelIconDarkMode.svg"
                        sourceSize.width: GcsStyle.PanelStyle.iconSize
                        sourceSize.height: GcsStyle.PanelStyle.iconSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true                        
                        onEntered: parent.hovered = true          
                        onExited: parent.hovered = false 
                        onClicked: {
                            mainPanel.activePanel = "discovery"
                            droneController.loadUnknownDrones()
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
                height: 80 
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 0

                    Text {
                        text: {
                            switch (mainPanel.activePanel) {
                            case "drones":      return "Drone List"
                            case "mission":     return "Mission Planning"
                            case "discovery":   return "UAV Discovery"
                            }
                        }
                        font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                        font.family: GcsStyle.PanelStyle.fontFamily
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                        font.underline: true
                    }

                    Text {
                        text: {
                            switch (mainPanel.activePanel) {
                            case "drones":
                                return droneController ? "Drones in fleet: " + droneController.drones.length : "0 drones in fleet"
                            case "mission":
                                return droneController ? "Drones in fleet: " + droneController.drones.length : "0 drones in fleet"
                            case "discovery":
                                return droneController ? droneController.unknownDrones.filter(u => !u.ignored).length + " discovered UAVs" : "0 discovered UAVs"
                            }
                        }
                        font.pixelSize: GcsStyle.PanelStyle.subHeaderFontSize
                        font.family: GcsStyle.PanelStyle.fontFamily
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                    }
                }
            }


            // Drone list view
            ColumnLayout {
                id: droneListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: mainPanel.activePanel === "drones"
                spacing: 0

                // Search bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    height: 36
                    color: GcsStyle.PanelStyle.baseBackground
                    border.color: GcsStyle.panelStyle.defaultBorderColor
                    border.width: GcsStyle.panelStyle.defaultBorderWidth
                    Layout.bottomMargin: 8
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                        anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                        spacing: 6

                        // so that user can enter text
                        TextInput {
                            id: trackSearchInput
                            Layout.fillWidth: true
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            font.family: GcsStyle.PanelStyle.fontFamily
                            clip: true

                            // The "search..." inside the search bar
                            Text {
                                anchors.fill: parent
                                text: "Search..."
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                visible: !trackSearchInput.text
                            }
                        }
                    }
                }

                // Active section dropdown
                Column {
                    id: trackActiveSection
                    Layout.fillWidth: true
                    Layout.fillHeight: trackActiveSection.expanded  // ← fills space only when expanded
                    Layout.preferredHeight: expanded ? -1 : 36 // ← 36 = just the header when collapsed
                    property bool expanded: true
                    width: parent.width 

                    // creating the active dropdown rectangle
                    Rectangle {
                        width: parent.width
                        height: 36
                        color: "transparent"
                        border.color: GcsStyle.panelStyle.defaultBorderColor
                        border.width: GcsStyle.panelStyle.defaultBorderWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                            anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

                            //active text
                            Text {
                                text: "Active (" + droneController.drones.length + ")"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                Layout.fillWidth: true
                            }

                            // up/down arrows
                            Text {
                                text: parent.parent.parent.expanded ? "▲" : "▼"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                            }
                        }

                        // Active section header MouseArea mouse expands
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                trackActiveSection.expanded = !trackActiveSection.expanded
                                if (trackActiveSection.expanded) {
                                    trackIdleSection.expanded = false
                                    trackInactiveSection.expanded = false
                                }
                            }
                        }
                    }

                    // listing all the drones
                    ListView {
                        id: trackListView
                        width: parent.width
                        visible: parent.expanded
                        height: parent.height - 36
                        clip: true
                        
                        model: droneController.drones

                        // Item must be delegate root so ListView injects index / modelData; forward into UAVListItem.
                        delegate: Item {
                            width: ListView.view.width
                            height: GcsStyle.PanelStyle.itemHeight

                            readonly property int delegateIndex: index
                            readonly property var delegateModelData: modelData

                            UAVListItem {
                                width: parent.width
                                height: parent.height
                                panel: mainPanel
                                index: delegateIndex
                                modelData: delegateModelData
                            }
                        }
                    }
                }

                // Idle section
                Column {
                    id: trackIdleSection
                    Layout.fillWidth: true
                    Layout.fillHeight: trackIdleSection.expanded
                    Layout.preferredHeight: expanded ? -1 : 36
                    property bool expanded: false

                    Rectangle {
                        width: parent.width
                        height: 36
                        color: "transparent"
                        border.color: GcsStyle.panelStyle.defaultBorderColor
                        border.width: GcsStyle.panelStyle.defaultBorderWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                            anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

                            Text {
                                text: "Idle (" + droneController.drones.length + ")"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                Layout.fillWidth: true
                            }
                            Text {
                                text: parent.parent.parent.expanded ? "▲" : "▼"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                            }
                        }

                        // Idle section header MouseArea
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                trackIdleSection.expanded = !trackIdleSection.expanded
                                if (trackIdleSection.expanded) {
                                    trackActiveSection.expanded = false
                                    trackInactiveSection.expanded = false
                                }
                            }
                        }
                    }

                    // listing all the drones
                    ListView {
                        id: trackIdleListView
                        width: parent.width
                        visible: parent.expanded
                        height: parent.height - 36
                        clip: true
                        model: droneController.drones

                        //drone items
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: GcsStyle.PanelStyle.itemHeight
                            property bool hovered: false
                            property bool selected: mainPanel.isIndexSelected(index)

                            // when selected changes colors
                            color: selected
                                ? GcsStyle.PanelStyle.listItemSelectedColor
                                : (hovered
                                    ? GcsStyle.PanelStyle.hoverBackground
                                    : GcsStyle.PanelStyle.cardBackground)

                            border.color: selected
                                ? GcsStyle.PanelStyle.listItemSelectedBorderColor
                                : GcsStyle.panelStyle.defaultBorderColor
                            border.width: GcsStyle.panelStyle.defaultBorderWidth

                            // allows for multiselect
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: (mouse) => {
                                    const isShift = mouse.modifiers & Qt.ShiftModifier
                                    const isCmd = mouse.modifiers & Qt.MetaModifier
                                    const isCtrl = mouse.modifiers & Qt.ControlModifier
                                    const ctrlOrCmd = isCmd || isCtrl
                                    const hasModifier = isShift || ctrlOrCmd

                                    const alreadySelected = !hasModifier
                                                            && mainPanel.selectedIndexes.length === 1
                                                            && mainPanel.selectedIndexes[0] === index
                                    if (alreadySelected) {
                                        mainPanel.clearSelection()
                                        return
                                    }

                                    if (isShift && ctrlOrCmd) {
                                        mainPanel.setSingleSelection(index)
                                        mainPanel.emitSelectionChanged()
                                        mainPanel.followRequested(modelData)
                                        return
                                    }

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

                            //drone icon + battery pill
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                                anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                                spacing: 16

                                // Drone icon with battery badge
                                Item {
                                    width: 44
                                    height: 44
                                    Layout.alignment: Qt.AlignVCenter

                                    //drone image
                                    Image {
                                        anchors.centerIn: parent
                                        source: GcsStyle.PanelStyle.isLightTheme
                                            ? "qrc:/resources/droneStatusLightMode.svg"
                                            : "qrc:/resources/droneStatusDarkMode.svg"
                                        sourceSize.width: GcsStyle.PanelStyle.iconSize + 8
                                        sourceSize.height: GcsStyle.PanelStyle.iconSize + 8
                                    }

                                    // Red battery badge bottom-left
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        width: trackIdleBattRow.width + 11
                                        height: 16
                                        radius: 10
                                        anchors.leftMargin: -5 // for centering
                                        anchors.bottomMargin: -1
                                        color: GcsStyle.PanelStyle.lowBatteryColor
                                        border.color: Qt.rgba(255, 255, 255, 0.5) 
                                        border.width: 0.5

                                        Row {
                                            id: trackIdleBattRow
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Image {
                                                source: "qrc:/resources/batteryIcon.svg"
                                                sourceSize.width: 15
                                                sourceSize.height: 13
                                                y: (trackIdleBattText.implicitHeight - 13) / 2
                                            }

                                            Text {
                                                id: trackIdleBattText
                                                text: modelData.batteryLevel ? modelData.batteryLevel + "%" : "?"
                                                color: "white"
                                                font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                            }
                                        }
                                    }
                                }

                                // Name and connection status
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: modelData.name
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font.bold: true
                                    }

                                    Row {
                                        spacing: 4

                                        // Connected pill
                                        Rectangle {
                                            height: 18
                                            width: trackConnRow.width + 14
                                            radius: 8
                                            color: Qt.rgba(0, 0, 0, 0.25)
                                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: GcsStyle.PanelStyle.defaultBorderWidth

                                            Row {
                                                id: trackConnRow
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Rectangle {
                                                    width: 6
                                                    height: 6   
                                                    radius: 3
                                                    color: "#af874c"
                                                    y: (trackConnText.implicitHeight - 6) / 2 + 1
                                                }

                                                Text {
                                                    id: trackConnText
                                                    text: "Low Connection"
                                                    color: "#af874c" 
                                                    // Qt.rgba(11, 9, 9, 0.5)
                                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                                    font.family: GcsStyle.PanelStyle.fontFamily
                                                    y: (parent.height - implicitHeight) / 2 + 1
                                                }
                                            }
                                        }

                                        // Status pill
                                        Rectangle {
                                            height: 18
                                            width: trackIdleStatusRow.width + 14
                                            radius: 8
                                            color: Qt.rgba(0, 0, 0, 0.25)
                                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: GcsStyle.PanelStyle.defaultBorderWidth

                                            Row {
                                                id: trackIdleStatusRow
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Image {
                                                    source: "qrc:/resources/flightIcon.svg"
                                                    sourceSize.width: 11
                                                    sourceSize.height: 11
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    id: trackIdleStatusText
                                                    text: modelData.status ? modelData.status : "Grounded"
                                                    color: Qt.rgba(255, 255, 255, 0.5)
                                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                                    font.family: GcsStyle.PanelStyle.fontFamily
                                                    y: (parent.height - implicitHeight) / 2 + 1
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Inactive section
                Column {
                    id: trackInactiveSection
                    Layout.fillWidth: true
                    Layout.fillHeight: trackInactiveSection.expanded
                    Layout.preferredHeight: expanded ? -1 : 36
                    property bool expanded: false

                    Rectangle {
                        width: parent.width
                        height: 36
                        color: "transparent"
                        border.color: GcsStyle.panelStyle.defaultBorderColor
                        border.width: GcsStyle.panelStyle.defaultBorderWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                            anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

                            Text {
                                text: "Inactive (0)"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                Layout.fillWidth: true
                            }
                            Text {
                                text: parent.parent.parent.expanded ? "▲" : "▼"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                            }
                        }

                        // Inactive section header MouseArea
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                trackInactiveSection.expanded = !trackInactiveSection.expanded
                                if (trackInactiveSection.expanded) {
                                    trackActiveSection.expanded = false
                                    trackIdleSection.expanded = false
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }  // bottom spacer

                // // mock data to test list
                ListModel {
                    id: mockDroneList
                    ListElement {
                        uavtype: "Arducopter";
                        uid: "123";
                        fc: "cub black";
                        componentid: "1433";
                        systemid: "1232"
                        ignored: false
                    }
                    ListElement {
                        uavtype: "ArduPlane";
                        uid: "21hadjfalkdj";
                        fc: "cube orange";
                        componentid: "1231231";
                        systemid: "2894293"
                        ignored: false
                    }
                    ListElement {
                        uavtype: "3";
                        uid: "jaldfjalfd";
                        fc: "cube blue";
                        componentid: "080923";
                        systemid: "82084"
                        ignored: false
                    }
                }

                Item { Layout.fillHeight: true }  // bottom spacer
            }

            // Mission Planning View
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: mainPanel.activePanel === "mission"
                Layout.topMargin: 0 
                spacing: 0

                // Search bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    height: 36
                    color: GcsStyle.PanelStyle.baseBackground
                    border.color: GcsStyle.panelStyle.defaultBorderColor
                    border.width: GcsStyle.panelStyle.defaultBorderWidth
                    Layout.bottomMargin: 8
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                        anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                        spacing: 6

                        // so that user can enter text
                        TextInput {
                            id: missionSearchInput
                            Layout.fillWidth: true
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            font.family: GcsStyle.PanelStyle.fontFamily
                            clip: true

                            // The "search..." inside the search bar
                            Text {
                                anchors.fill: parent
                                text: "Search..."
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                visible: !missionSearchInput.text
                            }
                        }
                    }
                }

                // Active section dropdown
                Column {
                    id: missionActiveSection       
                    Layout.fillWidth: true
                    Layout.fillHeight: missionActiveSection.expanded  // ← fills space only when expanded
                    Layout.preferredHeight: expanded ? -1 : 36 // ← 36 = just the header when collapsed
                    property bool expanded: true
                    width: parent.width 

                    // creating the active dropdown rectangle
                    Rectangle {
                        width: parent.width
                        height: 36
                        color: "transparent"
                        border.color: GcsStyle.panelStyle.defaultBorderColor
                        border.width: GcsStyle.panelStyle.defaultBorderWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                            anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

                            //active text
                            Text {
                                text: "Active (" + droneController.drones.length + ")"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                Layout.fillWidth: true
                            }

                            // up/down arrows
                            Text {
                                text: parent.parent.parent.expanded ? "▲" : "▼"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                            }
                        }

                        // Active section header MouseArea mouse expands
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                missionActiveSection.expanded = !missionActiveSection.expanded
                                if (missionActiveSection.expanded) {
                                    missionIdleSection.expanded = false
                                    missionInactiveSection.expanded = false
                                }
                            }
                        }
                    }

                    // listing all the drones
                    ListView {
                        id: missionListView
                        width: parent.width
                        visible: parent.expanded
                        height: visible ? Math.min(droneController.drones.length * GcsStyle.PanelStyle.itemHeight, 7 * GcsStyle.PanelStyle.itemHeight) : 0 //makes sure that all drones fit in the panel
                        clip: true
                        model: droneController.drones

                        //drone items
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: GcsStyle.PanelStyle.itemHeight
                            property bool hovered: false
                            property bool selected: mainPanel.isIndexSelected(index)

                            // when selected changes colors
                            color: selected
                                ? GcsStyle.PanelStyle.listItemSelectedColor
                                : (hovered
                                    ? GcsStyle.PanelStyle.hoverBackground
                                    : GcsStyle.PanelStyle.cardBackground)

                            border.color: selected
                                ? GcsStyle.PanelStyle.listItemSelectedBorderColor
                                : GcsStyle.panelStyle.defaultBorderColor
                            border.width: GcsStyle.panelStyle.defaultBorderWidth

                            // allows for multiselect
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: (mouse) => {
                                    const isShift = mouse.modifiers & Qt.ShiftModifier
                                    const isCmd = mouse.modifiers & Qt.MetaModifier
                                    const isCtrl = mouse.modifiers & Qt.ControlModifier
                                    const ctrlOrCmd = isCmd || isCtrl
                                    const hasModifier = isShift || ctrlOrCmd

                                    const alreadySelected = !hasModifier
                                                            && mainPanel.selectedIndexes.length === 1
                                                            && mainPanel.selectedIndexes[0] === index
                                    if (alreadySelected) {
                                        mainPanel.clearSelection()
                                        return
                                    }

                                    if (isShift && ctrlOrCmd) {
                                        mainPanel.setSingleSelection(index)
                                        mainPanel.emitSelectionChanged()
                                        mainPanel.followRequested(modelData)
                                        return
                                    }

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

                            //drone icon + battery pill
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                                anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                                spacing: 16

                                // Drone icon with battery badge
                                Item {
                                    width: 44
                                    height: 44
                                    Layout.alignment: Qt.AlignVCenter

                                    //drone image
                                    Image {
                                        anchors.centerIn: parent
                                        source: GcsStyle.PanelStyle.isLightTheme
                                            ? "qrc:/resources/droneStatusLightMode.svg"
                                            : "qrc:/resources/droneStatusDarkMode.svg"
                                        sourceSize.width: GcsStyle.PanelStyle.iconSize + 8
                                        sourceSize.height: GcsStyle.PanelStyle.iconSize + 8
                                    }

                                    // Red battery badge bottom-left
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        width: missionActiveBattRow.width + 11
                                        height: 16
                                        radius: 10
                                        anchors.leftMargin: -5 // for centering
                                        anchors.bottomMargin: -1
                                        color: GcsStyle.PanelStyle.lowBatteryColor
                                        border.color: Qt.rgba(255, 255, 255, 0.5) 
                                        border.width: 0.5

                                        Row {
                                            id: missionActiveBattRow
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Image {
                                                source: "qrc:/resources/batteryIcon.svg"
                                                sourceSize.width: 15
                                                sourceSize.height: 13
                                                y: (missionActiveBattText.implicitHeight - 13) / 2
                                            }

                                            Text {
                                                id: missionActiveBattText
                                                text: modelData.batteryLevel ? modelData.batteryLevel + "%" : "?"
                                                color: "white"
                                                font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                            }
                                        }
                                    }
                                }

                                // Name and connection status
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: modelData.name
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font.bold: true
                                    }

                                    Row {
                                        spacing: 4

                                        // Connected pill
                                        Rectangle {
                                            height: 18
                                            width: missionConnRow.width + 14
                                            radius: 8
                                            color: Qt.rgba(0, 0, 0, 0.25)
                                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: GcsStyle.PanelStyle.defaultBorderWidth

                                            Row {
                                                id: missionConnRow
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Rectangle {
                                                    width: 6
                                                    height: 6   
                                                    radius: 3
                                                    color: "#4caf50"
                                                    y: (missionConnText.implicitHeight - 6) / 2 + 1
                                                }

                                                Text {
                                                    id: missionConnText
                                                    text: "Connected"
                                                    color: "#4caf50" 
                                                    // Qt.rgba(255, 255, 255, 0.5)
                                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                                    font.family: GcsStyle.PanelStyle.fontFamily
                                                    y: (parent.height - implicitHeight) / 2 + 1
                                                }
                                            }
                                        }

                                        // Status pill
                                        Rectangle {
                                            height: 18
                                            width: missionStatusRow.width + 14
                                            radius: 8
                                            color: Qt.rgba(0, 0, 0, 0.25)
                                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: GcsStyle.PanelStyle.defaultBorderWidth

                                            Row {
                                                id: missionStatusRow
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Image {
                                                    source: "qrc:/resources/flightIcon.svg"
                                                    sourceSize.width: 11
                                                    sourceSize.height: 11
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    id: missionStatusText
                                                    text: modelData.status ? modelData.status : "Flying"
                                                    color: Qt.rgba(255, 255, 255, 0.5)
                                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                                    font.family: GcsStyle.PanelStyle.fontFamily
                                                    y: (parent.height - implicitHeight) / 2 + 1
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // Idle section
                Column {
                    id: missionIdleSection
                    Layout.fillWidth: true
                    Layout.fillHeight: missionIdleSection.expanded
                    Layout.preferredHeight: missionIdleSection.expanded ? -1 : 36
                    property bool expanded: false
                    spacing: 0

                    Rectangle {
                        width: parent.width
                        height: 36
                        color: "transparent"
                        border.color: GcsStyle.panelStyle.defaultBorderColor
                        border.width: GcsStyle.panelStyle.defaultBorderWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                            anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

                            Text {
                                text: "Idle (" + droneController.drones.length + ")"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                Layout.fillWidth: true
                            }
                            Text {
                                text: parent.parent.parent.expanded ? "▲" : "▼"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                            }
                        }

                        // Idle section header MouseArea
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                missionIdleSection.expanded = !missionIdleSection.expanded
                                if (missionIdleSection.expanded) {
                                    missionActiveSection.expanded = false
                                }
                            }
                        }
                    }
                    // listing all the drones
                    ListView {
                        id: missionIdleListView
                        width: parent.width
                        visible: parent.expanded
                        height: parent.height - 36
                        // height: visible ? Math.min(droneController.drones.length * GcsStyle.PanelStyle.itemHeight, 7 * GcsStyle.PanelStyle.itemHeight) : 0 //makes sure that all drones fit in the panel
                        clip: true
                        model: droneController.drones

                        //drone items
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: GcsStyle.PanelStyle.itemHeight
                            property bool hovered: false
                            property bool selected: mainPanel.isIndexSelected(index)

                            // when selected changes colors
                            color: selected
                                ? GcsStyle.PanelStyle.listItemSelectedColor
                                : (hovered
                                    ? GcsStyle.PanelStyle.hoverBackground
                                    : GcsStyle.PanelStyle.cardBackground)

                            border.color: selected
                                ? GcsStyle.PanelStyle.listItemSelectedBorderColor
                                : GcsStyle.panelStyle.defaultBorderColor
                            border.width: GcsStyle.panelStyle.defaultBorderWidth

                            // allows for multiselect
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: (mouse) => {
                                    const isShift = mouse.modifiers & Qt.ShiftModifier
                                    const isCmd = mouse.modifiers & Qt.MetaModifier
                                    const isCtrl = mouse.modifiers & Qt.ControlModifier
                                    const ctrlOrCmd = isCmd || isCtrl
                                    const hasModifier = isShift || ctrlOrCmd

                                    const alreadySelected = !hasModifier
                                                            && mainPanel.selectedIndexes.length === 1
                                                            && mainPanel.selectedIndexes[0] === index
                                    if (alreadySelected) {
                                        mainPanel.clearSelection()
                                        return
                                    }

                                    if (isShift && ctrlOrCmd) {
                                        mainPanel.setSingleSelection(index)
                                        mainPanel.emitSelectionChanged()
                                        mainPanel.followRequested(modelData)
                                        return
                                    }

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

                            //drone icon + battery pill
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                                anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                                spacing: 16

                                // Drone icon with battery badge
                                Item {
                                    width: 44
                                    height: 44
                                    Layout.alignment: Qt.AlignVCenter

                                    //drone image
                                    Image {
                                        anchors.centerIn: parent
                                        source: GcsStyle.PanelStyle.isLightTheme
                                            ? "qrc:/resources/droneStatusLightMode.svg"
                                            : "qrc:/resources/droneStatusDarkMode.svg"
                                        sourceSize.width: GcsStyle.PanelStyle.iconSize + 8
                                        sourceSize.height: GcsStyle.PanelStyle.iconSize + 8
                                    }

                                    // Red battery badge bottom-left
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        width: missionIdleBattRow.width + 11
                                        height: 16
                                        radius: 10
                                        anchors.leftMargin: -5 // for centering
                                        anchors.bottomMargin: -1
                                        color: GcsStyle.PanelStyle.lowBatteryColor
                                        border.color: Qt.rgba(255, 255, 255, 0.5) 
                                        border.width: 0.5

                                        Row {
                                            id: missionIdleBattRow
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Image {
                                                source: "qrc:/resources/batteryIcon.svg"
                                                sourceSize.width: 15
                                                sourceSize.height: 13
                                                y: (missionIdleBattText.implicitHeight - 13) / 2
                                            }

                                            Text {
                                                id: missionIdleBattText
                                                text: modelData.batteryLevel ? modelData.batteryLevel + "%" : "?"
                                                color: "white"
                                                font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                            }
                                        }
                                    }
                                }

                                // Name and connection status
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: modelData.name
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font.bold: true
                                    }

                                    Row {
                                        spacing: 4

                                        // Connected pill
                                        Rectangle {
                                            height: 18
                                            width: missionConnRow.width + 14
                                            radius: 8
                                            color: Qt.rgba(0, 0, 0, 0.25)
                                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: GcsStyle.PanelStyle.defaultBorderWidth

                                            Row {
                                                id: missionConnRow
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Rectangle {
                                                    width: 6
                                                    height: 6   
                                                    radius: 3
                                                    color: "#af874c"
                                                    y: (missionConnText.implicitHeight - 6) / 2 + 1
                                                }

                                                Text {
                                                    id: missionConnText
                                                    text: "Low Connection"
                                                    color: "#af874c" 
                                                    // Qt.rgba(11, 9, 9, 0.5)
                                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                                    font.family: GcsStyle.PanelStyle.fontFamily
                                                    y: (parent.height - implicitHeight) / 2 + 1
                                                }
                                            }
                                        }

                                        // Status pill
                                        Rectangle {
                                            height: 18
                                            width: missionIdleStatusRow.width + 14
                                            radius: 8
                                            color: Qt.rgba(0, 0, 0, 0.25)
                                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: GcsStyle.PanelStyle.defaultBorderWidth

                                            Row {
                                                id: missionIdleStatusRow
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Image {
                                                    source: "qrc:/resources/flightIcon.svg"
                                                    sourceSize.width: 11
                                                    sourceSize.height: 11
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    id: missionIdleStatusText
                                                    text: modelData.status ? modelData.status : "Grounded"
                                                    color: Qt.rgba(255, 255, 255, 0.5)
                                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeXS
                                                    font.family: GcsStyle.PanelStyle.fontFamily
                                                    y: (parent.height - implicitHeight) / 2 + 1
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
            // Discovery panel
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: mainPanel.activePanel === "discovery"
                spacing: 0

                // Search bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    Layout.bottomMargin: 8
                    height: 36
                    color: GcsStyle.PanelStyle.baseBackground
                    border.color: GcsStyle.panelStyle.defaultBorderColor
                    border.width: GcsStyle.panelStyle.defaultBorderWidth
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                        anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                        spacing: 6

                        TextInput {
                            id: discoverySearchInput
                            Layout.fillWidth: true
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            font.family: GcsStyle.PanelStyle.fontFamily
                            clip: true

                            Text {
                                anchors.fill: parent
                                text: "Search..."
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                visible: !discoverySearchInput.text
                            }
                        }
                    }
                }
                ListView {
                    id: discoveryListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    property int selectedIndex: -1

                    model: droneController.unknownDrones.filter(u => !u.ignored)

                    delegate: Rectangle {
                        id: discoveredItem
                        width: ListView.view.width
                        clip: true

                        // Hides ignored drones
                        height: visible ? (expanded ? 110 : GcsStyle.PanelStyle.itemHeight) : 0
                        visible: !modelData.ignored // only shows the discovered drone if it isn't ignored

                        // local UI state
                        property bool expanded: false
                        property bool hovered: false
                        property bool selected: discoveryListView.selectedIndex === index

                        // when selected changes colors
                        color: selected
                            ? GcsStyle.PanelStyle.listItemSelectedColor
                            : (hovered
                                ? GcsStyle.PanelStyle.hoverBackground
                                : GcsStyle.PanelStyle.cardBackground)

                        border.color: selected
                            ? GcsStyle.PanelStyle.listItemSelectedBorderColor
                            : GcsStyle.panelStyle.defaultBorderColor
                        border.width: GcsStyle.panelStyle.defaultBorderWidth

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: discoveredItem.hovered = true
                            onExited: discoveredItem.hovered = false

                            onClicked: {
                                discoveredItem.expanded = !discoveredItem.expanded
                                discoveryListView.selectedIndex =
                                        (discoveryListView.selectedIndex === index )
                                            ? -1 : index
                            }
                        }

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            RowLayout {
                                id: collapsedView
                                Layout.fillWidth: true
                                Layout.margins: GcsStyle.PanelStyle.defaultMargin
                                spacing: 15

                                //drone icon
                                Item {
                                    width: 23
                                    height: 23
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.leftMargin: 8

                                    Image {
                                        anchors.centerIn: parent
                                        source: GcsStyle.PanelStyle.isLightTheme
                                            ? "qrc:/resources/droneStatusLightMode.svg"
                                            : "qrc:/resources/droneStatusDarkMode.svg"
                                        sourceSize.width: GcsStyle.PanelStyle.iconSize + 8
                                        sourceSize.height: GcsStyle.PanelStyle.iconSize + 8
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 8
                                    spacing: 2

                                    Text {
                                        text: modelData.uavType
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font.bold: true
                                    }

                                    Text {
                                        text: "UID: " + modelData.uid;
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeXXS
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                    }
                                    Text {
                                        text: "FC: " + modelData.fc;
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeXXS
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                    }
                                }

                                RowLayout {
                                    Layout.alignment: Qt.AlignRight
                                    spacing: 4

                                    //spacer all buttons are pushed towards the right
                                    Item { Layout.fillWidth: true }

                                    // Add drone button
                                    Button {
                                        Layout.preferredHeight: 27
                                        Layout.preferredWidth: 27
                                        padding: 0

                                        contentItem: Item {
                                            anchors.fill: parent
                                            Image {
                                                anchors.centerIn: parent
                                                source: "qrc:/resources/plusIcon.png"
                                                height: GcsStyle.PanelStyle.statusIconSize
                                                width: GcsStyle.PanelStyle.statusIconSize
                                                fillMode: Image.PreserveAspectFit
                                            }
                                        }

                                        background: Rectangle {
                                            radius: GcsStyle.PanelStyle.buttonRadius
                                            color: "#b0ffa8"
                                        }

                                        MouseArea {
                                            // This mouse area gives us the ability to add a pointer hand when the button is hovered
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                console.log("added!")
                                                droneController.acceptUnknownDrone(modelData.uid);
                                                discoveryListView.selectedIndex = -1
                                            }
                                        }
                                    }

                                    // Ignore drone button
                                    Button {
                                        Layout.preferredHeight: 27
                                        Layout.preferredWidth: 27
                                        padding: 0

                                        contentItem: Item {
                                            anchors.fill: parent
                                            Image {
                                                anchors.centerIn: parent
                                                source: "qrc:/resources/xIcon.png"
                                                height: GcsStyle.PanelStyle.statusIconSize
                                                width: GcsStyle.PanelStyle.statusIconSize
                                                fillMode: Image.PreserveAspectFit
                                            }
                                        }

                                        background: Rectangle {
                                            radius: GcsStyle.PanelStyle.buttonRadius
                                            color: "#ffa8a8"
                                        }

                                        MouseArea {
                                            // This mouse area gives us the ability to add a pointer hand when the button is hovered
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                console.log("ignore")
                                                droneController.setUnknownDroneIgnored(modelData.uid, true)
                                                discoveryListView.selectedIndex = -1
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                id: expandedView
                                visible: discoveredItem.expanded
                                Layout.fillWidth: true

                                ColumnLayout {
                                    anchors.fill: parent

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.margins: GcsStyle.PanelStyle.defaultMargin

                                        text: "more drone info..."
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeXXS
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                    Connections {
                        target: droneController
                        function onUnknownDronesChanged() {
                            discoveryListView.model = droneController ? droneController.unknownDrones : []
                        }
                    }
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
            trackListView.currentIndex = selectedIndexes[0]
        } else {
            trackListView.currentIndex = -1
        }
    }

    function isIndexSelected(idx) {
        return selectedIndexes.indexOf(idx) !== -1
    }

    // Turn selected indexes into real drone objects and emit the public signal
    function emitSelectionChanged() {
        var selected = []
        var model = trackListView.model

        for (var i = 0; i < selectedIndexes.length; ++i) {
            var idx = selectedIndexes[i]
            if (idx >= 0 && idx < trackListView.count) {
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
        if (idx < 0 || idx >= trackListView.count)
            return

        var model = trackListView.model
        var drone = model ? model[idx] : null

        activeDroneChanged(drone)
    }
}
