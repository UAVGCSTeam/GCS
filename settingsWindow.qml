import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle
import "qrc:/components" as Components

/*
 * Settings Window - Application settings configuration
 * Categories are displayed on the left sidebar, settings content on the right.
 * Keyboard shortcuts:
 *   - Ctrl+. (Windows) / Cmd+. (Mac): Open settings
 *   - Escape: Close settings
 */

Window {
    id: settingsWindow
    width: 675
    height: 500
    minimumWidth: 600
    minimumHeight: 400
    title: "GCS Settings"
    // Standard window with title bar, minimize, maximize, and close buttons
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint | Qt.WindowCloseButtonHint

    // Track selected category
    property int selectedCategoryIndex: 0

    // Settings state - initialized from settingsManager 
    property int textSize: settingsManager.textSizeBase
    property string fontFamily: settingsManager.fontFamily 
    property string colorTheme: settingsManager.currentTheme
    property bool leaveAtLastMapLocation: settingsManager.leaveAtLastMapLocation
    property string homeLat: String(settingsManager.homeLat)
    property string homeLong: String(settingsManager.homeLong)

    // Category model
    ListModel {
        id: categoryModel
        ListElement { name: "Interface"}
        ListElement { name: "Startup Options"}
        ListElement { name: "Hotkeys"}
        ListElement { name: "Notifications"}
        ListElement { name: "Developer Settings"}
    }

    // Font options (cross-platform fonts available on Windows & Mac)
    ListModel {
        id: fontModel
        ListElement { name: "Arial" }
        ListElement { name: "Verdana" }
        ListElement { name: "Tahoma" }
        ListElement { name: "Georgia" }
        ListElement { name: "Trebuchet MS" }
        ListElement { name: "Courier New" }
    }

    // Text size options
    ListModel {
        id: sizeModel
        ListElement { value: 10; label: "10" }
        ListElement { value: 12; label: "12" }
        ListElement { value: 14; label: "14" }
        ListElement { value: 16; label: "16" }
        ListElement { value: 18; label: "18" }
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Escape"
        onActivated: settingsWindow.close()
    }

        // Track if there are unsaved changes
    property bool hasUnsavedChanges: {
        return textSize !== settingsManager.textSizeBase ||
               fontFamily !== settingsManager.fontFamily ||
               colorTheme !== settingsManager.currentTheme ||
               leaveAtLastMapLocation !== settingsManager.leaveAtLastMapLocation ||
               homeLat !== String(settingsManager.homeLat) ||
               homeLong !== String(settingsManager.homeLong)
    }

    // Main content
    Rectangle {
        id: windowBackground
        anchors.fill: parent
        color: GcsStyle.PanelStyle.primaryColor

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // Left sidebar with categories
            Rectangle {
                id: sidebar
                Layout.preferredWidth: 180
                Layout.fillHeight: true
                color: GcsStyle.PanelStyle.secondaryColor

                ColumnLayout {
                    anchors.fill: parent

                    // Category list
                    ListView {
                        id: categoryList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 8
                        clip: true
                        model: categoryModel
                        currentIndex: selectedCategoryIndex

                        delegate: Rectangle {
                            id: categoryDelegate
                            width: categoryList.width
                            height: 40
                            color: index === selectedCategoryIndex ? GcsStyle.PanelStyle.listItemSelectedColor
                                 : categoryMouseArea.containsMouse ? GcsStyle.PanelStyle.listItemHoverColor : "transparent"
                            
                            // Left accent bar for selected item
                            Rectangle {
                                width: 3
                                height: parent.height
                                color: index === selectedCategoryIndex ? GcsStyle.PanelStyle.buttonActiveColor : "transparent"
                                anchors.left: parent.left
                            }

                            Text {
                                text: model.name
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                font.family: GcsStyle.PanelStyle.fontFamily
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            MouseArea {
                                id: categoryMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: selectedCategoryIndex = index
                            }
                        }
                    }

                    // Spacer
                    Item {
                        Layout.fillHeight: true
                    }

                    // Save button at bottom
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: "transparent"

                        Button {
                            id: saveButton
                            text: "Save Settings"
                            anchors.centerIn: parent
                            width: parent.width - 24
                            height: 36

                            background: Rectangle {
                                color: saveButton.pressed ? GcsStyle.PanelStyle.buttonActiveColor
                                     : saveButton.hovered ? GcsStyle.PanelStyle.buttonHoverColor 
                                     : hasUnsavedChanges ? GcsStyle.PanelStyle.buttonActiveColor
                                     : GcsStyle.PanelStyle.buttonColor2
                                radius: GcsStyle.PanelStyle.buttonRadius
                                border.color: GcsStyle.PanelStyle.defaultBorderColor
                                border.width: GcsStyle.PanelStyle.defaultBorderWidth
                            }

                            contentItem: Text {
                                text: saveButton.text
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                font.family: GcsStyle.PanelStyle.fontFamily
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                // Save to settingsManager (save to disk)
                                settingsManager.currentTheme = colorTheme
                                settingsManager.textSizeBase = textSize
                                settingsManager.fontFamily = fontFamily
                                settingsManager.leaveAtLastMapLocation = leaveAtLastMapLocation
                                
                                // Only save coordinates if they're valid numbers
                                var latVal = parseFloat(homeLat)
                                var longVal = parseFloat(homeLong)
                                if (!isNaN(latVal) && !isNaN(longVal)) {
                                    settingsManager.homeLat = latVal
                                    settingsManager.homeLong = longVal
                                } else {
                                    console.warn("Invalid coordinates - keeping previous values")
                                }

                                // Update PanelStyle (for immediate UI update)
                                GcsStyle.PanelStyle.currentTheme = colorTheme
                                GcsStyle.PanelStyle.textSizeBase = textSize
                                GcsStyle.PanelStyle.fontFamily = fontFamily
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: GcsStyle.PanelStyle.defaultBorderColor
            }

            // Main content area
            Rectangle {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: GcsStyle.PanelStyle.primaryColor

                StackLayout {
                    id: settingsStack
                    anchors.fill: parent
                    anchors.margins: 24
                    currentIndex: selectedCategoryIndex

                    // ========== INTERFACE SETTINGS ==========
                    Item {
                        id: interfacePage

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 24

                            // Text Section
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 16

                                Text {
                                    text: "Text:"
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                    font.family: GcsStyle.PanelStyle.fontFamily
                                    font.weight: Font.Medium
                                }

                                // Size dropdown
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    Text {
                                        text: "Size"
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.preferredWidth: 80
                                    }

                                    Components.StyledComboBox {
                                        id: sizeCombo
                                        model: sizeModel
                                        textRole: "label"
                                        Layout.preferredWidth: 160
                                        // Find index where model value matches current setting so ComboBox displays correct size
                                        currentIndex: {
                                            for (var i = 0; i < sizeModel.count; i++) {
                                                if (sizeModel.get(i).value === textSize) return i
                                            }
                                            return 1 // default to 12
                                        }
                                        onActivated: textSize = sizeModel.get(currentIndex).value
                                    }
                                }

                                // Font dropdown
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    Text {
                                        text: "Font"
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.preferredWidth: 80
                                    }

                                    Components.StyledComboBox {
                                        id: fontCombo
                                        model: fontModel
                                        textRole: "name"
                                        Layout.preferredWidth: 160
                                        // Find index where model name matches current setting so ComboBox displays correct font
                                        currentIndex: {
                                            for (var i = 0; i < fontModel.count; i++) {
                                                if (fontModel.get(i).name === fontFamily) return i
                                            }
                                            return 0
                                        }
                                        onActivated: fontFamily = fontModel.get(currentIndex).name
                                    }
                                }

                                // Language dropdown (disabled)
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    Text {
                                        text: "Language"
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.preferredWidth: 80
                                    }

                                    ComboBox {
                                        id: languageCombo
                                        model: ["Not supported yet"]
                                        enabled: false
                                        Layout.preferredWidth: 160

                                        background: Rectangle {
                                            color: GcsStyle.PanelStyle.buttonUnavailableColor
                                            border.color: GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: 1
                                            radius: GcsStyle.PanelStyle.buttonRadius
                                            opacity: 0.6
                                        }

                                        contentItem: Text {
                                            text: languageCombo.displayText
                                            color: GcsStyle.PanelStyle.textSecondaryColor
                                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                            font.family: GcsStyle.PanelStyle.fontFamily
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 10
                                        }

                                        indicator: Text {
                                            text: "▼"
                                            color: GcsStyle.PanelStyle.textSecondaryColor
                                            font.pixelSize: 8
                                            anchors.right: parent.right
                                            anchors.rightMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }

                            // Colors Section
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                spacing: 16

                                Text {
                                    text: "Colors:"
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                    font.family: GcsStyle.PanelStyle.fontFamily
                                    font.weight: Font.Medium
                                }

                                // Theme toggle buttons (segmented control)
                                Rectangle {
                                    width: 210
                                    height: 36
                                    radius: GcsStyle.PanelStyle.buttonRadius
                                    color: GcsStyle.PanelStyle.secondaryColor
                                    border.color: GcsStyle.PanelStyle.defaultBorderColor
                                    border.width: 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 1

                                        // Dark button
                                        Rectangle {
                                            width: 69
                                            height: parent.height
                                            color: colorTheme === "dark" ? GcsStyle.PanelStyle.listItemSelectedColor
                                                 : darkMouse.containsMouse ? GcsStyle.PanelStyle.listItemHoverColor : "transparent"

                                            Text {
                                                text: "Dark"
                                                color: GcsStyle.PanelStyle.textPrimaryColor
                                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                                font.family: GcsStyle.PanelStyle.fontFamily
                                                anchors.centerIn: parent
                                            }
                                            MouseArea {
                                                id: darkMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: colorTheme = "dark"
                                            }
                                        }

                                        Rectangle { width: 1; height: parent.height; color: GcsStyle.PanelStyle.defaultBorderColor }

                                        // Light button
                                        Rectangle {
                                            width: 67
                                            height: parent.height
                                            color: colorTheme === "light" ? GcsStyle.PanelStyle.listItemSelectedColor
                                                 : lightMouse.containsMouse ? GcsStyle.PanelStyle.listItemHoverColor : "transparent"

                                            Text {
                                                text: "Light"
                                                color: GcsStyle.PanelStyle.textPrimaryColor
                                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                                font.family: GcsStyle.PanelStyle.fontFamily
                                                anchors.centerIn: parent
                                            }
                                            MouseArea {
                                                id: lightMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: colorTheme = "light"
                                            }
                                        }

                                        Rectangle { width: 1; height: parent.height; color: GcsStyle.PanelStyle.defaultBorderColor }

                                        // System button
                                        Rectangle {
                                            width: 69
                                            height: parent.height
                                            color: colorTheme === "system" ? GcsStyle.PanelStyle.listItemSelectedColor
                                                 : systemMouse.containsMouse ? GcsStyle.PanelStyle.listItemHoverColor : "transparent"

                                            Text {
                                                text: "System"
                                                color: GcsStyle.PanelStyle.textPrimaryColor
                                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                                font.family: GcsStyle.PanelStyle.fontFamily
                                                anchors.centerIn: parent
                                            }
                                            MouseArea {
                                                id: systemMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: colorTheme = "system"
                                            }
                                        }
                                    }
                                }
                            }

                            // Spacer
                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // ========== STARTUP OPTIONS ==========
                    Item {
                        id: startupPage

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 24

                            // Startup Options Section
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 16

                                Text {
                                    text: "Startup Options:"
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                    font.family: GcsStyle.PanelStyle.fontFamily
                                    font.weight: Font.Medium
                                }

                                // Leave at last map location checkbox
                                RowLayout {
                                    spacing: 12

                                    CheckBox {
                                        id: lastLocationCheckbox
                                        checked: leaveAtLastMapLocation

                                        indicator: Rectangle {
                                            width: 18
                                            height: 18
                                            radius: 3
                                            color: lastLocationCheckbox.checked 
                                                ? GcsStyle.PanelStyle.buttonActiveColor 
                                                : GcsStyle.PanelStyle.secondaryColor
                                            border.color: lastLocationCheckbox.checked 
                                                ? GcsStyle.PanelStyle.buttonActiveColor 
                                                : GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: 1

                                            Text {
                                                text: "✓"
                                                color: "white"
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                                anchors.centerIn: parent
                                                visible: lastLocationCheckbox.checked
                                            }
                                        }

                                        onCheckedChanged: leaveAtLastMapLocation = checked
                                    }

                                    ColumnLayout {
                                        spacing: 4

                                        Text {
                                            text: "Leave off at last map location"
                                            color: GcsStyle.PanelStyle.textPrimaryColor
                                            font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                            font.family: GcsStyle.PanelStyle.fontFamily
                                        }

                                        Text {
                                            text: leaveAtLastMapLocation 
                                                ? "Your application will reopen with the map at the last place your view was positioned."
                                                : "Your application will reopen at your set home location"
                                            color: GcsStyle.PanelStyle.textSecondaryColor
                                            font.pixelSize: GcsStyle.PanelStyle.fontSizeXXS
                                            font.family: GcsStyle.PanelStyle.fontFamily
                                            wrapMode: Text.WordWrap
                                            Layout.preferredWidth: 350
                                        }
                                    }
                                }
                            }

                            // Home Location Section
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 16
                                spacing: 16

                                Text {
                                    text: "Home Location:"
                                    color: GcsStyle.PanelStyle.textPrimaryColor
                                    font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                    font.family: GcsStyle.PanelStyle.fontFamily
                                    font.weight: Font.Medium
                                }

                                // Latitude input
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    Text {
                                        text: "Lat"
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.preferredWidth: 50
                                    }

                                    TextField {
                                        id: latField
                                        text: homeLat
                                        Layout.preferredWidth: 180

                                        background: Rectangle {
                                            color: GcsStyle.PanelStyle.secondaryColor
                                            border.color: latField.activeFocus 
                                                ? GcsStyle.PanelStyle.buttonActiveColor 
                                                : GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: 1
                                            radius: GcsStyle.PanelStyle.buttonRadius
                                        }

                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        leftPadding: 10
                                        selectByMouse: true

                                        onTextChanged: homeLat = text
                                    }
                                }

                                // Longitude input
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    Text {
                                        text: "Long"
                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        Layout.preferredWidth: 50
                                    }

                                    TextField {
                                        id: longField
                                        text: homeLong
                                        Layout.preferredWidth: 180

                                        background: Rectangle {
                                            color: GcsStyle.PanelStyle.secondaryColor
                                            border.color: longField.activeFocus 
                                                ? GcsStyle.PanelStyle.buttonActiveColor 
                                                : GcsStyle.PanelStyle.defaultBorderColor
                                            border.width: 1
                                            radius: GcsStyle.PanelStyle.buttonRadius
                                        }

                                        color: GcsStyle.PanelStyle.textPrimaryColor
                                        font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                        font.family: GcsStyle.PanelStyle.fontFamily
                                        leftPadding: 10
                                        selectByMouse: true

                                        onTextChanged: homeLong = text
                                    }
                                }
                            }

                            // Spacer
                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // ========== HOTKEYS (Empty) ==========
                    Item {
                        id: hotkeysPage

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 24

                            Text {
                                text: "Hotkeys"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                font.weight: Font.Medium
                            }

                            Text {
                                text: "Hotkey customization coming soon..."
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                font.family: GcsStyle.PanelStyle.fontFamily
                                font.italic: true
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // ========== NOTIFICATIONS (Empty) ==========
                    Item {
                        id: notificationsPage

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 24

                            Text {
                                text: "Notifications"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                font.weight: Font.Medium
                            }

                            Text {
                                text: "Notification settings coming soon..."
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                font.family: GcsStyle.PanelStyle.fontFamily
                                font.italic: true
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // ========== DEVELOPER SETTINGS (Empty) ==========
                    Item {
                        id: developerPage

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 24

                            Text {
                                text: "Developer Settings"
                                color: GcsStyle.PanelStyle.textPrimaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeMedium
                                font.family: GcsStyle.PanelStyle.fontFamily
                                font.weight: Font.Medium
                            }

                            Text {
                                text: "Developer options coming soon..."
                                color: GcsStyle.PanelStyle.textSecondaryColor
                                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                                font.family: GcsStyle.PanelStyle.fontFamily
                                font.italic: true
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }
                }
            }
        }
    }
}
