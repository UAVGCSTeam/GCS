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

    property bool autoScroll: true

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


            RowLayout{
                Layout.margins: 5

            Label {
                Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                text: "Message Log"
                color: "white"
            }

                Button{
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                    background: Image{
                        anchors.fill: parent
                        source: "qrc:/resources/warning.png"
                        sourceSize.width:  GcsStyle.PanelStyle.statusIconSize
                        sourceSize.height: GcsStyle.PanelStyle.statusIconSize
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
                    model: logModel

                    delegate: Row {
                        id: textLine
                        width: parent.width

                        spacing: 8

                        Text{
                            id: info
                            leftPadding: 5

                            text: "[" + type + "]"
                            color: typeColor(type)
                        }
                        Text{
                            width: textLine.width - info.width - textLine.spacing
                            wrapMode: Text.WordWrap

                            text: " " + message
                        color: "white"
                    }
                }

                    onContentHeightChanged: {
                        if (autoScroll) {positionViewAtEnd()}
                }
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
            onPressed: {
                switch (Math.floor(Math.random()*6)){
                    case 1: 
                        appendLog("debug","debug message is long in order to test if wrapping works");
                        break;
                    case 2:
                        appendLog("info","info message");
                        break;
                    case 3: 
                        appendLog("warning","warning message");
                        break;
                    case 4: 
                        appendLog("critical","critical message")
                        break;
                    case 5: 
                        appendLog("fatal","fatal message");
                        break;
                }
            }
        }
    }
}