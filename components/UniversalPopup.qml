import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "qrc:/gcsStyle" as GcsStyle

/*
 * UniversalPopup - Reusable popup component for messages, notifications, and user prompts
 * Supports multiple variants: default, info, success, warning, error, confirm, destructive, custom
 * Can function as auto-closing notifications (top-right) or centered popups with action buttons
 * IMPORTANT: This component should be independent of its parents.
 * For main configurability: set popupVariant, popupTitle, popupMessage. Use onAccepted/onRejected to handle button actions. Enable/disable isNotification to switch between notification and popup mode.
 */
 
Popup {
    id: popup

    // ---------------------------------------------------------------------------
    // COMPONENT PROPERTIES - Set or override these when using the component
    // ---------------------------------------------------------------------------
    property string popupTitle: ""
    property string popupMessage: ""
    property string popupVariant: "default" // default | info | success | warning | error | confirm | destructive | custom
    property int popupWidth: isNotification ? 320 : 360
    property var buttons: undefined // Determined by popupVariant
    property bool isNotification: false     // Notification style: auto-closes, no buttons, positioned top-right
    property int notificationDuration: 3000 // Time in ms before notification fades out
    property int fadeDuration: 300          // Fade out animation duration in ms
    // Smart defaults: showDimOverlay is false for info/success or notifications, true for destructive/confirm/error/warning
    property bool showDimOverlay: !isNotification && (popupVariant === "destructive" || popupVariant === "confirm" || popupVariant === "error" || popupVariant === "warning")

    // ---------------------------------------------------------------------------
    // SIGNALS - Events emitted to parent components
    // ---------------------------------------------------------------------------
    signal buttonTriggered(string role)
    signal accepted()
    signal rejected()

    // ---------------------------------------------------------------------------
    // INTERNAL - Computed/derived values based on public properties
    // ---------------------------------------------------------------------------

    // Accent color for each variant (background color and text color are shared across all variants)
    readonly property var accentColors: ({
        "default":    GcsStyle.PanelStyle.popupDefaultAccent,
        info:         GcsStyle.PanelStyle.popupInfoAccent,
        success:      GcsStyle.PanelStyle.popupSuccessAccent,
        warning:      GcsStyle.PanelStyle.popupWarningAccent,
        error:        GcsStyle.PanelStyle.popupErrorAccent,
        confirm:      GcsStyle.PanelStyle.popupConfirmAccent,
        destructive:  GcsStyle.PanelStyle.popupDestructiveAccent,
        custom:       GcsStyle.PanelStyle.buttonActiveColor
    })

    // Selects the accent color based on popupVariant
    readonly property color activeAccent: accentColors[popupVariant] || accentColors["default"]

    // Selects the buttons based on popupVariant (notifications have no buttons by default)
    readonly property var resolvedButtons: buttons !== undefined ? buttons :
        isNotification ? [] :
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

    // Default icons per variant. Commented out for now for simplicity
    // readonly property var iconMap: ({
    //     info: "", success: "", warning: "qrc:/resources/warning.png",
    //     error: "", confirm: "", destructive: "qrc:/resources/delete.svg", custom: ""
    // })
    // readonly property url resolvedIconSource: iconMap[popupVariant] !== undefined ? iconMap[popupVariant] : ""

    // ---------------------------------------------------------------------------
    // POPUP CONFIGURATION - Built-in Popup settings
    // ---------------------------------------------------------------------------
    modal: false
    focus: true
    padding: isNotification ? 10 : 24  // Notifications are more compact
    width: popupWidth

    // Close policy based on variant:
    // - Notifications: no auto-close (waits for fade timer)
    // - Strict variants (destructive, confirm, error, warning): Escape only, must click a button
    // - Relaxed variants (info, success, default): Escape or click outside
    closePolicy: isNotification ? Popup.NoAutoClose :
        (popupVariant === "destructive" || popupVariant === "confirm" || popupVariant === "error" || popupVariant === "warning")
            ? Popup.CloseOnEscape
            : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)

    // Smart positioning: notifications -> top-right, others -> center
    parent: Overlay.overlay
    x: isNotification
        ? parent.width - width - 20                                                            // Top-right with margin
        : (parent.width - width) / 2                                                           // Centered
    y: isNotification
        ? GcsStyle.PanelStyle.menuBarHeight + GcsStyle.PanelStyle.applicationBorderMargin      // Aligns with DroneTrackingPanel
        : (parent.height - height) / 2                                                         // Centered

    // ---------------------------------------------------------------------------
    // HELPER FUNCTIONS
    // ---------------------------------------------------------------------------

    // Returns the button background color based on state (highlighted, hovered)
    function buttonBackgroundColor(button) {
        if (button.highlighted) {
            if (button.hovered)
                return Qt.lighter(activeAccent, 1.15)
            return activeAccent
        }
        if (button.hovered)
            return GcsStyle.PanelStyle.buttonHoverColor
        return GcsStyle.PanelStyle.buttonColor2
    }

    // ---------------------------------------------------------------------------
    // ANIMATIONS & TIMERS
    // ---------------------------------------------------------------------------
    
    // Auto-close timer for notifications
    Timer {
        id: notificationTimer
        interval: popup.notificationDuration
        running: popup.opened && popup.isNotification
        onTriggered: fadeOutAnimation.start()
    }

    // Fade out animation before closing (used by notifications)
    NumberAnimation {
        id: fadeOutAnimation
        target: popup
        property: "opacity"
        to: 0
        duration: popup.fadeDuration
        onFinished: {
            popup.close()
            popup.opacity = 1  // Reset for next open
        }
    }

    // Slide-in animation for notifications (from right edge)
    NumberAnimation {
        id: slideInAnimation
        target: popup
        property: "x"
        from: parent.width
        to: parent.width - popup.width - 20
        duration: 400
        easing.type: Easing.OutCubic
    }

    // Pulse animation to draw attention when clicking outside non-dismissible popup
    SequentialAnimation {
        id: pulseAnimation
        NumberAnimation { target: popup; property: "scale"; to: 1.03; duration: 80 }
        NumberAnimation { target: popup; property: "scale"; to: 1.0; duration: 80 }
    }

    // ---------------------------------------------------------------------------
    // EVENT HANDLERS
    // ---------------------------------------------------------------------------

    // When popup opens: reset opacity (in case previous fade), play slide-in for notifications
    onOpened: {
        opacity = 1
        if (isNotification) {
            slideInAnimation.start()
        }
    }

    // ---------------------------------------------------------------------------
    // VISUAL COMPONENTS
    // ---------------------------------------------------------------------------

    // Dim overlay that darkens background when popup is open (only for strict variants)
    Loader {
        id: dimOverlayLoader
        active: popup.opened && popup.showDimOverlay
        sourceComponent: Rectangle {
            parent: Overlay.overlay
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
            z: -1  // Puts overlay behind the popup

            // Clicking the dim overlay triggers pulse animation
            MouseArea {
                anchors.fill: parent
                onClicked: pulseAnimation.start()
            }
        }
    }

    // Visual frame of the popup. Rounded card with accent border (no border for notifications)
    background: Rectangle {
        color: popup.isNotification
            ? Qt.rgba(GcsStyle.PanelStyle.primaryColor.r, GcsStyle.PanelStyle.primaryColor.g, GcsStyle.PanelStyle.primaryColor.b, 0.75)
            : GcsStyle.PanelStyle.primaryColor
        border.color: popup.isNotification ? "transparent" : popup.activeAccent
        border.width: popup.isNotification ? 0 : 1
        radius: GcsStyle.PanelStyle.cornerRadius
        clip: true  // Clips children to the rounded shape

        // Accent bar on the left edge for notifications.
        // Uses two overlapping rectangles to achieve left-side-only rounded corners:
        //   1. A fully rounded rectangle (all 4 corners)
        //   2. A square rectangle on the right half to mask the right rounded corners
        Item {
            visible: popup.isNotification
            width: GcsStyle.PanelStyle.cornerRadius + 4
            height: parent.height

            Rectangle {
                anchors.fill: parent
                color: popup.activeAccent
                radius: GcsStyle.PanelStyle.cornerRadius
            }
            Rectangle {
                width: parent.width / 2 + 2
                height: parent.height
                anchors.right: parent.right
                color: popup.activeAccent
            }
        }
    }

    // Main content layout
    contentItem: Item {
        implicitWidth: popup.popupWidth
        implicitHeight: column.implicitHeight + popup.padding * 2

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.leftMargin: popup.padding
            anchors.rightMargin: popup.padding
            anchors.topMargin: popup.padding + (isNotification ? 5 : 0)
            anchors.bottomMargin: popup.padding
            spacing: isNotification ? 10 : 14

            // Header row with title
            RowLayout {
                id: headerRow
                visible: popupTitle.length > 0
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                // Variant icon (commented out for now)
                // Image {
                //     source: resolvedIconSource
                //     width: GcsStyle.PanelStyle.iconSize
                //     height: GcsStyle.PanelStyle.iconSize
                //     fillMode: Image.PreserveAspectFit
                // }

                Label {
                    text: popupTitle
                    font.pixelSize: GcsStyle.PanelStyle.headerFontSize
                    color: GcsStyle.PanelStyle.textPrimaryColor
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Message body
            Label {
                text: popupMessage
                visible: popupMessage.length > 0
                color: GcsStyle.PanelStyle.textPrimaryColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font.pixelSize: GcsStyle.PanelStyle.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
            }

            // Button row
            RowLayout {
                id: buttonRow
                spacing: 12
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8

                Repeater {
                    model: popup.resolvedButtons
                    delegate: Button {
                        text: modelData.text
                        highlighted: modelData.accent === true
                        Layout.preferredWidth: modelData.fillWidth === true ? -1 : 110
                        Layout.fillWidth: modelData.fillWidth === true

                        background: Rectangle {
                            radius: GcsStyle.PanelStyle.buttonRadius
                            color: popup.buttonBackgroundColor(parent)
                            border.color: parent.highlighted
                                ? Qt.tint(popup.activeAccent, Qt.rgba(1, 1, 1, 0.25))
                                : GcsStyle.PanelStyle.defaultBorderColor
                            border.width: 1
                        }

                        contentItem: Label {
                            text: parent.text
                            color: GcsStyle.PanelStyle.textPrimaryColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Call custom onTrigger function if defined
                            if (typeof modelData.onTrigger === "function") {
                                modelData.onTrigger()
                            }

                            const role = (modelData.role || "").toString()
                            popup.buttonTriggered(role)

                            // Emit accept/reject signals for common roles
                            const normalizedRole = role.toLowerCase()
                            if (normalizedRole === "accept") {
                                popup.accepted()
                            } else if (normalizedRole === "reject") {
                                popup.rejected()
                            }

                            // Close popup unless button specifies closesOnTrigger: false
                            if (modelData.closesOnTrigger !== false) {
                                popup.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
