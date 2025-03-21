import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc://gcsStyle/panelStyle.qml" as GcsStyle

Window {
    id: goHomeLandingWindow
    width: 400
    height: 300
    title: qsTr("Go Home Landing Command")

    Rectangle {
        id: goHomeLandingBackground
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor

        // A temporary button that logs a message when clicked
        Button {
            id: goHomeLandingButton
            text: qsTr("Go Home Landing")
            anchors.centerIn: parent
            onClicked: console.log("Go Home Landing window button clicked")
        }
    }
}
