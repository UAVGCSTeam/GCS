import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc://gcsStyle/panelStyle.qml" as GcsStyle

Window {
    id: armWindow
    width: 400
    height: 300
    title: qsTr("ARM Command")
    // This is Bryce doing stuff

    Rectangle {
        id: armBackground
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor

        // A temporary button that logs a message when clicked
        Button {
            id: armButton
            text: qsTr("ARM")
            anchors.centerIn: parent
            onClicked: console.log("ARM window button clicked")
        }
    }
}
