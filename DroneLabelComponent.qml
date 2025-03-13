import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    id: droneLabel
    color: "black"
    font.bold: true
    font.pixelSize: 12
    style: Text.Outline
    styleColor: "white"

    // Add a rectangle background for better visibility
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        color: "white"
        opacity: 0.7
        radius: 3
        z: -1
    }
}
