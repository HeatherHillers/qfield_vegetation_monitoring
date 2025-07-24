# 🎨 Centralized Style System for QField Vegetation Monitoring Plugin

## Overview
This style system provides a CSS-like approach to styling QML components, centralizing all visual design decisions in one place for consistency and maintainability.

## Files
- **`d4_plugin_style.qml`** - Main style definitions (like CSS)
- **`d4_style_example.qml`** - Example component showing usage patterns
- Components updated: `d4_plugin_component.qml`, `d4_headerpage.qml`

## 🚀 How to Use the Style System

### 1. Import the Style in Your Component
```qml
Rectangle {
    id: myComponent
    
    // Import centralized style
    Loader {
        id: styleLoader
        source: "d4_plugin_style.qml"
    }
    
    // Access the style
    property var style: styleLoader.item
    
    // Use style properties with fallbacks
    color: style ? style.primaryBackground : "#ffecd1"
}
```

### 2. Using Colors
```qml
// Background colors
color: style ? style.primaryBackground : "#ffecd1"        // Light cream
color: style ? style.secondaryBackground : "#ffffff"      // White
color: style ? style.accentColor : "#2E7D32"             // Dark green

// Text colors
color: style ? style.primaryText : "#6baa75"             // Green text
color: style ? style.labelColor : "#333333"              // Dark gray labels

// Status colors
color: style ? style.successColor : "#4CAF50"            // Success green
color: style ? style.warningColor : "#FF9800"            // Warning orange
color: style ? style.errorColor : "#F44336"              // Error red
```

### 3. Using Typography
```qml
Label {
    text: "My Title"
    font.pixelSize: style ? style.fontSizeTitle : 24
    font.family: style ? style.fontFamily : "Arial"
    font.bold: style ? style.fontBoldTitles : true
    color: style ? style.labelColor : "#333333"
}
```

### 4. Using Spacing and Sizing
```qml
ColumnLayout {
    spacing: style ? style.layout.defaultSpacing : 15
    anchors.margins: style ? style.layout.margins : 15
}

Button {
    Layout.preferredHeight: style ? style.button.height : 40
}
```

### 5. Using Component-Specific Styles

#### Buttons
```qml
Button {
    background: Rectangle {
        color: style ? style.button.background : "#2E7D32"
        radius: style ? style.button.borderRadius : 5
    }
    
    contentItem: Text {
        text: parent.text
        color: style ? style.button.text : "#ffffff"
        font.pixelSize: style ? style.button.fontSize : 16
        font.bold: style ? style.button.fontBold : true
    }
}
```

#### Form Fields
```qml
RowLayout {
    spacing: style ? style.formField.spacing : 10
    
    Label {
        text: "Field Label:"
        color: style ? style.formField.labelColor : "#333333"
        font.pixelSize: style ? style.formField.labelFontSize : 16
    }
    
    TextField {
        background: Rectangle {
            color: style ? style.formField.inputBackground : "#ffffff"
            border.color: style ? style.formField.inputBorder : "#999999"
            radius: style ? style.formField.borderRadius : 5
        }
    }
}
```

#### Group Boxes
```qml
GroupBox {
    title: "My Group"
    font.pixelSize: style ? style.groupBox.titleFontSize : 20
    
    background: Rectangle {
        color: style ? style.groupBox.background : "#ffffff"
        border.color: style ? style.groupBox.border : "#cccccc"
        radius: style ? style.groupBox.borderRadius : 5
    }
}
```

## 🎯 Available Style Properties

### Colors
- `primaryBackground` - Main plugin background
- `secondaryBackground` - Component backgrounds  
- `primaryText` - Main text color
- `labelColor` - Form label color
- `accentColor` - Buttons and highlights
- `successColor`, `warningColor`, `errorColor` - Status colors
- `borderColor`, `formBorderColor` - Border colors

### Typography
- `fontFamily` - Default font family
- `fontSizeTitle`, `fontSizeSubtitle`, `fontSizeNormal`, `fontSizeSmall` - Font sizes
- `fontBoldDefault`, `fontBoldTitles` - Bold settings

### Spacing & Sizing
- `spacingTiny`, `spacingSmall`, `spacingMedium`, `spacingLarge` - Standard spacing units
- `borderRadius`, `borderWidth` - Border properties
- `buttonHeight`, `inputHeight`, `searchBarHeight` - Component heights

### Component Styles
- `button.*` - Button styling properties
- `saveButton.*` - Save button specific styles
- `formField.*` - Form field styling
- `groupBox.*` - Group box styling
- `searchBar.*` - Search bar styling
- `tabWidget.*` - Tab widget styling
- `layout.*` - Layout spacing and margins

## 🔧 Benefits

1. **Consistency** - All components use the same visual language
2. **Maintainability** - Change colors/fonts in one place
3. **Theming** - Easy to create different themes
4. **Fallbacks** - Components work even if style fails to load
5. **Performance** - Style loaded once, used everywhere

## 🎨 Customization

To modify the plugin's appearance:

1. **Edit `d4_plugin_style.qml`** to change colors, fonts, spacing
2. **Add new style properties** for new components
3. **Create style variants** for different themes
4. **Use animations** with the provided animation properties

## 📝 Example: Creating a New Styled Component

```qml
import QtQuick
import QtQuick.Controls

Rectangle {
    id: myStyledComponent
    
    // Import style
    Loader {
        id: styleLoader
        source: "d4_plugin_style.qml"
    }
    property var style: styleLoader.item
    
    // Apply styles
    color: style ? style.secondaryBackground : "#ffffff"
    border.color: style ? style.borderColor : "#cccccc"
    radius: style ? style.borderRadius : 5
    
    Text {
        anchors.centerIn: parent
        text: "Styled Component"
        color: style ? style.labelColor : "#333333"
        font.pixelSize: style ? style.fontSizeNormal : 16
        font.family: style ? style.fontFamily : "Arial"
    }
}
```

This approach ensures all components in your vegetation monitoring plugin have a consistent, professional appearance that can be easily maintained and modified.
