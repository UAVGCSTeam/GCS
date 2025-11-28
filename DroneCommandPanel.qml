import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: mainPanel
    width: 280
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius

    // has the collapsed form opened by default for main panel
    property bool expanded: false
    property var activeDrone: null
    property string currentTab: "Commands"

    function expand() {
        expandedBody.expand()
    }

    function collapse() {
        expandedBody.collapse()
    }

    //drone status for buttons
    readonly property int statusNotAvailable: 0
    readonly property int statusInProgress: 1
    readonly property int statusAvailable: 2

    onVisibleChanged: {
        if (!visible) {
            mainPanel.expanded = false
            expandedBody.collapse()
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            // Header aka collapsed view
            Rectangle {
                z: 2
                Layout.fillWidth: true
                height: GcsStyle.PanelStyle.headerHeight + 10
                color: "#17161e"
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            id: droneNameText
                            text: activeDrone ? activeDrone.name: ""
                            font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                            font.bold: true
                            color: "#d9e8f6"
                        }

                        // spacer
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }

                        Button {
                            id: collapseButton
                            icon.source: "qrc:/resources/down-arrow.png"
                            Layout.alignment: Qt.AlignTop | Qt.AlignRight
                            implicitWidth: 28
                            implicitHeight: 24

                            background: Rectangle {
                                border.width: 0
                                color: GcsStyle.PanelStyle.primaryColor
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (mainPanel.expanded) {
                                        expandedBody.collapse()
                                    }
                                    else {
                                        mainPanel.currentTab = "Commands"
                                        expandedBody.expand()
                                    }
                                    mainPanel.expanded = !mainPanel.expanded
                                }
                            }
                        }
                    }
                }
            }

            //expanded form
            Rectangle {
                id: expandedBody
                z: 1
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                Layout.topMargin: -20   //so the expanded/collapse view overlap and dont show ugly rounded corner
                Layout.fillWidth: true
                Layout.preferredHeight: 0
                clip: true

                PropertyAnimation {
                    id: animation
                    target: expandedBody
                    property: "Layout.preferredHeight"
                    easing.type: Easing.InOutQuad
                    duration: 500
                }

                function expand() {
                    animation.to = 300
                    animation.running = true
                }

                function collapse() {
                    animation.to = 0
                    animation.running = true
                }

                ListModel {
                    id: repeaterModel

                    ListElement {
                        name: "Go To"; //; destination:
                    }
                    ListElement {
                        name: "Return Home";//; destination:
                    }
                    ListElement {
                        name: "Hover"; //; destination:
                    }
                    ListElement {
                        name: "Do A Flip!"; //; destination:
                    }
                    ListElement {
                        name: "Connect"; //; destination:
                    }
                    ListElement {
                        name: "Evaluate Fleet"; //; destination:
                    }
                    ListElement {
                        name: "Arm Motors"; //; destination:
                    }
                    ListElement {
                        name: "Diagnose"; //; destination:
                    }
                }

                // mock status for testing
                property var buttonStatuses: ({
                    "Go To": statusAvailable, "Return Home": statusAvailable, "Hover": statusAvailable, "Do A Flip!": statusAvailable, "Connect": statusAvailable, "Evaluate Fleet": statusAvailable, "Arm Motors": statusAvailable, "Diagnose": statusAvailable
                })

                Loader {
                    id: bodyLoader
                    anchors.fill: parent
                    anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.bottomMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.topMargin: 20

                    sourceComponent: mainPanel.currentTab === "Commands" ? commandsBody : configBody
                }
            }
        }

        Column {
            id: tabColumn
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.preferredHeight: 0
            width: 24

            Rectangle {
                id: commandsTab
                width: 24
                height: 90
                visible: mainPanel.expanded
                color: mainPanel.currentTab === "Commands" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor

                Text {
                    anchors.centerIn: parent
                    text: "Commands"
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    rotation: 90
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mainPanel.currentTab = "Commands"
                }
            }

            Rectangle {
                id: configTab
                width: 24
                height: 60
                visible: mainPanel.expanded
                color: mainPanel.currentTab === "Config" ? GcsStyle.PanelStyle.primaryColor : GcsStyle.PanelStyle.secondaryColor

                Text {
                    anchors.centerIn: parent
                    text: "Config"
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    rotation: 90
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mainPanel.currentTab = "Config"
                }
            }
        }
    }

    Component {
        id: commandsBody

        ColumnLayout {
            spacing: 0

            Repeater {
                model: repeaterModel
                delegate: Button {
                    Layout.fillWidth: true
                    Layout.preferredWidth: GcsStyle.PanelStyle.buttonSize
                    Layout.preferredHeight: GcsStyle.PanelStyle.buttonSize

                    background: Rectangle {
                        border.width: 0.05
                        radius: 1
                        color: GcsStyle.PanelStyle.buttonColor
                    }

                    // gets button status
                    property int status: expandedBody.buttonStatuses[modelData] ?? statusNotAvailable

                    enabled: status === statusAvailable     // button only clickable for when status is available
                    hoverEnabled: enabled

                    contentItem: RowLayout {
                        spacing: 2
                        anchors.margins: 6

                        Item {
                            Layout.preferredWidth: GcsStyle.PanelStyle.iconSize
                            height: GcsStyle.PanelStyle.iconSize
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                //source: "https://supertails.com/cdn/shop/articles/360_f_681163919_71bp2aiyziip3l4j5mbphdxtipdtm2zh_e2c1dbbd-e3b0-4c7d-bc09-1ebff39513ef.jpg?v=1747293323"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        //changing text color
                        Text {
                            text: name
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true

                            color: {
                                if (status === statusNotAvailable)
                                    return GcsStyle.PanelStyle.commandNotAvailable
                                else if (status === statusInProgress)
                                    return GcsStyle.PanelStyle.commandInProgress
                                else
                                    return GcsStyle.PanelStyle.commandAvailable
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log ("opening", text)

                            if (status === statusAvailable) {
                                status = statusInProgress

                                console.log ("Action started:", text)
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: configBody

        Text {
            text: "hi"
            color: GcsStyle.PanelStyle.textPrimaryColor
        }
    }
}
