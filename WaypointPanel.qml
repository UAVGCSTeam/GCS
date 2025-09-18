import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc://gcsStyle/panelStyle.qml" as GcsStyle



    Rectangle {
        /*id: waypointPanel
        width: 400
        height: 300
        //title: qsTr("ARM Command")
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor*/
        id: waypointPanel
        width: 400
        height: 300
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor
        radius: GcsStyle.PanelStyle.cornerRadius



            TextField
            {
            id: altitudeField
            placeholderText: "Search by drone name"
            //Layout.fillWidth: true
            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
            onTextChanged: filterDroneList(text)
            }




        /*// A temporary button that logs a message when clicked
        Button {
            id: armButton
            text: qsTr("ARM")
            anchors.centerIn: parent
            onClicked: console.log("ARM window button clicked")
        }*/
    }

