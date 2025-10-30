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
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true


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

                    Text {
                        text: "Commands"
                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
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
                Layout.topMargin: -30   //so the expanded/collapse view overlap and dont show ugly rounded corner
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
                    //animation.to = content.Layout.preferredHeight
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
                        name: "Connect"; category: "ground" //; destination:
                    }
                    ListElement {
                        name: "Arm Drone"; category: "ground"//; destination:
                    }
                    ListElement {
                        name: "Take Off"; category: "ground" //; destination:
                    }
                    ListElement {
                        name: "Waypointing"; category: "flight" //; destination:
                    }
                    ListElement {
                        name: "Go Home"; category: "flight" //; destination:
                    }
                    ListElement {
                        name: "Hover"; category: "flight" //; destination:
                    }
                }

                //sorts the element by category
                function categoryList(cat) {
                    var arr = []
                    for (var i = 0; i < repeaterModel.count; ++i) {
                        var e = repeaterModel.get(i)

                        if (e.category === cat) {
                            arr.push(e.name)
                        }
                    }
                    return arr
                }

                ColumnLayout {
                    id: content
                    Layout.fillWidth: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 5

                    Layout.preferredHeight: content.implicitHeight + 14

                    Item {
                        id: groundMenu
                        width: parent.width
                        Layout.topMargin: GcsStyle.PanelStyle.defaultMargin + 10
                        Layout.bottomMargin: GcsStyle.PanelStyle.defaultMargin
                        //Layout.topMargin: index === 0 ? 30 : 0 //adding padding above first button

                        property bool open: false

                        //collapse/expand ground panel
                        function expandGround() {
                            groundBody.expandGround()
                        }

                        function collapseGround() {
                            groundBody.collapseGround()
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Button {
                                id: groundHeaderButton
                                text: "Ground"
                                Layout.fillWidth: true
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium

                                background: Rectangle {
                                    border.width: 0.2
                                    radius: 1
                                }

                                onClicked: {
                                    if (groundMenu.open)
                                    {
                                        groundBody.collapseGroundAni()
                                    }
                                    else {
                                        groundBody.expandGroundAni()
                                    }
                                    groundMenu.open = !groundMenu.open
                                }
                            }

                            Rectangle {
                                id: groundBody
                                Layout.fillWidth: true
                                radius: GcsStyle.PanelStyle.cornerRadius
                                color: "transparent"
                                Layout.preferredHeight: 0   //start collapsed
                                clip: true

                                PropertyAnimation {
                                    id: animation2
                                    target: groundBody
                                    property: "Layout.preferredHeight"
                                    easing.type: Easing.InOutQuad
                                    duration: 500
                                }


                                function expandGroundAni() {
                                    animation2.to = groundContent.implicitHeight
                                    animation2.running = true
                                }

                                function collapseGroundAni() {
                                    animation2.to = 0
                                    animation2.running = true
                                }


                                ColumnLayout {
                                    id: groundContent
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                                    //width: parent.width
                                    spacing: 6

                                    Layout.preferredHeight: groundContent.implicitHeight + 14

                                    Repeater {
                                        model: expandedBody.categoryList("ground")
                                        delegate: Button {
                                            text: modelData
                                            Layout.fillWidth: true
                                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                            Layout.topMargin: index === 0 ? 20 : 0 //adding padding above first button

                                            background: Rectangle {
                                                border.width: 0.05
                                                radius: 1
                                            }

                                            onClicked: {
                                                console.log ("opening", text)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    /*Repeater {
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
                    }*/
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

