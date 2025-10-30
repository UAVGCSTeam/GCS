import QtQuick 2.15
import QtQuick.Window 2.15
import "coordinates.js" as Coordinates
import QtQuick.Controls
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle


// Scale Indicator
Item {
    id: scaleBarContainer
    anchors {
        left: parent.left
        bottom: parent.bottom
        leftMargin: GcsStyle.PanelStyle.defaultMargin + 40
        bottomMargin: GcsStyle.PanelStyle.applicationBorderMarginBottom
    }
    width: 160
    height: 30

    // Horizontal scale line
    Rectangle {
        id: scaleBarLine
        anchors.verticalCenter: parent.verticalCenter
        x: 10
        height: 2
        width: 100   // will update dynamically
        color: "black"
    }

    // Left bracket
    Rectangle {
        anchors.left: scaleBarLine.left
        anchors.verticalCenter: scaleBarLine.verticalCenter
        width: 2
        height: 10
        color: "black"
    }

    // Right bracket
    Rectangle {
        anchors.left: scaleBarLine.right
        anchors.verticalCenter: scaleBarLine.verticalCenter
        width: 2
        height: 10
        color: "black"
    }

    Text {
        id: scaleText
        anchors.verticalCenter: scaleBarLine.verticalCenter
        anchors.right: scaleBarLine.left
        anchors.rightMargin: 5
        color: "black"
        font.pixelSize: 14
        text: ""  // will dynamically update
    }


    // Dynamically updates scale bar when zoom level is changed
    function updateScaleBar(coord1, coord2, pixelLength) {
        var distance = coord1.distanceTo(coord2)

        // get the distance in a nice value
        var niceDistance = getNiceDistance(distance)
        var scaleWidth = pixelLength * niceDistance / distance

        scaleBarLine.width = scaleWidth

        if (niceDistance >= 1000)
            scaleText.text = (niceDistance / 1000).toFixed(0) + " km"
        else
            scaleText.text = Math.round(niceDistance) + " m"
    }


    // helper to round distances to multiples of 1, 2, 5 * 10^n
    function getNiceDistance(d){
        var pow10 = Math.pow(10, Math.floor(Math.log10(d)))
        var n = d / pow10
        if (n < 1.5) return 1 * pow10
        else if (n < 3) return 2 * pow10
        else if (n < 7) return 5 * pow10
        else return 10 * pow10
    }
}
