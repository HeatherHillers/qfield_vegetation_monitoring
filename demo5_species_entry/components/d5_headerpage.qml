import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.qfield  
import org.qgis
import Theme  

Page {
    id: headerPage
    property var header_layer: qgisProject.mapLayersByName("plot_header")[0]
    // Explicit height for ScrollView detection
    implicitHeight: headerColumn.implicitHeight + 40  // Add padding
    
    // Import centralized style system
    Loader {
        id: styleLoader
        source: "d5_plugin_style.qml"
    }

    // Import the data model
    Loader {
        id: dataModelLoader
        source: "d5_form_data_model.qml"
    }
    
    // Access the data model
    property var formDataModel: dataModelLoader.item   

    // Access the style
    property var style: styleLoader.item
    
    // Properties that will be bound from parent
    property string currentPlotId: ""
    property bool plotFound: false

    // Centralized style properties with consistent fallbacks
    property int fontSize_title: style ? style.fontSizeTitle : 24
    property int fontSize_normal: style ? style.fontSizeNormal : 16
    property int defaultSpacing: style ? style.layout.defaultSpacing : 15
    property color backgroundColor: style ? style.primaryBackground : "#ffecd1"
    property color labelColor: style ? style.formField.labelColor : "#333333"
    property color formBorderColor: style ? style.formBorderColor : "#999999"
    property bool labelFontBold: style ? style.formField.labelFontBold : false

    property var header_feature: null  // Placeholder for header feature, can be set from parent
 

    // Store references to all input components
    property var inputComponents: ({})
    
    // Single range component template (will be configured for integer or decimal mode)
    Component {
        id: rangeComponent
        Loader {
            source: "d5_range.qml"
        }
    }
    
    // Auto-save management
    property bool hasUnsavedChanges: false
    property bool autoSaveEnabled: false // Disabled by default for offline GeoPackage
    property bool showUnsavedIndicator: true
    
    Timer {
        id: autoSaveTimer
        interval: 2000 // Auto-save 2 seconds after last change
        repeat: false
        onTriggered: {
            if (hasUnsavedChanges && autoSaveEnabled) {
                save()
            }
        }
    }

    // Main header container - using simple Rectangle approach that worked    
    Rectangle {
        id: headerContainer
        anchors.fill: parent
        color: backgroundColor
        border.color: "#ccc"
        border.width: 1
        visible: plotFound  // Hide the entire header content when no plot is found or selected
        
        Column {
            id: headerColumn
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 15
            
            // Header title
            Text {
                text: "Vegetation Monitoring - Plot: " + (currentPlotId || "None")
                font.pixelSize: fontSize_title
                color: "#000000"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            
            // Save button
            Rectangle {
                id: saveButtonContainer
                width: 200
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                color: hasUnsavedChanges ? "#2E7D32" : "#1B5E20"
                radius: 10
                border.color: "#333"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: hasUnsavedChanges ? "⚠ Save Data" : "✓ Saved"
                    color: "white"
                    font.pixelSize: fontSize_normal
                    font.bold: true
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        if (hasUnsavedChanges) {
                            save()
                        }
                    }
                }
            }
            
            // Dynamic GroupBox repeaters from data model
            Repeater {
                model: formDataModel ? formDataModel.groupBoxes : []
                    
                delegate: Rectangle {
                    id: groupBoxContainer
                    property string groupId: modelData.id
                    
                    width: parent.width
                    height: groupContent.implicitHeight + 40
                    color: backgroundColor
                    border.color: formBorderColor
                    border.width: 1
                    radius: 5
                    
                    Column {
                        id: groupContent
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        // Group title
                        Text {
                            text: modelData.title
                            color: labelColor
                            font.pixelSize: fontSize_title
                            font.bold: true
                            width: parent.width
                        }
                        
                        // Fields layout - using Flow for responsive arrangement
                        Flow {
                            width: parent.width
                            spacing: 15
                            flow: Flow.TopToBottom  // Stack vertically for text fields, wrap horizontally for numeric
                            
                            // Dynamic field generation using data model
                            Repeater {
                                model: formDataModel ? modelData.fields : []
                                
                                delegate: Rectangle {
                                    property string fieldType: modelData.fieldType || "numeric"  // Default to numeric if not specified
                                    
                                    width: fieldType === "text" ? parent.width : 280  // Full width for text fields
                                    height: fieldType === "text" ? 100 : 40  // Taller for text fields
                                    color: "white"
                                    border.color: "#ccc"
                                    border.width: 1
                                    radius: 3
                                    
                                    // Text field layout
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 5
                                        visible: fieldType === "text"
                                        
                                        Text {
                                            text: modelData.label
                                            color: labelColor
                                            font.pixelSize: fontSize_normal
                                            font.bold: labelFontBold
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
                                                font.pixelSize: fontSize_normal
                                                wrapMode: TextEdit.WordWrap
                                                selectByMouse: true
                                                text: "Enter text here..."
                                                
                                                onTextChanged: {
                                                    hasUnsavedChanges = true
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Numeric field layout  
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 10
                                        visible: fieldType !== "text"
                                        
                                        Text {
                                            text: modelData.label
                                            color: labelColor
                                            font.pixelSize: fontSize_normal
                                            font.bold: labelFontBold
                                            width: 120
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        // Dynamic SpinBox based on field type
                                        Loader {
                                            id: numericInputLoader
                                            width: 120
                                            height: 30
                                            anchors.verticalCenter: parent.verticalCenter
                                            
                                            sourceComponent: rangeComponent
                                            
                                            onLoaded: {
                                                if (item && item.item) {
                                                    
                                                    var rangeItem = item.item  // Access the actual d4_range component
                                                    
                                                    // Configure the loaded Range component
                                                    if (modelData.isDecimal) {
                                                        rangeItem.decimals = 2
                                                        rangeItem.realStepSize = modelData.stepSize || 0.1
                                                        rangeItem.realFrom = 0
                                                        rangeItem.realTo = 100
                                                    } else {
                                                        rangeItem.decimals = 0  // Integer mode
                                                        rangeItem.realStepSize = modelData.stepSize || 1
                                                        rangeItem.realFrom = 0
                                                        rangeItem.realTo = 100
                                                    }
                                                    
                                                    
                                                    // Connect value changes to mark as changed
                                                    rangeItem.realValueChanged.connect(function() {
                                                        hasUnsavedChanges = true
                                                    })
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Store reference for external access
                                    Component.onCompleted: {
                                        // Debug output
                                        
                                        // Store component reference based on field type
                                        if (fieldType === "text") {
                                            inputComponents[modelData.id + "_Input"] = { item: textInput }
                                        } else {
                                            // For numeric fields, we need to access the loaded Range item
                                            inputComponents[modelData.id + "_Input"] = { loader: numericInputLoader }
                                            
                                            // Once the loader is complete, update the reference
                                            numericInputLoader.onLoaded.connect(function() {
                                                if (numericInputLoader.item && numericInputLoader.item.item) {
                                                    inputComponents[modelData.id + "_Input"] = { 
                                                        item: numericInputLoader.item.item  // Access the actual d4_range component
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Placeholder message when no plot is selected
    Rectangle {
        id: noPlotContainer
        anchors.fill: parent
        color: backgroundColor
        visible: !plotFound  // Show when no plot is found or selected
        
        Column {
            anchors.centerIn: parent
            spacing: 20
            
            Text {
                text: currentPlotId ? "Plot '" + currentPlotId + "' not found" : "No plot selected"
                font.pixelSize: fontSize_title
                color: labelColor
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: currentPlotId ? "Please check if the plot ID is correct" : "Select a plot from the search menu to view details"
                font.pixelSize: fontSize_normal
                color: labelColor
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.7
            }
        }
    }
    
    // Page-level functions (business logic)
    function markAsChanged() {
        hasUnsavedChanges = true
        // Optional auto-save for offline GeoPackage (disabled by default)
        if (autoSaveEnabled) {
            autoSaveTimer.restart()
        }
    }
    
    function configureSpinBox(spinboxItem, fieldData) {
        if (!spinboxItem) return
        
        spinboxItem.stepSize = fieldData.stepSize || 5
        spinboxItem.textColor = headerPage.backgroundColor
        spinboxItem.backgroundColor = headerPage.backgroundColor

        // Add change tracking
        spinboxItem.valueChanged.connect(function() {
            markAsChanged()
        })
        
        // Add custom indicators if available
        if (typeof upIndicatorComponent !== 'undefined') {
            spinboxItem.up.indicator = upIndicatorComponent.createObject(spinboxItem, { "indicatorEnabled": spinboxItem.up.enabled })
        }
        if (typeof downIndicatorComponent !== 'undefined') {
            spinboxItem.down.indicator = downIndicatorComponent.createObject(spinboxItem, { "indicatorEnabled": spinboxItem.down.enabled })
        }
    }
    
    function save(){
        if (!header_feature) {
            console.log("No feature to save")
            return
        }
        header_layer.startEditing()
        var fid = header_feature.id
        var fields = header_feature.fields
        
        // Save timestamp and comment
        header_layer.changeAttributeValue(fid, fields.indexOf("log_date"), new Date().toISOString())

        // Save comment field (will be handled by getAllFields loop below)
        
        // Save all form fields using the data model
        if (formDataModel) {
            const allFields = formDataModel.getAllFields()
            allFields.forEach(function(field) {
                const fieldKey = field.id + "_Input"
                const inputComponent = inputComponents[fieldKey]
                
                if (inputComponent) {
                    let value
                    
                    if (field.fieldType === "text" && inputComponent.item) {
                        value = inputComponent.item.text || ""
                    } else if (field.fieldType !== "text") {
                        // Handle numeric fields - check different possible structures
                        let rangeItem = null
                        
                        if (inputComponent.item) {
                            // Direct access to range item
                            rangeItem = inputComponent.item
                        } else if (inputComponent.loader) {
                            if (inputComponent.loader.item) {
                                if (inputComponent.loader.item.item) {
                                    rangeItem = inputComponent.loader.item.item
                                }
                            }
                        }
                        
                        if (rangeItem) {
                            if (rangeItem.realValue !== undefined) {
                                value = rangeItem.realValue || 0
                            } else {
                                value = 0
                            }
                        } else {
                            value = 0
                            console.log("Could not find range item for save:", field.id, "using default value 0")
                        }
                    }
                    
                    // Save the value to the layer
                    if (value !== undefined) {
                        header_layer.changeAttributeValue(fid, fields.indexOf(field.id), value)
                    }
                } else {
                    console.log("No input component found for save:", fieldKey)
                }
            })
        }
        
        header_layer.commitChanges()
        hasUnsavedChanges = false
    }
    
    function clearForm() {
        // Clear all form fields
        if (formDataModel) {
            const allFields = formDataModel.getAllFields()
            allFields.forEach(function(field) {
                const fieldKey = field.id + "_Input"
                const inputComponent = inputComponents[fieldKey]
                
                if (inputComponent) {
                    if (field.fieldType === "text" && inputComponent.item) {
                        inputComponent.item.text = ""
                    } else if (field.fieldType !== "text") {
                        // Handle numeric fields - check different possible structures
                        let rangeItem = null
                        
                        if (inputComponent.item) {
                            // Direct access to range item
                            rangeItem = inputComponent.item
                        } else if (inputComponent.loader) {
                            if (inputComponent.loader.item) {
                                if (inputComponent.loader.item.item) {
                                    rangeItem = inputComponent.loader.item.item
                                }
                            }
                        }
                        
                        if (rangeItem) {
                            if (rangeItem.realValue !== undefined) {
                                rangeItem.realValue = 0
                            }
                        } else {
                            console.log("Could not find range item for:", field.id)
                        }
                    }
                } else {
                    console.log("No input component found for:", fieldKey)
                }
            })
        }
        
        header_feature = null
        hasUnsavedChanges = false
    }
    
    function show_form(header_feature) {
        
        // Load all form fields using the data model (including comments)
        if (formDataModel) {
            const allFields = formDataModel.getAllFields()
            allFields.forEach(function(field) {
                const fieldKey = field.id + "_Input"
                const inputComponent = inputComponents[fieldKey]
                
                if (inputComponent) {
                    if (field.fieldType === "text" && inputComponent.item) {
                        const textValue = header_feature.attribute(field.id) || ''
                        inputComponent.item.text = textValue
                    } else if (field.fieldType !== "text") {
                        // Handle numeric fields - check different possible structures
                        let rangeItem = null
                        
                        if (inputComponent.item) {
                            // Direct access to range item
                            rangeItem = inputComponent.item
                        } else if (inputComponent.loader) {
                            if (inputComponent.loader.item) {
                                if (inputComponent.loader.item.item) {
                                    rangeItem = inputComponent.loader.item.item
                                }
                            }
                        }
                        
                        if (rangeItem) {
                            const attributeValue = header_feature.attribute(field.id) || 0
                            if (rangeItem.realValue !== undefined) {
                                rangeItem.realValue = attributeValue
                            }
                        } else {
                            console.log("Could not find range item for load:", field.id)
                        }
                    }
                } else {
                    console.log("No input component found for load:", fieldKey)
                }
            })
        }
        
        hasUnsavedChanges = false // Reset change tracking after loading
    }
    
    function load(){
        /* On load, the header table row corresponding to the plot id will be loaded to the form.  If it
           has not been created yet, a new row will be initialized with the plot id, uid and log_date populated.*/
        header_layer.startEditing()
        var feature_iterator = LayerUtils.createFeatureIteratorFromExpression(header_layer, "plot_id = '" + currentPlotId + "'")
        if (feature_iterator.hasNext()){
            header_feature = feature_iterator.next()
            feature_iterator.close()
        } else {
            feature_iterator.close()
            header_feature = FeatureUtils.createFeature(header_layer)
            header_feature.setAttribute("f_uid", StringUtils.createUuid().replace(/[\{\}]/g, ""))
            header_feature.setAttribute("plot_id", currentPlotId)
            header_feature.setAttribute("log_date", new Date().toISOString())
            LayerUtils.addFeature(header_layer, header_feature) 
            header_layer.commitChanges()
            // retrieve the feature again after a commit to get the valid feature and id 
            feature_iterator = LayerUtils.createFeatureIteratorFromExpression(header_layer, "plot_id = '" + currentPlotId + "'")
            header_feature = feature_iterator.next()
            feature_iterator.close()  
        }
        show_form(header_feature)
    }
    
    function error(message){
        console.log("Header page error:", message)
        // Could add error display UI here in the future
    }


}
