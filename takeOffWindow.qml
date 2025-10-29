import ErrorHandler 1.0
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Window {
    id: takeOffWindow
    width: 400
    height: 300
    title: qsTr("Take-off Command")

    Rectangle {
        id: takeOffBackground
        anchors.fill: parent
        color: ErrorHandler.requireDefined(GcsStyle.PanelStyle.primaryColor, "GcsStyle.PanelStyle.primaryColor")

        // A temporary button that logs a message when clicked
        Button {
            id: takeOffButton
            text: qsTr("Take-off")
            anchors.centerIn: parent
            onClicked: console.log("Take-off window button clicked")
        }
    }
}
