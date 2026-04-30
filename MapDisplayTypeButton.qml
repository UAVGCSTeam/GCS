import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic
import "qrc:/gcsStyle" as GcsStyle


Button {
    id: mapTypeButton

    property var mapTypes: ["Street"]
    property int currentTypeIndex: 0

    text: "Map Type: " + mapTypes[currentTypeIndex]

    onClicked: {
        // Single supported map type (OpenStreetMap Street), keep index pinned to 0.
        currentTypeIndex = 0
        mapController.changeMapType(currentTypeIndex)
    }

    background: Rectangle {
        // color: "white"
        color: mapTypeButton.pressed ? GcsStyle.PanelStyle.secondaryColor : GcsStyle.PanelStyle.buttonColor2 
        border.color: GcsStyle.PanelStyle.defaultBorderColor
        border.width: GcsStyle.PanelStyle.defaultBorderWidth
        radius: GcsStyle.PanelStyle.buttonRadius
    }

    contentItem: Text {
        text: mapTypeButton.text
        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
        font.family: GcsStyle.PanelStyle.fontFamily
        color: GcsStyle.PanelStyle.textPrimaryColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }


    Connections {
        target: mapController
        function onMapTypeChanged(typeIndex) {
            currentTypeIndex = typeIndex
        }
    }
}
