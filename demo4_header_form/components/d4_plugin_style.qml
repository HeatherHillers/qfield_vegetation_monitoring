import QtQuick

// Centralized style definitions for the vegetation monitoring plugin
// Similar to CSS, this defines all visual styling in one place
QtObject {
    id: pluginStyle
    
    // ===== COLOR PALETTE =====
    readonly property color primaryBackground: "#ffecd1"    // Light cream
    readonly property color primaryText: "#6baa75"          // Asparagus
    readonly property color secondaryBackground: "#6baa75"   // Asparagus
    readonly property color secondaryText: "#ffffff"        // White    
    readonly property color tertiaryBackground: "#333333"  // Dark gray
    readonly property color tertiaryText: "#ffffff"         // White text on dark background
    readonly property color accentColor: "#2E7D32"         // Dark green
    readonly property color warningColor: "#FF9800"        // Orange
    readonly property color errorColor: "#F44336"          // Red
    readonly property color successColor: "#4CAF50"        // Light green
    readonly property color borderColor: "#cccccc"         // Light gray
    readonly property color formBorderColor: "#999999"     // Medium gray
    readonly property color labelColor: "#333333"          // Dark gray
    readonly property color inputBackground: "#ffffff"     // White
    readonly property color buttonHover: "#1B5E20"        // Very dark green
    
    // ===== TYPOGRAPHY =====
    readonly property string fontFamily: "Arial"
    readonly property int fontSizeTitle: 24
    readonly property int fontSizeSubtitle: 20
    readonly property int fontSizeNormal: 16
    readonly property int fontSizeSmall: 14
    readonly property int fontSizeLarge: 18
    readonly property bool fontBoldDefault: false
    readonly property bool fontBoldTitles: true
    
    // ===== SPACING & SIZING =====
    readonly property int spacingTiny: 5
    readonly property int spacingSmall: 10
    readonly property int spacingMedium: 15
    readonly property int spacingLarge: 20
    readonly property int spacingHuge: 30
    
    readonly property int borderRadius: 5
    readonly property int borderWidth: 1
    readonly property int borderWidthThick: 2
    
    readonly property int buttonHeight: 40
    readonly property int inputHeight: 35
    readonly property int headerHeight: 60
    readonly property int searchBarHeight: 100
    
    // ===== COMPONENT-SPECIFIC STYLES =====
    
    // Button styles
    readonly property QtObject button: QtObject {
        readonly property color background: pluginStyle.accentColor
        readonly property color backgroundHover: pluginStyle.buttonHover
        readonly property color backgroundDisabled: pluginStyle.borderColor
        readonly property color text: "#ffffff"
        readonly property color textDisabled: "#666666"
        readonly property int fontSize: pluginStyle.fontSizeNormal
        readonly property bool fontBold: true
        readonly property int borderRadius: pluginStyle.borderRadius
        readonly property int height: pluginStyle.buttonHeight
        readonly property int padding: pluginStyle.spacingSmall
    }
    
    // Save button specific styles
    readonly property QtObject saveButton: QtObject {
        readonly property color backgroundSaved: pluginStyle.buttonHover
        readonly property color backgroundUnsaved: pluginStyle.accentColor
        readonly property color text: "#ffffff"
        readonly property int fontSize: 20
        readonly property bool fontBold: true
        readonly property int borderRadius: 10
    }
    
    // Form field styles
    readonly property QtObject formField: QtObject {
        readonly property color labelColor: pluginStyle.labelColor
        readonly property int labelFontSize: pluginStyle.fontSizeNormal
        readonly property string labelFontFamily: pluginStyle.fontFamily
        readonly property bool labelFontBold: pluginStyle.fontBoldDefault
        readonly property color inputBackground: pluginStyle.inputBackground
        readonly property color inputBorder: pluginStyle.borderColor
        readonly property int inputHeight: pluginStyle.inputHeight
        readonly property int spacing: pluginStyle.spacingSmall
        readonly property int borderRadius: pluginStyle.borderRadius
    }
    
    // Group box styles
    readonly property QtObject groupBox: QtObject {
        readonly property color background: pluginStyle.primaryBackground
        readonly property color border: pluginStyle.formBorderColor
        readonly property int borderWidth: pluginStyle.borderWidth
        readonly property int borderRadius: pluginStyle.borderRadius
        readonly property color titleColor: pluginStyle.labelColor
        readonly property int titleFontSize: pluginStyle.fontSizeSubtitle
        readonly property bool titleFontBold: pluginStyle.fontBoldTitles
        readonly property int padding: pluginStyle.spacingMedium
        readonly property int spacing: pluginStyle.spacingSmall
    }
    
    // Search bar styles
    readonly property QtObject searchBar: QtObject {
        readonly property color background: "#6baa75"  // Green background for search bar
        readonly property color inputBackground: pluginStyle.inputBackground
        readonly property color inputBorder: pluginStyle.borderColor
        readonly property color buttonBackground: pluginStyle.accentColor
        readonly property color buttonText: "#ffffff"
        readonly property color titleColor: "#ffffff"
        readonly property int height: pluginStyle.searchBarHeight
        readonly property int borderRadius: pluginStyle.borderRadius
        readonly property int spacing: pluginStyle.spacingMedium
        readonly property int titleFontSize: pluginStyle.fontSizeSubtitle
        readonly property int inputFontSize: pluginStyle.fontSizeNormal
    }
    
    // Tab widget styles
    readonly property QtObject tabWidget: QtObject {
        readonly property color tabBackground: "#333333"  
        readonly property int fontSizeTabs: pluginStyle.fontSizeLarge        
        readonly property color tabActiveBackground: pluginStyle.buttonHover
        readonly property color contentBackground: pluginStyle.inputBackground
        readonly property color tabInactiveBackground: pluginStyle.tertiaryBackground
        readonly property color titleColor: pluginStyle.tertiaryText
        readonly property color tabText: pluginStyle.tertiaryText
        readonly property color tabActiveText: pluginStyle.secondaryText
        readonly property color border: pluginStyle.borderColor
        readonly property int borderRadius: pluginStyle.borderRadius
        readonly property int spacing: pluginStyle.spacingSmall
        readonly property int tabHeight: pluginStyle.buttonHeight
    }
    
    // Layout styles
    readonly property QtObject layout: QtObject {
        readonly property int defaultSpacing: pluginStyle.spacingMedium
        readonly property int tightSpacing: pluginStyle.spacingSmall
        readonly property int looseSpacing: pluginStyle.spacingLarge
        readonly property int margins: pluginStyle.spacingMedium
        readonly property int padding: pluginStyle.spacingSmall
    }
    
    // Animation properties
    readonly property QtObject animation: QtObject {
        readonly property int durationFast: 150
        readonly property int durationNormal: 250
        readonly property int durationSlow: 400
        readonly property int easingType: Easing.OutCubic
    }
}
