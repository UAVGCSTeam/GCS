import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "qrc:/gcsStyle" as GcsStyle


Rectangle {
    id: mainPanel
    width: 300
    height: 600
    color: GcsStyle.PanelStyle.primaryColor
    radius: GcsStyle.PanelStyle.cornerRadius


    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Right view
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                height: GcsStyle.PanelStyle.headerHeight
                color: GcsStyle.PanelStyle.primaryColor
                radius: GcsStyle.PanelStyle.cornerRadius
                clip: true

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height / 2
                    color: parent.color
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: GcsStyle.PanelStyle.defaultMargin
                    spacing: 0

                    Text {
                        text: "Drone Status"
                        font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                        color: GcsStyle.PanelStyle.textOnPrimaryColor
                    }
                }
            }

            ListModel {
                id: activeDroneModel
            }

            ListView {
                id: droneListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: true
                model: activeDroneModel

                delegate: Rectangle {
                    width: parent.width
                    height: GcsStyle.PanelStyle.listItemHeight

                    ColumnLayout {
                        anchors.fill: parent
                        Layout.fillWidth: true
                        anchors.margins: 20
                        spacing: 20

                        Text {
                            text: name
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: status
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        Text {
                            text: battery + "%"
                            color: battery > 70 ? GcsStyle.PanelStyle.batteryHighColor :
                                                  battery > 30 ? GcsStyle.PanelStyle.batteryMediumColor :
                                                                 GcsStyle.PanelStyle.batteryLowColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                        }
                        
                        // Button 1: Liftoff
                        Button {
                            id: liftoffButton
                            text: "Liftoff"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#DCDCDC"
                                radius: 10
                            }
                            onClicked: {
                                enterAltitude.open()
                            }
                        }
                        Dialog {
                            id: enterAltitude
                            title: "Drone Liftoff"
                            standardButtons: Dialog.Cancel
                            Column {
                                    spacing: 20
                                    padding: 20

                                    Text {
                                        id: altitudePrompt
                                        text: "Please enter a target altitude"
                                        wrapMode: Text.Wrap
                                    }

                                    TextField {
                                        id: desiredAltitude
                                        placeholderText: "Drone Target Altitude"
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    }
                                    Row {
                                        spacing: 20
                                        Button {
                                            text: "Enter"
                                            onClicked: {
                                                let inputAltitude = parseFloat(desiredAltitude.text);
                                                // Check if altitude is a number & greater than 0
                                                if (!isNaN(inputAltitude) && inputAltitude > 0) {
                                                    liftoffButton.enabled = false;
                                                    returnHomeButton.enabled = true;
                                                    targetAltitudeText.text = "Target Altitude: " + inputAltitude + " m";
                                                    targetAltitudeText.visible = true;


                                                    console.log("liftoff") // User command: liftoff goes here for drone


                                                    enterAltitude.close();
                                                } else {
                                                    altitudePrompt.text = "ERROR: Please enter a valid number.";
                                                }
                                            }
                                        }
                                    }
                                }   
                            } 

                        // Button 2: View Flight Telemetry
                        Button {
                            id: flightDetails
                            text: "Check Flight Details"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#DCDCDC"
                                radius: 10
                            }

                            // Works as a toggle; button turns the text details on/off
                            onClicked: {
                                if (flightDetails.text == "Check Flight Details") {
                                    latitudeText.visible = true;
                                    longitudeText.visible = true;
                                    altitudeText.visible = true;
                                    flightDetails.text = "Close Flight Details";
                                }
                                else {
                                    latitudeText.visible = false;
                                    longitudeText.visible = false;
                                    altitudeText.visible = false;
                                    flightDetails.text = "Check Flight Details";                                    
                                }

                                console.log("data") // User command: data goes here
                                //activeDroneModel.append(getStatus());
                                /*
                                Define getStatus as a method (return latitude, longitude, altitude, and role ?)
                                */
                            }
                        }

                        // Button 3: Return drone to home
                        Button {
                            id: returnHomeButton
                            text: "Return Home"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#DCDCDC"
                                radius: 10
                            }
                            enabled: false
                            onClicked: {
                                returnHomeButton.enabled = false;
                                liftoffButton.enabled = true;
                                console.log("Return home") // User command: return home goes here
                                targetAltitudeText.text = "Returning to home...";

                                /*if (activeDroneModel.altitude = 0) {
                                    targetAltitudeText.visible = false
                                }
                                Can implement functionality if needed
                                */
                            }
                        }
                        Text {
                            id: targetAltitudeText
                            text: "Target Altitude: "
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            visible: false
                        }

                        Text {
                            id: latitudeText
                            text: "Latitude: " // + latitude <- from user command
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            visible: false
                        }
                        Text {
                            id: longitudeText
                            text: "Longitude: " // + longitude <- from user command
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            visible: false
                        }
                        Text {
                            id: altitudeText
                            text: "Altitude: " // + altitude <- from user command
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                            visible: false
                        }
                    }
                } 
            }
        }
    }

    Connections {
        target: droneTrackingPanel
        onUpdateSelectedDroneSignal: populateActiveDroneModel(name, status, battery)
    }

    // In this future this would be updated by a pointer: (drone1 -> activeDrone)
    function populateActiveDroneModel(name, status, battery) {
        activeDroneModel.clear()
        activeDroneModel.append({ name: name,
                                    status: status,
                                    battery: battery
                                })
    }
}