import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * Range Component
 * 
 * A customizable range input that handles both integer and decimal values, inspired by QField's Range.qml
 * Uses TextField + custom buttons approach for better reliability.
 * 
 * Usage examples:
 *   // For integers
 *   D4_Range {
 *       style: pluginStyle  // Pass the centralized style object
 *       decimals: 0         // Integer mode
 *       realFrom: 0         // Minimum value
 *       realTo: 100         // Maximum value
 *       realStepSize: 1     // Step size for integers
 *       realValue: 25       // Initial value
 *   }
 * 
 *   // For decimals
 *   D4_Range {
 *       style: pluginStyle  // Pass the centralized style object
 *       decimals: 2         // Number of decimal places
 *       realFrom: 0.0       // Minimum real value
 *       realTo: 100.0       // Maximum real value
 *       realStepSize: 0.1   // Step size for decimals
 *       realValue: 5.26     // Initial value
 *   }
 */
Rectangle {
    id: customRangeInput

    // Load centralized styling
    property var style: null
    property var computedStyle: style?.formField || {
        "labelColor": "#333333",
        "labelFontSize": 16,
        "labelFontFamily": "Arial",
        "labelFontBold": false,
        "inputBackground": "#ffffff",
        "inputBorder": "#999999",
        "inputHeight": 35,
        "spacing": 10,
        "borderRadius": 5
    }
    
    // Customizable properties
    property color textColor: computedStyle.labelColor
    property color backgroundColor: computedStyle.inputBackground
    property int minimumWidth: 100
    property int preferredWidth: 200
    property bool fillWidth: false
    
    // Range-specific properties (works for both integers and decimals)
    property int decimals: 2           // 0 for integers, >0 for decimals
    property real realValue: 0.0
    property real realFrom: 0.0
    property real realTo: 100.0
    property real realStepSize: 0.01   // Use 1.0 for integers, smaller values for decimals
    
    // Internal flag to prevent feedback loops during user input
    property bool isUserTyping: false
    
    // Update text display when decimals property changes
    onDecimalsChanged: {
        if (!isUserTyping) {
            updateTextDisplay();
        }
    }
    
    // Update text display when realValue changes
    onRealValueChanged: {
        if (!isUserTyping) {
            updateTextDisplay();
        }
    }
    
    // Legacy properties for compatibility with integer spinbox
    property alias value: customRangeInput.realValue
    property alias from: customRangeInput.realFrom
    property alias to: customRangeInput.realTo
    property alias stepSize: customRangeInput.realStepSize
    
    // Properties for parent context (to be bound from parent)
    property var parentContext: null
    
    // Layout properties for ColumnLayout/GridLayout compatibility
    Layout.preferredWidth: preferredWidth
    Layout.fillWidth: fillWidth
    Layout.minimumWidth: minimumWidth
    
    // Size and appearance
    width: preferredWidth
    height: Math.max(35, computedStyle.inputHeight || 35)
    color: backgroundColor
    border.color: computedStyle.inputBorder
    border.width: 1
    radius: computedStyle.borderRadius
    
    // Ensure component is visible and clickable
    clip: false  // Don't clip content
    
    // Helper functions following QField's approach
    function decreaseValue() {
        const currentValue = Number.parseFloat(textField.text);
        let newValue;
        if (!isNaN(currentValue)) {
            newValue = roundValue(currentValue - realStepSize, decimals);
            updateValue(Math.max(realFrom, newValue));
        } else {
            updateValue(realFrom);
        }
    }

    function increaseValue() {
        const currentValue = Number.parseFloat(textField.text);
        let newValue;
        if (!isNaN(currentValue)) {
            newValue = roundValue(currentValue + realStepSize, decimals);
            updateValue(Math.min(realTo, newValue));
        } else {
            updateValue(realFrom);
        }
    }

    function roundValue(value, precision) {
        const multiplier = Math.pow(10, precision || 0);
        return Math.round(value * multiplier) / multiplier;
    }
    
    function updateValue(newValue) {
        isUserTyping = false  // Temporarily disable user typing flag
        realValue = newValue;
        textField.text = decimals === 0 ? Math.round(newValue).toString() : newValue.toFixed(decimals);
        isUserTyping = false  // Ensure it stays disabled for programmatic updates
    }
    
    // Function to validate and update value when user finishes typing
    function validateAndUpdateValue() {
        if (!textField) return
        
        const text = textField.text
        
        if (decimals === 0) {
            // Integer mode
            if (text === '' || /^\d+$/.test(text)) {
                const newValue = text === '' ? realFrom : parseInt(text);
                if (!isNaN(newValue)) {
                    const clampedValue = Math.max(realFrom, Math.min(realTo, newValue));
                    realValue = Math.round(clampedValue);
                }
            } else {
                // Invalid input, reset to current realValue
                updateTextDisplay();
            }
        } else {
            // Decimal mode
            if (text === '' || !isNaN(parseFloat(text))) {
                const newValue = text === '' ? realFrom : parseFloat(text);
                if (!isNaN(newValue)) {
                    const clampedValue = Math.max(realFrom, Math.min(realTo, newValue));
                    realValue = clampedValue;
                }
            } else {
                // Invalid input, reset to current realValue  
                updateTextDisplay();
            }
        }
    }
    
    // Legacy function for compatibility
    function setRealValue(realVal) {
        updateValue(Math.max(realFrom, Math.min(realTo, realVal)));
    }

    Row {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        TextField {
            id: textField
            width: parent.width - 60  // Two buttons at 30px each
            height: parent.height
            
            font.pixelSize: computedStyle.labelFontSize
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            
            text: decimals === 0 ? Math.round(realValue).toString() : realValue.toFixed(decimals)
            
            validator: decimals === 0 ? intValidator : doubleValidator
            
            IntValidator {
                id: intValidator
                bottom: realFrom
                top: realTo
            }
            
            DoubleValidator {
                id: doubleValidator
                bottom: realFrom
                top: realTo
                decimals: customRangeInput.decimals
                locale: 'C'  // Use C locale for consistent decimal parsing like QField
            }
            
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            
            background: Rectangle {
                color: "transparent"
            }
            
            onActiveFocusChanged: {
                if (activeFocus) {
                    isUserTyping = true
                } else {
                    isUserTyping = false
                    // Update realValue when user finishes typing
                    validateAndUpdateValue()
                }
            }
            
            onTextChanged: {
                if (!isUserTyping) {
                    // Only auto-update when not user typing (e.g., programmatic changes)
                    return
                }
                
                // For decimal mode, don't update realValue while typing
                // For integer mode, still validate to prevent invalid characters
                if (decimals === 0) {
                    // Integer mode - prevent non-digit characters immediately
                    if (text !== '' && !/^\d+$/.test(text)) {
                        // Remove invalid characters
                        var validText = text.replace(/[^\d]/g, '')
                        if (validText !== text) {
                            text = validText
                        }
                    }
                }
            }
        }

        Rectangle {
            id: decreaseButton
            width: 30
            height: parent.height
            color: decreaseArea.pressed ? "#e0e0e0" : "#f5f5f5"
            border.color: computedStyle.inputBorder
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: "−"
                font.pixelSize: Math.max(14, computedStyle.labelFontSize)
                color: textColor
            }
            
            MouseArea {
                id: decreaseArea
                anchors.fill: parent
                onClicked: {
                    decreaseValue()
                }
            }
        }

        Rectangle {
            id: increaseButton
            width: 30
            height: parent.height
            color: increaseArea.pressed ? "#e0e0e0" : "#f5f5f5"
            border.color: computedStyle.inputBorder
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: Math.max(14, computedStyle.labelFontSize)
                color: textColor
            }
            
            MouseArea {
                id: increaseArea
                anchors.fill: parent
                onClicked: {
                    increaseValue()
                }
            }
        }
    }

    Component.onCompleted: {
        // Ensure proper initial text display
        updateTextDisplay();
    }
    
    // Helper function to update text display
    function updateTextDisplay() {
        if (textField) {
            textField.text = decimals === 0 ? Math.round(realValue).toString() : realValue.toFixed(decimals);
        }
    }
}
