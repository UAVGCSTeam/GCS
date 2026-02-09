pragma Singleton
import QtQuick 2.15

QtObject {
    // Theme state - bound to settingsManager
    property string currentTheme: settingsManager ? settingsManager.currentTheme : "dark"
    readonly property bool isLightTheme: currentTheme === "light" 

    // Text size state - bound to settingsManager
    property int textSizeBase: settingsManager ? settingsManager.textSizeBase : 12

    // Font family state - bound to settingsManager
    property string fontFamily: settingsManager ? settingsManager.fontFamily : "Arial"

    // Color scheme
    readonly property color listItemHoverColor: isLightTheme ? "#D1D1D6" : "#384250"     // light silver, blue-grey slate
    readonly property color listItemSelectedColor: isLightTheme ? "#C7D2E8" : "#495B76"  // soft blue-grey, muted steel blue
    readonly property color primaryColor: isLightTheme ? "#FDF6F6" : "#161720"           // subtle warm pink white, dark navy
    readonly property color secondaryColor: isLightTheme ? "#E8E8ED" : "#282831"         // light grey, charcoal
    readonly property color accentColor: "#007bff"                                       // bright blue
    readonly property color textPrimaryColor: isLightTheme ? "#1D1D1F" : "#ffffff"       // black, white
    readonly property color textSecondaryColor: isLightTheme ? "#86868B" : "#666666"     // medium grey, dark grey

    // Sizes
    readonly property int sidebarWidth: 50
    readonly property int headerHeight: 50
    readonly property int menuBarHeight: 30
    readonly property int itemHeight: 50
    readonly property int cornerRadius: 10

    // Font sizes (computed from textSizeBase)
    readonly property int fontSizeLarge: textSizeBase + 6 //18 default value
    readonly property int fontSizeMedium: textSizeBase + 4 //16 default value
    readonly property int fontSizeSmall: textSizeBase //12 default value
    readonly property int fontSizeXS: textSizeBase - 2 //10 default value
    readonly property int fontSizeXXS: textSizeBase - 2 //10 default value

    // Button properties
    readonly property int buttonSize: 40
    readonly property int buttonRadius: 6
    readonly property color buttonColor: "transparent"
    readonly property color buttonColor2: isLightTheme ? "#DCDCE2" : "#282830"           // pale grey, charcoal
    readonly property color buttonActiveColor: "#4B88A2"                                  // teal blue
    readonly property color buttonHoverColor: isLightTheme ? "#C5C5CC" : "#364357"       // silver, slate blue
    readonly property color buttonPressedColor: listItemHoverColor
    readonly property color buttonUnavailableColor: isLightTheme ? "#E5E5EA" : "#212129" // light grey, dark charcoal
    readonly property color buttonBorderColor: isLightTheme ? "#B0B0B5" : "#c8c8c8"      // grey, light grey
    
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
    readonly property color listItemOddColor: isLightTheme ? "#EBEBF0" : "#202029"       // light grey, dark grey
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
    readonly property color defaultBorderColor: isLightTheme ? "#C5C5CC" : "#515151"     // silver, medium grey

    // Icon properties
    readonly property int iconSize: 24
    readonly property int statusIconSize: 15

    // Text colors for different backgrounds
    readonly property color textOnPrimaryColor: isLightTheme ? "#1D1D1F" : "#ffffff"     // near-black, white
    readonly property color textOnSecondaryColor: textPrimaryColor

    // Header-specific properties (scale with textSizeBase)
    readonly property int headerFontSize: textSizeBase + 6 //18 default value
    readonly property int subHeaderFontSize: textSizeBase // 12 default value

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
