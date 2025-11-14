import QtQuick
import QtQuick.Controls

Rectangle {
    id: horizon
    width: 200
    height: 200
    color: "black"
    radius : width/2
    clip: true
    focus: true
    signal attitudeWidthReady(int w)
    function publishAttitudeWidth() {
        attitudeWidthReady(width)
    }
    property real pitch: 0
    property real bank: 0
    property var activeDrone: null

    // Keys.onPressed: (event) => {
    //     switch (event.key) {
    //     case Qt.Key_W:
    //         pitch = Math.min(pitch + 5, 85);
    //         break;
    //     case Qt.Key_S:
    //         pitch = Math.max(pitch - 5, -85);
    //         break;
    //     case Qt.Key_A:
    //         bank = Math.max(bank - 5, -85);
    //         break;
    //     case Qt.Key_D:
    //         bank = Math.min(bank + 5, 85);
    //         break;
    //     case Qt.Key_Q:
    //         visible = false;
    //         break;
    //     case Qt.Key_V:
    //         visible = true;
    //         break;
    //     }
    // }

    Item {
        id: ladderOverlay
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        z: 2
        // horizon line
        // Rectangle {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.verticalCenter: parent.verticalCenter
        //     width: parent.width
        //     height: 3
        //     color: "white"
        //     radius: 1
        // }

        // // reference bars to right and left of the horizon line
        // Rectangle {
        //     width: parent.width * 0.25
        //     height: 4
        //     color: "white"
        //     anchors.verticalCenter: parent.verticalCenter
        //     anchors.left: parent.horizontalCenter
        //     anchors.leftMargin: 4
        // }
        // Rectangle {
        //     width: parent.width * 0.25
        //     height: 4
        //     color: "white"
        //     anchors.verticalCenter: parent.verticalCenter
        //     anchors.right: parent.horizontalCenter
        //     anchors.rightMargin: 4
        // }

        // // Short vertical center line
        // Rectangle {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.verticalCenter: parent.verticalCenter
        //     width: 2
        //     height: 10
        //     color: "white"
        //     radius: 1
        //     opacity: 5
        // }
    }

    Image {
        id: background
        source: "qrc:/resources/attitude-indicator.png"
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        smooth: true
        clip: true

        // transform: [
        //     Rotation {
        //         id: roll
        //         axis { x: 0; y: 0; z: 1 }
        //         origin.x: background.width / 2
        //         origin.y: background.height / 2
        //         angle: activeDrone.orientation.x * 100
        //         Behavior on angle { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     },
        //     Scale {
        //         id: tilt
        //         origin.x: background.width / 2
        //         origin.y: background.height / 2
        //         yScale: 1.0 - Math.abs(activeDrone.orientation.y * 100) / 300
        //         Behavior on yScale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     },
        //     Translate {
        //         id: parallax
        //         x: activeDrone.orientation.x * 100 / 85 * 80
        //         y: -activeDrone.orientation.y * 100 / 85 * 100
        //         Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //         Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     }
        // ]
    }

    Text {
        text: "Pitch: " + activeDrone.orientation.y.toFixed(3)+ "°\nBank: " + activeDrone.orientation.x.toFixed(3) + "°"
        color: "white"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
    }
    function setActiveDrone(drone) {
        if (!drone) return;
        activeDrone = drone;
        pitch = (activeDrone.orientation.y) * 20
        bank = (activeDrone.orientation.x) * 20
    }
}
