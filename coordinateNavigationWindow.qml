import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc://gcsStyle/panelStyle.qml" as GcsStyle

Window {
    id: coordinateNavigationWindow
    width: 400
    height: 300
    title: qsTr("Coordinate Navigation Command")

    Rectangle {
        id: coordinateNavBackground
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor

        // A temporary button that logs a message when clicked
        Button {
            id: coordinateNavButton
            text: qsTr("Coordinate Navigation")
            anchors.centerIn: parent
            onClicked: console.log("Coordinate Navigation window button clicked")
        }
    }
}
