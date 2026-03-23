import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle
import "."
/*
 * UAVListItem — ListView row for a fleet UAV
 * ListView only injects index/modelData on the delegate *root*. Prefer a wrapper Item
 * in the parent that forwards delegateIndex → index and delegateModelData → modelData.
 * Set panel to the DroneTrackingPanel root (id mainPanel) for selection handling.
 */

Rectangle {
    id: root

    property int index
    property var modelData
    property var panel // DroneTrackingPanel instance (selection, follow, etc.)

    // ListView.view exists only on the delegate root; when this item is nested, use parent width.
    width: ListView.view ? ListView.view.width : (parent ? parent.width : implicitWidth)
    height: GcsStyle.PanelStyle.itemHeight
    property bool hovered: false
    property bool selected: panel ? panel.isIndexSelected(index) : false

    // change colors on selection
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
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: (mouse) => {
            if (!panel)
                return

            const isShift = mouse.modifiers & Qt.ShiftModifier
            const isCmd = mouse.modifiers & Qt.MetaModifier
            const isCtrl = mouse.modifiers & Qt.ControlModifier
            const ctrlOrCmd = isCmd || isCtrl
            const hasModifier = isShift || ctrlOrCmd

            const alreadySelected = !hasModifier
                                    && panel.selectedIndexes.length === 1
                                    && panel.selectedIndexes[0] === index
            if (alreadySelected) {
                panel.clearSelection()
                return
            }

            if (isShift && ctrlOrCmd) {
                panel.setSingleSelection(index)
                panel.emitSelectionChanged()
                panel.followRequested(modelData)
                return
            }

            if (isShift) {
                var anchor = panel.selectionAnchorIndex
                if (anchor === -1) {
                    if (panel.selectedIndexes.length > 0) {
                        anchor = panel.selectedIndexes[0]
                    } else if (panel.lastSelectedIndex !== -1) {
                        anchor = panel.lastSelectedIndex
                    } else {
                        anchor = index
                    }
                    panel.selectionAnchorIndex = anchor
                }
                panel.selectRange(anchor, index)
            } else if (ctrlOrCmd) {
                panel.toggleSelection(index)
            } else {
                panel.setSingleSelection(index)
            }

            panel.emitSelectionChanged()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
        anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
        spacing: 16

        // Drone icon and battery 
        Item {
            width: 44
            height: 44
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                source: GcsStyle.PanelStyle.isLightTheme
                    ? "qrc:/resources/droneStatusLightMode.svg"
                    : "qrc:/resources/droneStatusDarkMode.svg"
                sourceSize.width: GcsStyle.PanelStyle.iconSize + 8
                sourceSize.height: GcsStyle.PanelStyle.iconSize + 8
            }

            BatteryIcon {
                batteryLevel: modelData ? modelData.batteryLevel : undefined
            }
        }

        // Name, connection status, and operational status
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
                ConnectionStatusIcon { }
                OperationalStatusIcon { status: modelData.status }
            }
        }
    }
}
