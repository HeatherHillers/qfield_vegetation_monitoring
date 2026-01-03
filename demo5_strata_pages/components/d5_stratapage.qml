import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Theme  
// import qmldir objects
import "."
/**
 * Strata Page Component
 * Strata Page
 * 
 * Architecture:
 *   - Data Controller: Pure QField/QGIS API (WORKSHOP FOCUS)
 *   - Strata Controller: Manages entry widget list
 *   - UI Layer: This file - just presentation
 */
Rectangle {
    id: strataPage
    
    implicitHeight: strataColumn.implicitHeight + 30
    
    // ===================================================================
    // EXTERNAL PROPERTIES - Set by parent
    // ===================================================================
    property string strataName: parent.strataName
    property string strataCode: parent.strataCode
    property string plotId: parent.plotId

    onPlotIdChanged: {
        // plot id comes in after the page is created - load entries when it is set.
        dataController.loadEntries(strataPage.plotId, strataPage.strataCode)
    }

    // Data layer - QField/QGIS API interactions
    Loader {
        id: dataControllerLoader
        source: "d5_strata_data_controller.qml"
        onLoaded: {
            // Keep data controller context in sync with page properties
            item.plotId = Qt.binding(function() { return plotId })
            item.currentStratum = Qt.binding(function() { return strataCode })
            
            // Connect to data controller signals
            item.entriesLoaded.connect(function(features) {
                strataController.clearAllWidgets()
                for (var i = 0; i < features.length; i++) {
                    createEntryWidget(features[i])
                }
            })
            
            item.entryCreated.connect(function(feature) {
                createEntryWidget(feature)
            })
            
            
            item.error.connect(function(message) {
                console.log("Data error:", message)
                showError(message)
            })
        }
    }
    property var dataController: dataControllerLoader.item

    // Widget management layer
    Loader {
        id: strataControllerLoader
        source: "d5_strata_controller.qml"
        onLoaded: {
            item.dataController = Qt.binding(function() { return dataController })
        }
    }
    property var strataController: strataControllerLoader.item   

    // ===================================================================
    // STYLING
    // ===================================================================
    color: PluginTheme.vanilla
    border.color: PluginTheme.vanilla
    border.width: 1

    // ===================================================================
    // UI LAYER - Pure presentation
    // ===================================================================   
    Column {
        id: strataColumn
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15
        
        Label {
            id: pageError
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Qt.AlignHCenter
            visible: false
            color: Theme.errorColor
            text: "Error Message"
            font.pixelSize: PluginTheme.titleFontSize
        }
        
        // Title
        Label {
            id: pageTitle
            visible: !pageError.visible
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Qt.AlignHCenter
            text: strataName + " " + plotId
            color: Theme.darkGray
            font.pixelSize: PluginTheme.titleFontSize
            font.bold: true
        }
        
        // Add Entry Button
        Button {
            id: addEntryButton
            visible: !pageError.visible
            anchors.horizontalCenter: parent.horizontalCenter
            
            background: Rectangle {
                anchors.fill: parent
                color: PluginTheme.green
                radius: 10
            }
            
            contentItem: Text {
                text: "New Entry"
                color: addEntryButton.pressed ? Theme.darkGray : "white"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                if (strataController) {
                    strataController.createNewEntry()
                }
            }
        }
        // Entries container
        ColumnLayout {
            id: entriesLayout
            width: parent.width
            spacing: 15
            visible: !pageError.visible
        }
    }

    // ===================================================================
    // WIDGET CREATION
    // ===================================================================
    
    // Component template for species entry
    Component {
        id: speciesEntryComponent
        
        Rectangle {
            id: speciesEntryWrapper
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            
            property var entryFeature: null
            property var onDeleteRequestedFromChild: null
            
            Loader {
                id: speciesLoader
                source: "d5_species.qml"
                anchors.fill: parent
                
                onLoaded: {
                    if (item) {
                        updateItemProperties()
                    }
                }
                
                function updateItemProperties() {
                    if (!item) return
                    
                    // Pass properties to species entry using bindings where possible
                    item.plotId = plotId
                    item.feature = speciesEntryWrapper.entryFeature
                    item.stratum = strataCode
                    
                    // No need to pass menuProvider - species widget accesses MenuProvider singleton directly!
                    
                    // Connect save callback
                    item.onSaveField = function(fieldName, value) {
                        console.log("Save callback triggered for field:", fieldName, "value:", value)
                        if (speciesEntryWrapper.entryFeature && dataController) {
                            console.log("Feature ID:", speciesEntryWrapper.entryFeature.id)
                            var success = dataController.saveFieldValue(
                                speciesEntryWrapper.entryFeature.id,
                                fieldName,
                                value
                            )
                            console.log("Save result:", success)
                        } else {
                            console.error("Missing feature or dataController")
                        }
                    }
                    
                    // Connect deletion callback
                    item.onDeleteRequested = function() {
                        if (speciesEntryWrapper.onDeleteRequestedFromChild) {
                            speciesEntryWrapper.onDeleteRequestedFromChild()
                        }
                    }
                }
            }
            
            // Watch for entryFeature changes and update loaded item
            onEntryFeatureChanged: {
                if (speciesLoader.item) {
                    speciesLoader.updateItemProperties()
                }
            }
        }
    }   
    /**
     * Create a widget for a species entry feature
     */
    function createEntryWidget(feature) {
        if (!feature) {
            console.error("Cannot create widget - feature is null")
            return
        }
        
        try {
            var entryWidget = speciesEntryComponent.createObject(entriesLayout)
            
            if (!entryWidget) {
                console.error("Failed to create species entry widget")
                return
            }
            
            // Set properties
            entryWidget.entryFeature = feature
            
            // Set up deletion callback.  The species widget has deleted its data, now delete the widget.
            entryWidget.onDeleteRequestedFromChild = function() {
                var featureId = feature.id
                strataController.removeWidget(entryWidget)
            }
            
            // Register with controller
            strataController.registerWidget(entryWidget)
            
        } catch (error) {
            console.error("Error creating entry widget:", error)
        }
    }
    function showError(message) {
        pageError.text = message
        pageError.visible = true
    }    
}
