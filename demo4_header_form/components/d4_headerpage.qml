import QtQuick
import QtQuick.Layouts

import org.qfield  
import org.qgis
import Theme  
import "."

/**
 * Header Page 
 * 
 * Architecture:
 *   - Form Controller: Mediates between data layers and UI
 *      - load called when plotId changes
 *      - save called when user clicks save button
 *   - Layout: Layout is the focus of this file
 */
Rectangle {
    id: headerPage
    property string plotId: parent.plotId
    implicitHeight: headerColumn.implicitHeight + 40
    
    color: PluginTheme.vanilla
    border.color: PluginTheme.vanilla
    border.width: 1
    
    // Form coordination between data and UI
    FormController {
        id: controller
    }
    
    // Obfuscation: Property alias to expose controller to children
    property var formController: controller
        
    // Load plot data when plotId changes (set via binding from parent)
    onPlotIdChanged: {
        if (plotId ) {
            console.log("HeaderPage: Loading plot", plotId)
            formController.loadPlot(plotId)
        }
    }
    
    // ===================================================================
    // LAYOUT
    // ===================================================================
    
    Column {
        id: headerColumn
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 15
        
        // Title
        Text {
                text: "Vegetation Monitoring - Plot: " + (plotId || "None")
                font.pixelSize: PluginTheme.titleFontSize
                color: Theme.darkGray
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            
        // Save button
        Rectangle {
            id: saveButton
            width: 200
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            color: formController.hasUnsavedChanges ? "#2E7D32" : "#1B5E20"
            radius: 10
            border.color: Theme.darkGray
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: formController.hasUnsavedChanges ? "⚠ Save Data" : "✓ Saved"
                color: PluginTheme.white
                font.pixelSize: PluginTheme.inputFontSize
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    formController.save()
                }
            }
        }
        
        // Dynamic form sections from data model
        Repeater {
            model: FormDataModel.groupBoxes
            
            delegate: FormSection {
                width: parent.width
                sectionData: modelData
                
                // Pass controller reference
                controller: headerPage.formController
            }
        }
    }  // Column
}
