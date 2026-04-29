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

    //Dark or light mode theme 
    property string currentTheme: settingsManager ? settingsManager.currentTheme : "dark"
    readonly property bool isLightTheme: currentTheme === "light"
    property string textColor: isLightTheme ? "black" : "white"

    //All the text logs 
    ListModel { id:logModel }

    //Texts log with the filter applied
    ListModel { id: filterLogModel }

    //Used in checkboxes to determine whether checked or not
    ListModel {
        id: filterStateModel
        ListElement {key: "debug"; name: "Debug"; checked: true}
        ListElement {key: "info"; name: "Info"; checked: true}
        ListElement {key: "warning";name: "Warning"; checked: true}
        ListElement {key: "critical";name: "Critical"; checked: true}
        ListElement {key: "fatal";name: "Fatal";checked: true}
    }

    //Returns checked state if the log type and checkbox type are the same
    function isTypeEnabled(type) {
        for (let i = 0; i < filterStateModel.count; i++){
            let filterItem = filterStateModel.get(i)
            if (filterItem.key === type)
                return filterItem.checked
        }
        return false
    }

    //Updates the filtered log based on changes from checkbox
    function updateFilter(){
        filterLogModel.clear()

        for (let i = 0; i < logModel.count; i++) {
            let item = logModel.get(i)

            if (isTypeEnabled(item.type)){
                filterLogModel.append(item)
            }
        }
    }
    
    //Returns a certain color based on the type of message
    function typeColor(type) {
        switch (type){
            case "debug":   return "green";
            case "info":    return "white";
            case "warning": return "yellow";
            case "critical":return "red";
            case "fatal":   return "pink";
        }
    }

    //Adds the message to the text log
    function appendLog(type, message){
        logModel.append({type: type.toLowerCase(), message: message})
        updateFilter()
    }

    //Message log console
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
                    onPressed: function(mouse) {
                        _resizeStartY = resizeHandle.mapToGlobal(mouse.x, mouse.y).y
                        _resizeStartFraction = heightFraction
                    }
                    onPositionChanged: function(mouse) {
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

                //Message Log title 
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    text: "Message Log"
                    color: textColor
                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                    font.family: GcsStyle.PanelStyle.fontFamily
                }
                //Filter button to access checkboxes
                Button {
                    background: Image{
                        source: isLightTheme ? "qrc:/resources/filterIcon_light.svg" : "qrc:/resources/filterIcon_dark.svg"
                        sourceSize.width:  GcsStyle.PanelStyle.statusIconSize
                        sourceSize.height: GcsStyle.PanelStyle.statusIconSize
                    }

                    onPressed: filterDropdown.visible = !filterDropdown.visible

                    //Creates a popup with the different filtered checkboxes
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

                        //Uses repeater and the filterStateModel to create checkboxes
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Repeater {
                                model: filterStateModel //Links the checboxes to the filterStateModel 

                                CheckBox {
                                    id: checkBox
                                    checked: model.checked

                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignTop
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24

                                    contentItem: Text {
                                        text: model.name
                                        color: textColor
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

                                    //Updates checked property for filterStateModel
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

            //Scrollable text area
            ScrollView {
                id: messageLog
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4
                clip: true

                ScrollBar.vertical.interactive: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                //Texts messages appears in here with custom ([Type] Message) layout
                ListView {
                    model: filterLogModel
                    width: parent.width

                    delegate: Row {
                        id: textLine
                        width: ListView.view ? ListView.view.width : 0
                        spacing: 8

                        //Type message
                        Text {
                            id: info
                            leftPadding: 5
                            width: 50

                            text: "[" + type + "]"
                            color: typeColor(type)
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            font.family: GcsStyle.PanelStyle.fontFamily
                        }
                        //Actual message 
                        Text {
                            rightPadding: 10
                            width: textLine.width - info.width - textLine.spacing //Allows the text message to be spaced properly
                            wrapMode: Text.WordWrap

                            text: " " + message
                            color: textColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                            font.family: GcsStyle.PanelStyle.fontFamily
                        }
                }
                    //Autoscrolling based on whether it is toggeled or not
                    onContentHeightChanged: {
                        if (settingsManager && settingsManager.logAutoScroll) { positionViewAtEnd() }
                    }
                }
            }

            // //test button
            // Button {
            //     text: "add text"
            //     height: 50
            //     onPressed: appendLog("Debug", "this is a debug message to test whether this works or not and also wrapping.")
            // }
        }
    }
}
