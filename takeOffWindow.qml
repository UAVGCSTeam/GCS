import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc://gcsStyle/panelStyle.qml" as GcsStyle

Window {
    id: takeOffWindow
    width: 400
    height: 300
    title: qsTr("Take-off Command")

    Rectangle {
        id: takeOffBackground
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor

        // A temporary button that logs a message when clicked
        Button {
            id: takeOffButton
            text: qsTr("Take-off")
            anchors.centerIn: parent
            onClicked: console.log("Take-off window button clicked")
        }
    }
}
