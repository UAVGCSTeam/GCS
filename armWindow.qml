import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc://gcsStyle/panelStyle.qml" as GcsStyle
import com.gcs.dronecontroller 1.0

Window {
    id: armWindow
    width: 400
    height: 300
    title: qsTr("ARM Command")

    Rectangle {
        id: armBackground
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor

        // A temporary button that logs a message when clicked
        Button {
            id: armButton
            text: qsTr("ARM")
            anchors.centerIn: parent
            onClicked: {
                // Fire ARM with defaults (Python may use configured default target)
                const ok = droneController.sendArmCommand("Drone1", "", true)
                console.log("ARM window button clicked, command sent:", ok)
            }
        }
    }
}
