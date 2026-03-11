import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.platform
import "qrc:/gcsStyle" as GcsStyle
import "./components" as Components

Item {
    id: main
    width: droneStatusPanel ? droneStatusPanel.width : 250
    height: droneStatusPanel ? droneStatusPanel.height * heightFraction : 180

    property var droneStatusPanel: null
    property real heightFraction: 0.25  // Default: bottom 1/4 of drone panel
    property real heightFractionMin: 0.1
    property real heightFractionMax: 0.75
    property real _resizeStartY: 0
    property real _resizeStartFraction: 0.25

    ListModel { id:logModel }

    function typeColor(type) {
        switch (type){
            case "debug":   return "green";
            case "info":    return "white";
            case "warning": return "yellow";
            case "critical":return "red";
            case "fatal":   return "pink";
        }
    }

    function appendLog(type, message){
        logModel.append({type: type, message: message})
    }

    Rectangle {
        anchors.fill: parent
        color: GcsStyle.panelStyle.primaryColor
        radius: GcsStyle.panelStyle.cornerRadius - 5

        ColumnLayout {
            anchors.fill: parent
            spacing: 6

            // Draggable resize handle at top
            Rectangle {
                id: resizeHandle
                Layout.fillWidth: true
                Layout.preferredHeight: 12
                color: Qt.rgba(1, 1, 1, 0.15)
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 4
                    radius: 2
                    color: Qt.rgba(1, 1, 1, 0.5)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeVerCursor
                    preventStealing: true
                    onPressed: {
                        _resizeStartY = resizeHandle.mapToGlobal(mouse.x, mouse.y).y
                        _resizeStartFraction = heightFraction
                    }
                    onPositionChanged: {
                        if (pressed && droneStatusPanel) {
                            var currentGlobalY = resizeHandle.mapToGlobal(mouse.x, mouse.y).y
                            var deltaY = _resizeStartY - currentGlobalY
                            var deltaFraction = deltaY / droneStatusPanel.height
                            heightFraction = Math.max(heightFractionMin, Math.min(heightFractionMax, _resizeStartFraction + deltaFraction))
                        }
                    }
                }
            }

            RowLayout{
                Layout.margins: 5

            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                text: "Message Log"
                color: "white"
                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                font.family: GcsStyle.PanelStyle.fontFamily
            }

            }
            

            ScrollView {
                id: messageLog
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 4
                clip: true

                ScrollBar.vertical.interactive: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                ListView {
                    model: logModel

                    delegate: Row {
                        id: textLine
                        width: parent.width

                        spacing: 8

                        Text {
                            id: info
                            leftPadding: 5
                            width: 75
                            text: "[" + type + "]"
                            color: typeColor(type)
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            font.family: GcsStyle.PanelStyle.fontFamily
                        }
                        Text {
                            width: textLine.width - info.width - textLine.spacing
                            wrapMode: Text.WordWrap
                            text: " " + message
                            color: "white"
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            font.family: GcsStyle.PanelStyle.fontFamily
                        }
                }

                    onContentHeightChanged: {
                        if (settingsManager && settingsManager.logAutoScroll) { positionViewAtEnd() }
                    }
                }
            }

        }
    }
}