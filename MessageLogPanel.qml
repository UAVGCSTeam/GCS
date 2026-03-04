import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle
import "./components" as Components

Rectangle {
    id: mainML
    width: 250
    height: 180
    color: GcsStyle.panelStyle.primaryColor
    radius: GcsStyle.panelStyle.cornerRadius - 5
    border.color: "white"
    border.width: GcsStyle.panelStyle.defaultBorderWidth

    property bool enabledAS: false //autoscrolling
    

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Rectangle {
        color: GcsStyle.panelStyle.secondaryColor
        radius: GcsStyle.panelStyle.cornerRadius - 10 
        border.color: "white"
        border.width: GcsStyle.panelStyle.defaultBorderWidth

        anchors.top: parent.top
        Layout.fillWidth: true
        height: parent.height/10
        z: 2

        Text {
            text: "Message Log"
            color: "white"
            leftPadding: 5 
        }
        }

        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.interactive: false
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            ScrollBar.vertical.interactive: true

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true 
                model: logModel
                clip: true

                delegate: Text {
                    width: ListView.view.width
                    wrapMode: Text.Wrap
                    padding: 5

                    text: input
                    color: "white"
                }
            }

            ListModel {
                id: logModel
            }

            function autoScroll() {
                contentItem.contentY = contentItem.contentHeight - contentItem.height
            }

            onContentHeightChanged: if (enabledAS) {autoScroll()}

            
        }
        Button {
            Layout.alignment: Qt.AlignLeft
            text: "add text"
            onPressed: logModel.append({input: "This message is super long in order to test for wrapping and message."})
        }
        Button {
            Layout.alignment: Qt.AlignRight
            text: "autoscroll"
            onPressed: {
                enabledAS: true 
            }
        }
    }
}