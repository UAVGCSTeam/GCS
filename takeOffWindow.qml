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
        color: GcsStyle.PanelStyle.primaryColor

        // A temporary button that logs a message when clicked
        Button {
            id: takeOffButton
            text: qsTr("Takeoff")
            anchors.centerIn: parent
            onClicked: {
            // TEMP: hardcode a target; replace with your real XBee address or ID later
                const target = "11062025" // the custom SITL drone
                const ok = droneController.sendTakeoffCmd(target)   // true = arm, false = disarm
                console.log("TAKEOFF ->", target, ok)
                takeOffWindow.close()
            }
        }
    }
}
