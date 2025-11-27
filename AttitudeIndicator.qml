import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

Rectangle {
    id: backgroundRect
    width: 200
    height: 200
    color: "transparent"
    radius: width / 2
    focus: true // only for the keys to be enabled

    signal attitudeWidthReady(int w)
    function publishAttitudeWidth() {
        attitudeWidthReady(width)
    }

    property real pitch: 0
    property real bank: 0

    Keys.onPressed: (event) => {
            switch (event.key) {
            case Qt.Key_W:
                pitch = Math.max(pitch - 5, -105);
                break;
            case Qt.Key_S:
                pitch = Math.min(pitch + 5, 105);
                break;
            case Qt.Key_A:
                bank = Math.max(bank - 5, -85);
                break;
            case Qt.Key_D:
                bank = Math.min(bank + 5, 85);
                break;
            case Qt.Key_Q:
                visible = false;
                break;
            case Qt.Key_V:
                visible = true;
                break;
            }
        }

    Item {
        id: skySource
        x: -10000
        y: -10000
        width: backgroundRect.width
        height: backgroundRect.height

        Image {
            id: horizon
            anchors.centerIn: parent
            width: parent.width * 4
            height: parent.height * 4

            source: "qrc:/resources/horizon.JPG"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            antialiasing: true

            transform: [
                Rotation {
                    id: roll
                    axis { x: 0; y: 0; z: 1 }
                    origin.x: horizon.width / 2
                    origin.y: horizon.height / 2
                    angle: bank
                    Behavior on angle {
                        NumberAnimation {
                            duration: 200; easing.type: Easing.InOutQuad
                        }
                    }
                },

                Translate {
                    id: parallax
                    x: bank  / 85 * backgroundRect.width
                    y: -pitch / 85 * backgroundRect.height

                    Behavior on x {
                        NumberAnimation {
                            duration: 200; easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on y {
                        NumberAnimation {
                            duration: 200; easing.type: Easing.InOutQuad
                        }
                    }
                }
            ]
        }
    }
    // circular mask for opacitymask.
    Shape {
        id: circleMask
        anchors.fill: backgroundRect

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: "white"

            startX: width / 2
            startY: 0

            PathArc { // a half circle drawn from the top to the bottom, 0 to 180
                x: width / 2
                y: height
                radiusX: width / 2
                radiusY: height / 2
                direction: PathArc.Clockwise
            }

            PathArc { // half circle from bottom to the top 180 to 360
                x: width / 2
                y: 0
                radiusX: width / 2
                radiusY: height / 2
                direction: PathArc.Clockwise
            }
        }
    }

    OpacityMask {
        id: maskedBackground
        anchors.fill: backgroundRect
        source: skySource       // big off-screen moving horizon
        maskSource: circleMask  // circular aperture
        antialiasing: true
        smooth: true
        cached: false
        z: 1
    }

    Item {
        id: horizonline
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        z: 2

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 3
            color: "white"
            radius: 1
        }

        Rectangle {
            width: parent.width * 0.25
            height: 4
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: 4
        }

        Rectangle {
            width: parent.width * 0.25
            height: 4
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: 4
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: 10
            color: "white"
            radius: 1
            opacity: 0.8
        }
    }

    Shape {
        id: circleOutline
        anchors.fill: parent
        z: 3

        ShapePath {
            strokeWidth: 2
            strokeColor: "white"
            fillColor: "transparent"

            startX: width / 2
            startY: 0

            PathArc {
                x: width / 2
                y: height
                radiusX: width / 2
                radiusY: height / 2
                direction: PathArc.Clockwise
            }

            PathArc {
                x: width / 2
                y: 0
                radiusX: width / 2
                radiusY: height / 2
                direction: PathArc.Clockwise
            }
        }
    }

    Text {
        text: "Pitch: " + pitch + "° | Bank: " + bank + "°"
        color: "white"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
        z: 4
    }
}

