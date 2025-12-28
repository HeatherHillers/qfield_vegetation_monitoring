import QtQuick
import "."

// Form Controller: Bridges between data layer and UI widgets
// Handles widget value synchronization without QField API details
QtObject {
    id: formController
    
    // Data layer - QField/QGIS API interactions
    property var dataControllerLoader: Loader {
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
    
    // Reference to form data model
    property var dataModel: FormDataModel
    
    // Widget registry - maps field IDs to widget accessors
    property var widgets: ({})
    
    // State
    property bool hasUnsavedChanges: false
    property var pendingFeature: null  // Feature waiting for widgets to be ready
    
    // Signals
    signal saved()
    signal loaded()
    signal cleared()
    
    /**
     * Register a widget for a field
     * If we have a pending feature, populate it after registration
     */
    function registerWidget(fieldId, widgetAccessor) {
        widgets[fieldId] = widgetAccessor
        
        // Check if all widgets are now registered and we have pending data
        if (pendingFeature && allWidgetsRegistered()) {
            populateFormFromFeature(pendingFeature)
            pendingFeature = null
        }
    }
    
    /**
     * Check if all expected widgets are registered
     */
    function allWidgetsRegistered() {
        if (!dataModel) return false
        
        var allFields = dataModel.getAllFields()
        var registeredCount = Object.keys(widgets).length
        
        return registeredCount === allFields.length
    }
    
    /**
     * Get widget value for a field
     */
    function getWidgetValue(fieldId) {
        var accessor = widgets[fieldId]
        if (!accessor) {
            console.log("No widget registered for:", fieldId)
            return null
        }
        
        return accessor.getValue()
    }
    
    /**
     * Set widget value for a field
     */
    function setWidgetValue(fieldId, value) {
        var accessor = widgets[fieldId]
        if (!accessor) {
            console.log("No widget registered for:", fieldId)
            return
        }
        
        accessor.setValue(value)
    }
    
    /**
     * Collect all form values into a field-value map
     */
    function collectFormValues() {
        if (!dataModel) return {}
        
        var values = {}
        var allFields = dataModel.getAllFields()
        
        allFields.forEach(function(field) {
            var value = getWidgetValue(field.id)
            if (value !== null) {
                values[field.id] = value
            }
        })
        
        console.log("Collected form values:", JSON.stringify(values))
        return values
    }
    
    /**
     * Populate form widgets from feature data
     * If widgets aren't ready yet, store feature for later
     */
    function populateFormFromFeature(feature) {
        if (!dataModel || !feature) return
        
        // Check if all widgets are registered yet
        if (!allWidgetsRegistered()) {
            pendingFeature = feature
            return
        }
        
        var allFields = dataModel.getAllFields()
        
        allFields.forEach(function(field) {
            var value = feature.attribute(field.id)
            if (value !== null) {
                setWidgetValue(field.id, value)
            }
        })
        
        hasUnsavedChanges = false
        loaded()
    }
    
    /**
     * Clear all form widgets
     */
    function clearAllWidgets() {
        if (!dataModel) return
        
        console.log("Clearing all widgets")
        var allFields = dataModel.getAllFields()
        
        allFields.forEach(function(field) {
            var defaultValue = (field.fieldType === "text") ? "" : 0
            setWidgetValue(field.id, defaultValue)
        })
        
        hasUnsavedChanges = false
        cleared()
    }
    
    /**
     * Save form values to the current feature
     */
    function save() {
        if (!hasUnsavedChanges) {
            console.log("No changes to save")
            return success
        }
        if (!dataController) {
            console.log("No data controller")
            return false
        }
        
        var fieldValues = collectFormValues()
        var success = dataController.saveFieldValues(fieldValues)
        
        if (success) {
            hasUnsavedChanges = false
            saved()
        }
        
        return success
    }
    
    /**
     * Load feature for a plot and populate form
     */
    function loadPlot(plotId) {
        if (!dataController) {
            console.log("No data controller")
            return
        }
        
        var feature = dataController.loadFeatureForPlot(plotId)
        if (feature) {
            populateFormFromFeature(feature)
        }
    }
    
    /**
     * Mark form as changed (called by widgets)
     */
    function markChanged() {
        hasUnsavedChanges = true
    }
}
