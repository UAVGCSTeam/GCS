import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle


Window {

    id: armWindow
    width: 400
    height: 300
    title: qsTr("ARM Command")
    property color panelColor: "green"


    Rectangle {
        id: armBackground
        anchors.fill: parent
        color: panelColor

        // A temporary button that logs a message when clicked
        Button {
            id: armButton
            text: qsTr("ARM")
            anchors.centerIn: parent
            onClicked: {
                // TEMP: hardcode a target; replace with your real XBee address or ID later
                const target = "11062025" // the custom SITL drone
                const ok = droneController.sendArm(target, true)   // true = arm, false = disarm
                console.log("ARM ->", target, ok)
                armWindow.close()
            }
        }
    }
}
