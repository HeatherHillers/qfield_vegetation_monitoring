import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.qfield  
import org.qgis
import Theme  

/**
 * Header Page 
 * 
 * Architecture:
 *   - Data Controller: Pure QField/QGIS API (WORKSHOP FOCUS)
 *   - Form Controller: Mediates between data and UI
 *   - Widget Accessor: Standardizes widget value access
 *   - UI Layer: This file - just presentation
 */
Page {
    id: headerPage
    property string plotId: parent.plotId
    // Explicit height for ScrollView detection (Page handles scrolling automatically)
    implicitHeight: headerColumn.implicitHeight + 40
    
    // ===================================================================
    // CONTROLLERS - Separated concerns
    // ===================================================================
    
    // Data layer - QField/QGIS API interactions
    Loader {
        id: dataControllerLoader
        source: "d4_data_controller.qml"
        onLoaded: {
            item.featureSaved.connect(function() {
                console.log("Feature saved successfully")
            })
            
            item.error.connect(function(message) {
                console.log("Data error:", message)
            })
        }
    }
    property var dataController: dataControllerLoader.item
    
    // Form coordination layer
    Loader {
        id: formControllerLoader
        source: "d4_form_controller.qml"
        onLoaded: {
            item.dataController = Qt.binding(function() { return dataController })
            item.dataModel = Qt.binding(function() { return formDataModel })
            
            item.saved.connect(function() {
                console.log("Form saved")
            })
        }
    }
    property var formController: formControllerLoader.item
    
    // Widget accessor factory: provides a simple getValue/setValue API 
    // for all used types of form widget (text, numeric range)
    Loader {
        id: widgetAccessorLoader
        source: "d4_widget_accessor.qml"
    }
    property var widgetAccessor: widgetAccessorLoader.item
    
    // ===================================================================
    // DATA MODEL
    // ===================================================================
    
    Loader {
        id: dataModelLoader
        source: "d4_form_data_model.qml"
    }
    property var formDataModel: dataModelLoader.item
    
    // ===================================================================
    // STATE
    // ===================================================================
    
    // Load plot data when plotId changes (set via binding from parent)
    onPlotIdChanged: {
        if (plotId && controllersReady && formController) {
            console.log("HeaderPage: Loading plot", plotId)
            formController.loadPlot(plotId)
        }
    }
    property bool controllersReady: false
    
    // Wait for all controllers to load before showing UI
    onDataControllerChanged: checkControllersReady()
    onFormControllerChanged: checkControllersReady()
    onWidgetAccessorChanged: checkControllersReady()
    
    function checkControllersReady() {
        controllersReady = (dataController !== null && 
                           formController !== null && 
                           widgetAccessor !== null)
    }
    
    // ===================================================================
    // UI LAYER - Pure presentation
    // ===================================================================
    
    // Main content (Page handles scrolling automatically)
    Rectangle {
        id: headerContainer
        anchors.fill: parent
        color: PluginTheme.vanilla
        border.color: PluginTheme.vanilla
        border.width: 1
        visible: controllersReady
        
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
                            if (formController.hasUnsavedChanges) {
                                formController.save()
                            }
                        }
                    }
                }
                
                // Dynamic form sections from data model
                Repeater {
                    model: (controllersReady && formDataModel) ? formDataModel.groupBoxes : []
                    
                    delegate: FormSection {
                        width: parent.width
                        sectionData: modelData
                        
                        // Pass controller references
                        formController: headerPage.formController
                        widgetAccessor: headerPage.widgetAccessor
                    }
                }
            }  // Column
        }  // Rectangle
    
}
