import QtQuick
import QtQuick.Controls
import Theme
import "."

/**
 * FormSection Component
 * Renders a group of form fields from the data model
 * Simplified UI-only component - uses PluginTheme for styling
 */
Rectangle {
    id: groupBox
    
    // Properties from parent
    property var sectionData: null
    property var formController: null
    property var widgetAccessor: null
    
    height: groupContent.implicitHeight + 40
    color: PluginTheme.vanilla
    border.color: PluginTheme.vanilla
    border.width: 1
    radius: 5
    
    Column {
        id: groupContent
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        // Section title
        Text {
            text: sectionData ? sectionData.title : ""
            color: Theme.darkGray
            font.pixelSize: PluginTheme.titleFontSize
            font.bold: true
            width: parent.width
        }
        
        // Fields
        Flow {
            width: parent.width
            spacing: 15
            flow: Flow.TopToBottom
            
            Repeater {
                model: sectionData ? sectionData.fields : []
                
                delegate: FormField {
                    fieldData: modelData
                    formController: groupBox.formController
                    widgetAccessor: groupBox.widgetAccessor
                }
            }
        }
    }
}
