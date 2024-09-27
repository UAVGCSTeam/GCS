import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic

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
        color: mapTypeButton.pressed ? "#d0d0d0" : "#f0f0f0"
        border.color: "#808080"
        border.width: 1
        radius: 5
    }

    contentItem: Text {
        text: mapTypeButton.text
        font.pixelSize: 14
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
