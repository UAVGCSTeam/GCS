import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle

// Collapsible header + optional ListView; collapsePeersWhenExpanded for accordion peers with .expanded.
Column {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: root.expanded
    Layout.preferredHeight: root.expanded ? -1 : root.headerHeight

    property bool expanded: false
    property int headerHeight: 36
    property string title: ""
    property string expandGlyph: "▼"
    property string collapseGlyph: "▲"
    property var model
    property alias delegate: listView.delegate
    property alias listView: listView
    property var collapsePeersWhenExpanded: null
    property bool showList: true

    width: parent.width

    readonly property var __listModel: !root.showList ? [] : (root.model !== undefined && root.model !== null ? root.model : [])

    function toggleExpanded() {
        expanded = !expanded
        if (expanded && collapsePeersWhenExpanded) {
            var peers = collapsePeersWhenExpanded
            for (var i = 0; i < peers.length; ++i) {
                var p = peers[i]
                if (p && p !== root && p.expanded !== undefined)
                    p.expanded = false
            }
        }
    }

    Rectangle {
        width: parent.width
        height: root.headerHeight
        color: "transparent"
        border.color: GcsStyle.panelStyle.defaultBorderColor
        border.width: GcsStyle.panelStyle.defaultBorderWidth

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
            anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin

            Text {
                text: root.title
                color: GcsStyle.PanelStyle.textPrimaryColor
                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                font.family: GcsStyle.PanelStyle.fontFamily
                Layout.fillWidth: true
            }

            Text {
                text: root.expanded ? root.collapseGlyph : root.expandGlyph
                color: GcsStyle.PanelStyle.textPrimaryColor
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.toggleExpanded()
        }
    }

    ListView {
        id: listView
        width: parent.width
        visible: root.expanded && root.showList
        height: root.showList ? (parent.height - root.headerHeight) : 0
        clip: true
        model: root.__listModel
    }
}
