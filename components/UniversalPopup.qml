import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle

Popup {
    id: popup
    property string popupTitle: ""
    property string popupMessage: ""
    property string popupVariant: "info" // info | success | warning | error | confirm | destructive | custom
    property int popupWidth: 360
    property bool autoCloseOnAction: true
    property var buttons: undefined

    signal buttonTriggered(string role)
    signal accepted()
    signal rejected()

    modal: true
    focus: true
    padding: 24
    width: popupWidth
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    readonly property var palette: ({
    info: {
        bg:    GcsStyle.PanelStyle.primaryColor,
        border:GcsStyle.PanelStyle.defaultBorderColor,
        text:  GcsStyle.PanelStyle.textPrimaryColor,
        accent:GcsStyle.PanelStyle.buttonActiveColor
    },
    success: {
        bg:    GcsStyle.PanelStyle.primaryColor,
        border:GcsStyle.PanelStyle.defaultBorderColor,
        text:  GcsStyle.PanelStyle.textPrimaryColor,
        accent:GcsStyle.PanelStyle.statusFlyingColor
    },
    warning: {
        bg:    GcsStyle.PanelStyle.primaryColor,
        border:GcsStyle.PanelStyle.defaultBorderColor,
        text:  GcsStyle.PanelStyle.textPrimaryColor,
        accent:GcsStyle.PanelStyle.statusIdleColor
    },
    error: {
        bg:    GcsStyle.PanelStyle.primaryColor,
        border:GcsStyle.PanelStyle.buttonDangerColor,
        text:  GcsStyle.PanelStyle.defaultBorderColor,
        accent:GcsStyle.PanelStyle.buttonDangerColor
    },
    confirm: {
        bg:    GcsStyle.PanelStyle.primaryColor,
        border:GcsStyle.PanelStyle.defaultBorderColor,
        text:  GcsStyle.PanelStyle.textPrimaryColor,
        accent:GcsStyle.PanelStyle.buttonActiveColor
    },
    destructive: {
        bg:    GcsStyle.PanelStyle.primaryColor,
        border:GcsStyle.PanelStyle.defaultBorderColor,
        text:  GcsStyle.PanelStyle.textPrimaryColor,
        accent:GcsStyle.PanelStyle.buttonDangerColor
    },
    custom:  {
        bg:    GcsStyle.PanelStyle.primaryColor,
        border:GcsStyle.PanelStyle.defaultBorderColor,
        text:  GcsStyle.PanelStyle.textPrimaryColor,
        accent:GcsStyle.PanelStyle.buttonActiveColor
    }
})

    readonly property var activePalette: palette[popupVariant] !== undefined ? palette[popupVariant] : palette.info

    // Default icons per variant
    readonly property var iconMap: ({
        info: "",
        success: "",
        warning: "qrc:/resources/warning.png",
        error: "",
        confirm: "",
        destructive: "qrc:/resources/delete.svg",
        custom: ""
    })

    // Resolve the icon source based on the popup variant
    readonly property url resolvedIconSource: iconMap[popupVariant] !== undefined ? iconMap[popupVariant] : ""

    // Resolve the buttons based on the popup variant
    readonly property var resolvedButtons: buttons !== undefined ? buttons :
        popupVariant === "confirm" ? [
            { text: qsTr("No"), role: "reject" },
            { text: qsTr("Yes"), role: "accept", accent: true }
        ] :
        popupVariant === "destructive" ? [
            { text: qsTr("Cancel"), role: "reject", fillWidth: true },
            { text: qsTr("Delete"), role: "accept", accent: true, fillWidth: true }
        ] :
        [
            { text: qsTr("OK"), role: "accept", accent: true }
        ]

    function buttonBackgroundColor(button) {
        if (button.highlighted) {
            if (button.hovered)
                return Qt.lighter(activePalette.accent, 1.15)
            return activePalette.accent
        }
        if (button.hovered)
            return GcsStyle.PanelStyle.buttonHoverColor
        return GcsStyle.PanelStyle.buttonColor2
    }

    // Visual frame of the popup. Rounded card with border
    background: Rectangle {
        color: popup.activePalette.bg
        border.color: popup.activePalette.border
        border.width: 1
        radius: GcsStyle.PanelStyle.cornerRadius
    }

    // Content of the popup
    contentItem: Item {
        implicitWidth: popup.popupWidth
        implicitHeight: column.implicitHeight + popup.padding * 2

        // Main vertical layout of the popup
        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.leftMargin: popup.padding
            anchors.rightMargin: popup.padding
            anchors.topMargin: popup.padding
            anchors.bottomMargin: popup.padding
            spacing: 16

            // Header row of the popup. Contains the icon and title.
            RowLayout {
                id: headerRow
                visible: resolvedIconSource !== "" || popupTitle.length > 0
                Layout.alignment: Qt.AlignHCenter 
                spacing: 8

                // Variant based icon of the popup 
                Image {
                    source: resolvedIconSource
                    width: GcsStyle.PanelStyle.iconSize
                    height: GcsStyle.PanelStyle.iconSize
                    fillMode: Image.PreserveAspectFit
                }

                // Title text of the popup
                Label {
                    text: popupTitle
                    visible: popupTitle.length > 0
                    font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                    font.bold: true
                    color: popup.activePalette.text
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter

                }
            }

            // Main message body text
            Label {
                text: popupMessage
                visible: popupMessage.length > 0
                color: popup.activePalette.text
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
            }

            // Button row of the popup 
            RowLayout {
                id: buttonRow
                spacing: 12
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                // Dynamically create one button per entry in resolvedButtons
                Repeater {
                    model: popup.resolvedButtons
                    delegate: Button {
                        text: modelData.text
                        // highlighted primpary action button gets accent colored background
                        highlighted: modelData.accent === true
                        // Default width of button is 110 if fillwidth is false 
                        Layout.preferredWidth: modelData.fillWidth === true ? undefined : 110
                        Layout.fillWidth: modelData.fillWidth === true

                        // Visual style of the button background
                        background: Rectangle {
                            radius: GcsStyle.PanelStyle.buttonRadius
                            color: popup.buttonBackgroundColor(parent)
                            // Accent border for highlighted buttons or neutral border otherwise
                            border.color: parent.highlighted
                                             ? Qt.tint(popup.activePalette.accent, Qt.rgba(1, 1, 1, 0.25))
                                             : GcsStyle.PanelStyle.defaultBorderColor
                            border.width: 1
                        }

                        // Visual style of button text
                        contentItem: Label {
                            text: parent.text
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Click handler for button
                        onClicked: { 

                            // Call the onTrigger custom function if it is defined
                            if (typeof modelData.onTrigger === "function") {
                                modelData.onTrigger()
                            }
                            // Get the role of the button
                            const role = (modelData.role || "").toString()

                           // Emit signal for parent to handle custom behavior
                            popup.buttonTriggered(role)

                            // Normalize the role to lowercase
                            const normalizedRole = role.toLowerCase()

                            // Special handling for common roles of buttons
                            if (normalizedRole === "accept") {
                                popup.accepted()
                            } else if (normalizedRole === "reject") {
                                popup.rejected()
                            }

                            // Auto close unless otherwise specified
                            const shouldClose = modelData.closesOnTrigger !== false && popup.autoCloseOnAction
                            if (shouldClose) {
                                popup.close()
                            }
                        }
                    }
                }
            }
        }
    }
}

