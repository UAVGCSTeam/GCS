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
                Layout.fillWidth: true
                height: GcsStyle.PanelStyle.headerHeight + 15
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true

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

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height / 2
                    color: parent.color
                }

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 0

                    Text {
                        id: droneNameText
                        text: activeDrone ? activeDrone.name: ""
                        font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                    }

                    Text {
                        text: "Commands"
                        font.pixelSize: GcsStyle.PanelStyle.headerFontSize - 5
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                    }
                }
            }
            //expanded form
            Rectangle {
                id: expandedBody
                Layout.fillWidth: true

                height: 0
                opacity: height > 0 ? 1 : 0
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

                ColumnLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 5

                    Layout.preferredHeight: 200

                    RowLayout {
                        Layout.fillWidth:true
                        spacing: 8

                        Button {
                            text: "test"
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

