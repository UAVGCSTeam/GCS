import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic
import "qrc:/gcsStyle" as GcsStyle


Button {
    id: mapTypeButton

    property var mapTypes: ["Street", "Satellite", "Terrain"]
    property int currentTypeIndex: 0

    text: "Map Type: " + mapTypes[currentTypeIndex]

    onClicked: {
        // Call our mapController.cpp logic
        currentTypeIndex = (currentTypeIndex + 1) % mapTypes.length
        mapController.changeMapType(currentTypeIndex)
    }

    background: Rectangle {
        // color: "white"
        color: mapTypeButton.pressed ? "#f0f0f0" : "white" 
        border.color: GcsStyle.PanelStyle.defaultBorderColor
        border.width: GcsStyle.PanelStyle.defaultBorderWidth
        radius: GcsStyle.PanelStyle.buttonRadius
    }

    contentItem: Text {
        text: mapTypeButton.text
        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
        color: mapTypeButton.pressed ? "#404040" : "#202020"
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
