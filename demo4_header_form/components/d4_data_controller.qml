// d4_data_controller.qml
import QtQuick
import org.qfield  
import org.qgis

// Data Controller: Handles all QField/QGIS layer interactions for the plot header form
QtObject {
    id: dataController
    
    // Layer reference
    property var layer: qgisProject.mapLayersByName("plot_header")[0]
    
    // Current feature being edited
    property var currentFeature: null
    
    // Signals
    signal featureLoaded(var feature)
    signal featureSaved()
    signal error(string message)
    
    
    /**
     * Load or create a feature for the given plot ID
     * Demonstrates: Feature iteration, feature creation, LayerUtils
     */
    function loadHeaderForPlot(plotId) {
        if (!plotId) {
            error("No plot ID provided")
            return null
        }
        
        console.log("Loading Header Row feature for plot:", plotId)
        
        // Query for existing feature
        var expression = "plot_id = '" + plotId + "'"
        var iterator = LayerUtils.createFeatureIteratorFromExpression(layer, expression)
        
        if (iterator.hasNext()) {
            // Feature exists - load it
            currentFeature = iterator.next()
            iterator.close()  // CRITICAL: Always close iterators
            console.log("Found existing Header Row feature for plot:", plotId)
        } else {
            iterator.close()  // CRITICAL: Always close iterators
            
            // Feature doesn't exist - create it
            currentFeature = createNewFeature(plotId)
        }
        
        featureLoaded(currentFeature)
        return currentFeature
    }
    
    /**
     * Create a new feature with initial values
     * Demonstrates: FeatureUtils.createFeature, setAttribute, LayerUtils.addFeature
     */
    function createNewFeature(plotId) {
        console.log("Creating new feature for plot:", plotId)
        
        layer.startEditing()
        
        var newFeature = FeatureUtils.createFeature(layer)
        newFeature.setAttribute("f_uid", StringUtils.createUuid().replace(/[\{\}]/g, ""))
        newFeature.setAttribute("plot_id", plotId)
        newFeature.setAttribute("log_date", new Date().toISOString())
        
        LayerUtils.addFeature(layer, newFeature)
        layer.commitChanges()
        
        // Re-fetch to get valid feature ID after commit
        var iterator = LayerUtils.createFeatureIteratorFromExpression(
            layer, 
            "plot_id = '" + plotId + "'"
        )
        var committedFeature = iterator.next()
        iterator.close()  // CRITICAL: Always close iterators
        
        console.log("Created feature with ID:", committedFeature.id)
        return committedFeature
    }
    
    /**
     * Read a field value from the current feature
     * Demonstrates: feature.attribute() - never use hardcoded indexes!
     */
    function getFieldValue(fieldName) {
        if (!currentFeature) {
            console.log("No feature loaded - cannot get field:", fieldName)
            return null
        }
        
        return currentFeature.attribute(fieldName)
    }
    
    /**
     * Save field values to the feature
     * Demonstrates: layer editing workflow, changeAttributeValue
     */
    function saveFieldValues(fieldValueMap) {
        if (!currentFeature) {
            error("No feature to save")
            return false
        }
        
        console.log("Saving", Object.keys(fieldValueMap).length, "fields")
        
        layer.startEditing()
        
        var fid = currentFeature.id
        var fields = currentFeature.fields
        
        // Update timestamp
        var logDateIndex = fields.indexOf("log_date")
        layer.changeAttributeValue(fid, logDateIndex, new Date().toISOString())
        
        // Update all field values from the map
        for (var fieldName in fieldValueMap) {
            var value = fieldValueMap[fieldName]
            var fieldIndex = fields.indexOf(fieldName)
            
            if (fieldIndex >= 0) {
                layer.changeAttributeValue(fid, fieldIndex, value)
                console.log("Saved field:", fieldName, "=", value)
            } else {
                console.log("Warning: Field not found:", fieldName)
            }
        }
        
        layer.commitChanges()
        featureSaved()
        
        console.log("Successfully saved feature")
        return true
    }
    
    /**
     * Get all field values as a map
     * Useful for debugging and form population
     */
    function getAllFieldValues() {
        if (!currentFeature) return {}
        
        var values = {}
        var fields = currentFeature.fields
        
        for (var i = 0; i < fields.count(); i++) {
            var fieldName = fields.field(i).name()
            values[fieldName] = currentFeature.attribute(fieldName)
        }
        
        return values
    }
}
