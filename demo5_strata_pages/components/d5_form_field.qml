import QtQuick
import QtQuick.Controls
import Theme
import "."

/**
 * FormField Component
 * Renders a single form field (text or numeric)
 * Automatically registers itself with the form controller
 * Uses PluginTheme for styling
 */
Rectangle {
    id: fieldContainer
    
    property var fieldData: null
    property var formController: null
    property var widgetAccessor: null
    
    property bool isTextField: fieldData ? (fieldData.fieldType === "text") : false
    
    width: isTextField ? parent.width : 280
    height: isTextField ? 100 : 40
    color: "white"
    border.color: "#ccc"
    border.width: 1
    radius: 3
    
    // Text field layout
    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 5
        visible: isTextField
        
        Text {
            text: fieldData ? fieldData.label : ""
            color: Theme.darkGray
            font.pixelSize: PluginTheme.inputFontSize
            width: parent.width
        }
        
        Rectangle {
            width: parent.width
            height: 60
            color: "white"
            border.color: "#999"
            border.width: 1
            
            TextEdit {
                id: textInput
                anchors.fill: parent
                anchors.margins: 5
                color: "#000000"
                font.pixelSize: PluginTheme.inputFontSize
                wrapMode: TextEdit.WordWrap
                selectByMouse: true
                text: ""
                
                onTextChanged: {
                    if (formController) {
                        formController.markChanged()
                    }
                }
            }
        }
    }
    
    // Numeric field layout
    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10
        visible: !isTextField
        
        Text {
            text: fieldData ? fieldData.label : ""
            color: Theme.darkGray
            font.pixelSize: PluginTheme.inputFontSize
            width: 120
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Loader {
            id: numericInputLoader
            width: 120
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            source: "d5_range.qml"
            
            onLoaded: {
                if (item && fieldData) {
                    var rangeItem = item  // d5_range.qml is accessed as loader.item, not loader.item.item
                    
                    // Configure range widget
                    if (fieldData.isDecimal) {
                        rangeItem.decimals = 2
                        rangeItem.realStepSize = fieldData.stepSize || 0.1
                        rangeItem.realFrom = 0
                        rangeItem.realTo = 100
                    } else {
                        rangeItem.decimals = 0
                        rangeItem.realStepSize = fieldData.stepSize || 1
                        rangeItem.realFrom = 0
                        rangeItem.realTo = 100
                    }
                    
                    // Connect change signal directly
                    rangeItem.realValueChanged.connect(function() {
                        if (formController) {
                            formController.markChanged()
                        }
                    })
                }
            }
        }
    }
    
    // Connections for numeric widget changes
    Connections {
        target: numericInputLoader.item  // d5_range.qml is accessed as loader.item
        enabled: !isTextField && target !== null
        
        function onRealValueChanged() {
            if (formController) {
                formController.markChanged()
            }
        }
    }
    
    // Auto-register with form controller when component is complete
    Component.onCompleted: {
        if (!fieldData || !formController || !widgetAccessor) {
            return
        }
        
        // Register widget immediately - controllers are guaranteed ready
        registerWidget()
    }
    
    function registerWidget() {
        if (!fieldData || !formController || !widgetAccessor) return
        
        var accessor
        if (isTextField) {
            accessor = widgetAccessor.createTextAccessor(textInput)
            formController.registerWidget(fieldData.id, accessor)
        } else {
            // For numeric fields, need to wait for loader to complete
            if (numericInputLoader.status === Loader.Ready) {
                accessor = widgetAccessor.createRangeAccessor(numericInputLoader)
                formController.registerWidget(fieldData.id, accessor)
            } else {
                // Loader not ready yet, connect to onLoaded
                numericInputLoader.onLoaded.connect(function() {
                    if (formController && widgetAccessor) {
                        var acc = widgetAccessor.createRangeAccessor(numericInputLoader)
                        formController.registerWidget(fieldData.id, acc)
                    }
                })
            }
        }
    }
}
