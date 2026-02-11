import QtQuick 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Button{
    id: statusPill
    height: textOfButton.implicitHeight + 15
    flat: true
    anchors.margins: 12
    
    property var stateText: [
        "Idle",
        "Arming",
        "In Flight"
    ]

    property string statusVariant: "idle"

    background: Rectangle {
        color: checkColor(statusVariant)
        border: GcsStyle.PanelStyle.defaultBorderWidth
        radius: GcsStyle.PanelStyle.cornerRadius
    }

    contentItem: text{
        id: textOfStatus
        text: stateText[checkText(statusVariant)] ?? stateText[0]
        color: "black"
        font.pointSize: GcsStyle.PanelStyle.fontSizeXS
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } 
    
    function checkText(var){
        switch(var){
            case "idle": return 0
            case "inFlight": return 1
            case "arming": return 2
            case "active": return 3
        }
    }

    function checkColor(var){
        switch(var){
            case "idle": return GcsStyle.PanelStyle.secondaryColor
            case "inFlight": return GcsStyle.PanelStyle.buttonActiveColor
            case "arming": return GcsStyle.PanelStyle.statusFlyingColor
            case "active": return GcsStyle.PanelStyle.statusIdleColor
        }
    }
}