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
            //Layout.fillHeight: true
            spacing: 0

            // Header aka collapsed view
            Rectangle {
                z: 2
                Layout.fillWidth: true
                height: GcsStyle.PanelStyle.headerHeight + 10
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true

                /*Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height / 2
                    color: parent.color
                }*/

                ColumnLayout {
                    anchors.fill:parent
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
                            color: "#006480"
                        }

                        // spacer
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }

                        Button {
                            id: collapseButton
                            text: mainPanel.expanded ? "v" : ">"
                            Layout.alignment: Qt.AlignTop | Qt.AlignRight
                            implicitWidth: 28
                            implicitHeight: 24


                            MouseArea {
                                anchors.fill: parent
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

                    Text {
                        text: "Commands"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                        //font.pixelSize: GcsStyle.PanelStyle.headerFontSize - 5
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                    }
                }
            }
            //expanded form
            Rectangle {
                id: expandedBody
                z: 1
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                Layout.fillWidth: true
                Layout.topMargin: -30

                height: 0
                //opacity: height > 0 ? 1 : 0
                clip: true

                PropertyAnimation {
                    id: animation
                    target: expandedBody
                    property: "height"
                    easing.type: Easing.InOutQuad
                    duration: 500
                }

                function expand() {
                    animation.to = content.Layout.preferredHeight
                    animation.running = true
                }

                function collapse() {
                    animation.to = 0
                    animation.running = true
                }

                ListModel {
                    id: repeaterModel

                    ListElement {
                        name: "Connect" //; destination:
                    }
                    ListElement {
                        name: "Arm Drone" //; destination:
                    }
                    ListElement {
                        name: "Take Off" //; destination:
                    }
                    ListElement {
                        name: "Waypointing" //; destination:
                    }
                    ListElement {
                        name: "Go Home" //; destination:
                    }
                    ListElement {
                        name: "Hover" //; destination:
                    }
                }

                ColumnLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 5

                    Layout.preferredHeight: content.implicitHeight + 14

                    Repeater {
                        model: repeaterModel
                        delegate: Button {
                            text: name
                            Layout.fillWidth: true
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            Layout.topMargin: index === 0 ? 20 : 0 //adding padding above first button

                            background: Rectangle {
                                border.width: 0.05
                                radius: 1
                            }

                            onClicked: {
                                console.log ("opening", name)
                            }
                        }
                    }
                }
            }
        }
    }

    // has the collapsed form opened by default
    property bool expanded: false

    function expand() {
        expandedBody.expand()
    }

    function collapse() {
        expandedBody.collapse()
    }
    property var activeDrone: null

    /*function populateActiveDroneModel(drone) {
        if (!drone) return;

        activeDrone = drone; // store reference to currently active drone

        // Update model
        activeDroneModel.clear();
    }*/
}

