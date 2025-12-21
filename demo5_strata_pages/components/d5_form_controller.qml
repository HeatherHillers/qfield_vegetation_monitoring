import QtQuick

// Form Controller: Bridges between data layer and UI widgets
// Handles widget value synchronization without QField API details
QtObject {
    id: formController
    
    // Reference to data controller
    property var dataController: null
    
    // Reference to form data model
    property var dataModel: null
    
    // Widget registry - maps field IDs to widget accessors
    property var widgets: ({})
    
    // State
    property bool hasUnsavedChanges: false
    
    // Signals
    signal saved()
    signal loaded()
    signal cleared()
    
    /**
     * Register a widget for a field
     * Simplifies widget access by hiding loader complexity
     */
    function registerWidget(fieldId, widgetAccessor) {
        widgets[fieldId] = widgetAccessor
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
        
        return values
    }
    
    /**
     * Populate form widgets from feature data
     */
    function populateFormFromFeature(feature) {
        if (!dataModel || !feature) return
        
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
