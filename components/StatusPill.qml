import QtQuick 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Item {
    id: statusPill
    property int size: GcsStyle.PanelStyle.statusIconSize

    property string statusVariant: "idle"

    property string statusText: checkText(statusVariant)
    property color statusColor: checkColor(statusVariant)

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: statusPill.statusColor
        border.width: statusPill.size / 10
        border.color: Qt.darker(color, 1.4)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: tooltip.open()
        onExited: tooltip.close()
    }

    Popup {
        id: tooltip
        modal: false
        focus: false
        closePolicy: Popup.NoAutoClose
        padding: 4

        x: statusPill.width
        y: statusPill.height

        background: Rectangle {
            radius: GcsStyle.PanelStyle.cornerRadius - 7
            color: Qt.lighter(statusColor,1.5)
            opacity: 0.95
        }

        contentItem: Text {
            text: statusPill.statusText
            color: "white"
            font.pointSize: GcsStyle.PanelStyle.fontSizeXS - 2
            font.weight: Font.DemiBold
        }
    }

    function checkText(v) {
        switch(v){
            case "idle": return "Idle"
            case "inFlight": return "In Flight"
            case "arming": return "Arming"
            case "active": return "Idle"
        }
    }

    function checkColor(v) {
        switch(v){
            case "idle": return GcsStyle.PanelStyle.secondaryColor
            case "inFlight": return GcsStyle.PanelStyle.buttonActiveColor
            case "arming": return GcsStyle.PanelStyle.statusFlyingColor
            case "active": return GcsStyle.PanelStyle.statusIdleColor
        }
    }
}
