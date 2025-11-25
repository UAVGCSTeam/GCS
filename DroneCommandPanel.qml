import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle

Rectangle {
    id: mainPanel
    width: 300
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Right view
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            // Header aka collapsed view
            Rectangle {
                z: 2
                Layout.fillWidth: true
                height: GcsStyle.PanelStyle.headerHeight + 10
                //color: GcsStyle.PanelStyle.primaryColor
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
                            icon.source: "https://assets.streamlinehq.com/image/private/w_300,h_300,ar_1/f_auto/v1/icons/4/sidebar-collapse-wa8mq2uy2zwwo4sv7h6j8.png/sidebar-collapse-2w3re62ix0sjmbcj645cho.png?_a=DATAg1AAZAA0"
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
                    "Connect": statusAvailable, "Arm Drone": statusNotAvailable, "Take Off": statusAvailable, "Waypointing": statusNotAvailable, "Go Home": statusAvailable, "Hover": statusAvailable
                })

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.leftMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.rightMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.bottomMargin: GcsStyle.PanelStyle.defaultMargin
                    anchors.topMargin: 20
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
                                        source: "https://supertails.com/cdn/shop/articles/360_f_681163919_71bp2aiyziip3l4j5mbphdxtipdtm2zh_e2c1dbbd-e3b0-4c7d-bc09-1ebff39513ef.jpg?v=1747293323"
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
                                            return GcsStyle.PanelStyle.textSecondaryColor
                                        else if (status === statusInProgress)
                                            return GcsStyle.PanelStyle.batteryMediumColor
                                        else
                                            return GcsStyle.PanelStyle.textPrimaryColor
                                    }
                                }
                            }

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
    }

    // has the collapsed form opened by default for main panel
    property bool expanded: false

    function expand() {
        expandedBody.expand()
    }

    function collapse() {
        expandedBody.collapse()
    }

    property var activeDrone: null

    //drone status for buttons
    readonly property int statusNotAvailable: 0
    readonly property int statusInProgress: 1
    readonly property int statusAvailable: 2

    /*function populateActiveDroneModel(drone) {
        if (!drone) return;

        activeDrone = drone; // store reference to currently active drone

        // Update model
        activeDroneModel.clear();
    }*/
}

