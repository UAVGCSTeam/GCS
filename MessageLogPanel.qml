import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle
import "./components" as Components

Item {
    id: main
    width: 250
    height: 180

    focus: true
    Keys.priority: Keys.AfterItem

    property bool autoScroll: true

    Shortcut {
        sequence: StandardKey.Find
        enabled: main.activeFocus
        onActivated: console.log("Find message log")
    }

    Rectangle {
        anchors.fill: parent
        color: GcsStyle.panelStyle.primaryColor
        radius: GcsStyle.panelStyle.cornerRadius - 5

        ColumnLayout {
            anchors.fill: parent
            spacing: 6

            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                leftPadding: 5

                text: "Message Log"
                color: "white"
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
                        bottomPadding: 10

                        text: input
                        color: "white"
                    }
                }

                ListModel {
                    id: logModel
                }

                onContentHeightChanged: if (main.autoScroll) {autoScroll()} 

                function autoScroll() {
                    contentItem.contentY = contentItem.contentHeight - contentItem.height
                }
            }

            Button {
                Layout.alignment: Qt.AlignBottom | Qt.AlignRight

                background: Image{
                    anchors.fill: parent
                    source: main.autoScroll ? "qrc:/resources/autoscroll.png" : "qrc:/resources/warning.png"
                    sourceSize.width:  GcsStyle.PanelStyle.statusIconSize
                    sourceSize.height: GcsStyle.PanelStyle.statusIconSize
                }

                onPressed: {
                    main.autoScroll = !main.autoScroll 
                }
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: parent.height / 10
            text: "add text"
            onPressed: logModel.append({input: "This message is super long in order to test for wrapping and message."})
        }
    }
}