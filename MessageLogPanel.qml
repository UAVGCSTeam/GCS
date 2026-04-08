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

    ListModel { id: filterLogModel }

    ListModel {
        id: filterStateModel
        ListElement {key: "debug"; name: "Debug"; checked: true}
        ListElement {key: "info"; name: "Info"; checked: true}
        ListElement {key: "warning";name: "Warning"; checked: true}
        ListElement {key: "critical";name: "Critical"; checked: true}
        ListElement {key: "fatal";name: "Fatal";checked: true}
    }

    function isTypeEnabled(type) {
        for (let i = 0; i < filterStateModel.count; i++){
            let filterItem = filterStateModel.get(i)
            if (filterItem.key === type)
                return filterItem.checked
        }
        return false
    }

    function updateFilter(){
        filterLogModel.clear()

        for (let i = 0; i < logModel.count; i++) {
            let item = logModel.get(i)

            if (isTypeEnabled(item.type)){
                filterLogModel.append(item)
            }
        }
    }
    

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
        updateFilter()
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

            RowLayout {
                Layout.margins: 5

            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                text: "Message Log"
                color: "white"
                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                font.family: GcsStyle.PanelStyle.fontFamily
            }
                Button {
                    background: Image{
                        source: "qrc:/resources/warning.png"
                        sourceSize.width:  GcsStyle.PanelStyle.statusIconSize
                        sourceSize.height: GcsStyle.PanelStyle.statusIconSize
                    }

                    onPressed: filterDropdown.visible = !filterDropdown.visible

                    Popup {
                        id: filterDropdown
                        width: 100
                        height: 175

                        modal: false
                        focus: true
                        
                        visible: false

                        background: Rectangle {
                            color: GcsStyle.PanelStyle.baseBackground
                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                            border.width: GcsStyle.PanelStyle.defaultBorderWidth
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Repeater {
                                model: filterStateModel

                                CheckBox {
                                    id: checkBox
                                    checked: model.checked

                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignTop
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24

                                    contentItem: Text {
                                        text: model.name
                                        color: "white"
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: checkBox.indicator.width
                                    }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 20
                                        implicitHeight: 20
                                        radius: 4
                                        border.width: 2
                                        border.color: checkBox.checked ? "green" : "gray"
                                        color: checkBox.checked ? "lightgreen" : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: checkBox.checked ? "✔" : ""
                                            color: "white"
                                        }
                                    }

                                    onCheckedChanged: {
                                        filterStateModel.setProperty(index,"checked",checked)
                                        updateFilter()
                                    }
                                }
                                
                            }
                        }
                    }
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
                    model: filterLogModel
                    width: parent.width

                    delegate: Row {
                        id: textLine
                        width: parent.width

                        spacing: 8

                        Text {
                            id: info
                            leftPadding: 5
                            width: 50

                            text: "[" + type + "]"
                            color: typeColor(type)
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            font.family: GcsStyle.PanelStyle.fontFamily
                        }
                        Text {
                            rightPadding: 10
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

            Button {
                text: "add text"
                height: 50
                onPressed: appendLog("debug", "this is a debug message to test whether this works or not and also wrapping.")
            }
        }
    }
}