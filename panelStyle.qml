pragma Singleton
import QtQuick 2.15

QtObject {
    // Color scheme
    readonly property color primaryColor: "#FFF9FB"
    readonly property color secondaryColor: "#ffffff"
    readonly property color accentColor: "#007bff"
    readonly property color textPrimaryColor: "#333333"
    readonly property color textSecondaryColor: "#666666"

    // Sizes
    readonly property int sidebarWidth: 50
    readonly property int headerHeight: 50
    readonly property int itemHeight: 50
    readonly property int cornerRadius: 10

    // Font sizes
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeMedium: 16
    readonly property int fontSizeSmall: 12
    readonly property int menuBarFontSize: 10

    // Temporary Icons
    readonly property string droneIcon: "🚁"
    readonly property string settingsIcon: "⚙️"

    // Button properties
    readonly property int buttonSize: 40
    readonly property int buttonRadius: 8
    readonly property color buttonColor: "transparent"
    readonly property color buttonActiveColor: "#4B88A2"
    readonly property color buttonHoverColor: "#e6f0ff"
    readonly property color buttonPressedColor: "#cfe0ff"
    readonly property color buttonBorderColor: "#c8c8c8"

    // List view properties
    readonly property color listItemEvenColor: secondaryColor
    readonly property color listItemOddColor: "#FFF9FB"
    readonly property int listItemHeight: 50

    // Margin and spacing
    readonly property int defaultMargin: 10
    readonly property int applicationBorderMargin: 20
    readonly property int defaultSpacing: 10
    readonly property int leftButtonSpacing: 0
    readonly property double iconRightMargin: 7.8
    readonly property int sidebarTopMargin: 100
    readonly property double buttonSpacing: 5

    // Icon properties
    readonly property int iconSize: 24
    readonly property int statusIconSize: 15

    // Text colors for different backgrounds
    readonly property color textOnPrimaryColor: "#000000"
    readonly property color textOnSecondaryColor: textPrimaryColor

    // Header-specific properties
    readonly property int headerFontSize: 18
    readonly property int subHeaderFontSize: 12

    // Battery indicator colors
    readonly property color batteryHighColor: "#4CAF50"
    readonly property color batteryMediumColor: "#FFC107"
    readonly property color batteryLowColor: "#F44336"

    // Status colors
    readonly property color statusFlyingColor: "#4CAF50"
    readonly property color statusIdleColor: "#FFC107"
    readonly property color statusChargingColor: "#2196F3"

    Component.onCompleted: console.log("PanelStyle loaded")
}
