import QtQuick 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Button{
    id: statusPill
    height: textOfButton.implicitHeight
    flat: false
    anchors.margins: 5


    property var stateText: [
        "Idle",
        "Arming",
        "In Flight"
    ]

    property string statusVariant: "idle"

    background: Rectangle {
        //color: GcsStyle.PanelStyle.buttonActiveColor
        color: checkColor(statusVariant)
        radius: GcsStyle.PanelStyle.cornerRadius
    }

    contentItem: Text{
        id: textOfStatus
        text: stateText[checkText(statusVariant)] ?? stateText[0]
        color: "white"
        font.pointSize: GcsStyle.PanelStyle.fontSizeXS - 5
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } 

    function checkText(v){
        switch(v){
            case "idle": return 0
            case "inFlight": return 1
            case "arming": return 2
            case "active": return 3
        }
    }

    function checkColor(v){
        switch(v){
            case "idle": return GcsStyle.PanelStyle.secondaryColor
            case "inFlight": return GcsStyle.PanelStyle.buttonActiveColor
            case "arming": return GcsStyle.PanelStyle.statusFlyingColor
            case "active": return GcsStyle.PanelStyle.statusIdleColor
        }
    }
}