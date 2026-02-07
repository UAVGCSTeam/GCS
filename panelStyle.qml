pragma Singleton
import QtQuick 2.15

QtObject {
    // Color scheme
    readonly property color listItemHoverColor: "#384250"
    readonly property color listItemSelectedColor: "#495B76"
    readonly property color primaryColor: "#161720"
    readonly property color secondaryColor: "#282831"
    readonly property color accentColor: "#007bff"
    readonly property color textPrimaryColor: "#ffffff"
    readonly property color textSecondaryColor: "#666666"

    // Sizes
    readonly property int sidebarWidth: 50
    readonly property int headerHeight: 50
    readonly property int menuBarHeight: 30
    readonly property int itemHeight: 50
    readonly property int cornerRadius: 10

    // Font sizes
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeMedium: 16
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeXS: 10
    readonly property int fontSizeXXS: 10

    // Button properties
    readonly property int buttonSize: 40
    readonly property int buttonRadius: 6
    readonly property color buttonColor: "transparent"
    readonly property color buttonColor2: "#282830"
    readonly property color buttonActiveColor: "#4B88A2"
    readonly property color buttonHoverColor: "#364357"
    readonly property color buttonPressedColor: listItemHoverColor
    readonly property color buttonUnavailableColor: "#212129"
    readonly property color buttonBorderColor: "#c8c8c8"
    
    // Danger/warning button colors
    readonly property color buttonDangerColor: "#c62828"
    readonly property color buttonDangerHoverColor: "#ff8e8e"
    readonly property color buttonDangerTextColor: "#ffffff"

    // Popup variant accent colors
    readonly property color popupDefaultAccent: buttonColor2  
    readonly property color popupInfoAccent: "#4B88A2"       // Teal
    readonly property color popupSuccessAccent: "#3d7a3d"    // Green 
    readonly property color popupWarningAccent: "#C99409"    // Yellow/amber 
    readonly property color popupErrorAccent: "#a32222"      // Red 
    readonly property color popupConfirmAccent: "#4B88A2"    // Teal 
    readonly property color popupDestructiveAccent: "#a32222" // Red 

    // List view properties
    readonly property color listItemEvenColor: primaryColor
    readonly property color listItemOddColor: "#202029"
    readonly property int listItemHeight: 40

    // Command Menu
    readonly property int commandButtonHeight: 18

    // Margin and spacing
    readonly property int defaultMargin: 10
    readonly property int applicationBorderMargin: 8
    readonly property int applicationBorderMarginBottom: 20
    readonly property int defaultSpacing: 10
    readonly property int leftButtonSpacing: 0
    readonly property double iconRightMargin: 7.8
    readonly property int sidebarTopMargin: 100
    readonly property double buttonSpacing: 5

    // Borders 
    readonly property double defaultBorderWidth: 0.5
    // readonly property color defaultBorderColor: "lightgray"
    readonly property color defaultBorderColor: "#515151"
    // readonly property color defaultBorderColor: "red"

    // Icon properties
    readonly property int iconSize: 24
    readonly property int statusIconSize: 15

    // Text colors for different backgrounds
    // readonly property color textOnPrimaryColor: "#000000"
    readonly property color textOnPrimaryColor: "#ffffff"
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

    // Command Panel drone colors
    readonly property color commandAvailable: textPrimaryColor
    readonly property color commandInProgress: "#FFC107"
    readonly property color commandNotAvailable: textSecondaryColor

    Component.onCompleted: console.log("PanelStyle loaded")
}
