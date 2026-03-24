import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle
import "."


// TODO: Update this to properly filter number of UAVs based on active, idle, and inactive

ColumnLayout {
    id: droneListView
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0

    property var panel
    property var listModel
    property int inactiveCount: 0
    property bool activeExpanded: true
    property bool idleExpanded: false
    property bool inactiveExpanded: false
    property string searchPlaceholder: "Search..."
    property string activeLabel: "Active"
    property string idleLabel: "Idle"
    property string inactiveLabel: "Inactive"
    property alias uavListPanel: trackActiveSection.listView
    property alias activeSection: trackActiveSection
    property alias idleSection: trackIdleSection
    property alias inactiveSection: trackInactiveSection

    readonly property int modelCount: (listModel && listModel.length !== undefined)
                                    ? listModel.length
                                    : trackActiveSection.listView.count

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
                    text: droneListView.searchPlaceholder
                    color: GcsStyle.PanelStyle.textSecondaryColor
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    font.family: GcsStyle.PanelStyle.fontFamily
                    visible: !trackSearchInput.text
                }
            }
        }
    }

    // Active section of drone list view
    MenuCollapsableBar {
        id: trackActiveSection
        expanded: droneListView.activeExpanded
        title: droneListView.activeLabel + " (" + droneListView.modelCount + ")"
        model: droneListView.listModel
        collapsePeersWhenExpanded: [trackIdleSection, trackInactiveSection]

        delegate: Item {
            width: ListView.view.width
            height: GcsStyle.PanelStyle.itemHeight

            readonly property int delegateIndex: index
            readonly property var delegateModelData: modelData

            UAVListItem {
                width: parent.width
                height: parent.height
                panel: droneListView.panel
                index: delegateIndex
                modelData: delegateModelData
            }
        }
    }

    // Idle section of drone list view
    MenuCollapsableBar {
        id: trackIdleSection
        expanded: droneListView.idleExpanded
        title: droneListView.idleLabel + " (" + droneListView.modelCount + ")"
        model: droneListView.listModel
        collapsePeersWhenExpanded: [trackActiveSection, trackInactiveSection]

        delegate: Item {
            width: ListView.view.width
            height: GcsStyle.PanelStyle.itemHeight

            readonly property int delegateIndex: index
            readonly property var delegateModelData: modelData

            UAVListItem {
                width: parent.width
                height: parent.height
                panel: droneListView.panel
                index: delegateIndex
                modelData: delegateModelData
            }
        }
    }

    // Inactive section of drone list view
    MenuCollapsableBar {
        id: trackInactiveSection
        expanded: droneListView.inactiveExpanded
        title: droneListView.inactiveLabel + " (" + droneListView.inactiveCount + ")"
        model: droneListView.listModel
        collapsePeersWhenExpanded: [trackActiveSection, trackIdleSection]
    }
    Item { Layout.fillHeight: true }  // bottom spacer
}