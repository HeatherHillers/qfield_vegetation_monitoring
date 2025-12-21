import QtQuick
import org.qfield
import org.qgis

/**
 * Strata Data Controller
 * 
 * Pure QField/QGIS API layer for species entries management.
 * This is the WORKSHOP FOCUS - demonstrates QField feature operations:
 * - Querying features with expressions
 * - Creating new features
 * - Feature attribute manipulation
 * - Layer editing workflow (startEditing/commitChanges)
 * 
 * Responsibilities:
 * - Load species entries for a plot/stratum
 * - Create new species entries
 * - Delete species entries
 * - No UI knowledge - only emits signals
 */
QtObject {
    id: dataController
    
    // Layer references (set by parent)
    property var speciesLayer: null
        
    // Current context
    property string plotId: ""
    property string currentStratum: ""
    
    // Signals
    signal entriesLoaded(var features)
    signal entryCreated(var feature)
    signal entryDeleted(var featureId)
    signal error(string message)
    
    /**
     * Load all species entries for the current plot and stratum
     * Returns array of features via entriesLoaded signal
     */
    function loadEntries(plot_id, stratum_code) {
        if (!speciesLayer) {
            speciesLayer = qgisProject.mapLayersByName("species")[0]
            if (!speciesLayer) {
                error("Species layer not found in project")
                return
            }
        }
        
        var expression = "plot_id = '" + plot_id + "' and stratum = '" + stratum_code + "'"
        var iterator = LayerUtils.createFeatureIteratorFromExpression(speciesLayer, expression)
        
        var features = []
        while (iterator.hasNext()) {
            var feature = iterator.next()
            features.push(feature)
        }
        iterator.close()  // CRITICAL: Always close iterator
        
        entriesLoaded(features)
    }
    
    /**
     * Create a new species entry for the current plot/stratum
     * Returns the committed feature via entryCreated signal
     */
    function createNewEntry() {
        if (!speciesLayer) {
            speciesLayer = qgisProject.mapLayersByName("species")[0]
            if (!speciesLayer) {
                error("Species layer not found in project")
                return
            }
        }
        
        if (!plotId) {
            error("No plot selected")
            return
        }
        
        
        // Start editing transaction
        speciesLayer.startEditing()
        
        // Create new feature
        var feature = FeatureUtils.createFeature(speciesLayer)
        if (!feature) {
            error("Failed to create new feature")
            speciesLayer.rollBack()
            return
        }
        
        // Set attributes
        feature.setAttribute("f_uid", StringUtils.createUuid().replace(/[\{\}]/g, ""))
        feature.setAttribute("plot_id", plotId)
        feature.setAttribute("stratum", currentStratum)
        feature.setAttribute("year", new Date().getFullYear())
        
        // Add to layer
        LayerUtils.addFeature(speciesLayer, feature)
        
        // Commit changes
        var commitSuccess = speciesLayer.commitChanges()
        if (!commitSuccess) {
            console.error("Commit errors:", speciesLayer.commitErrors())
            error("Failed to commit new entry to database")
            speciesLayer.rollBack()
            return
        }
        
        // Retrieve the committed feature with its permanent ID
        var f_uid = feature.attribute("f_uid")
        var iterator = LayerUtils.createFeatureIteratorFromExpression(
            speciesLayer, 
            "f_uid = '" + f_uid + "'"
        )
        
        if (iterator.hasNext()) {
            var committedFeature = iterator.next()
            iterator.close()
            
            console.log("Created new entry with f_uid:", f_uid)
            entryCreated(committedFeature)
        } else {
            iterator.close()
            error("Failed to retrieve committed feature")
        }
    }
    
    /**
     * Delete a species entry by feature ID
     */
    function deleteEntry(featureId) {
        if (!speciesLayer) {
            error("Species layer not available")
            return false
        }
        
        speciesLayer.startEditing()
        
        var success = speciesLayer.deleteFeature(featureId)
        if (!success) {
            error("Failed to delete feature")
            speciesLayer.rollBack()
            return false
        }
        
        var commitSuccess = speciesLayer.commitChanges()
        if (!commitSuccess) {
            error("Failed to commit deletion")
            speciesLayer.rollBack()
            return false
        }
        
        console.log("Deleted entry with ID:", featureId)
        entryDeleted(featureId)
        return true
    }
    
    /**
     * Update a single field value for a species entry
     * Returns true on success, false on failure
     */
    function saveFieldValue(featureId, fieldName, value) {
        if (!speciesLayer) {
            error("Species layer not available")
            return false
        }
        
        // Get the feature to find field index
        var iterator = LayerUtils.createFeatureIteratorFromExpression(
            speciesLayer,
            "$id = " + featureId
        )
        
        if (!iterator.hasNext()) {
            iterator.close()
            error("Feature not found: " + featureId)
            return false
        }
        
        var feature = iterator.next()
        iterator.close()
        
        // Get field index from feature.fields (property, not method)
        var fieldIndex = feature.fields.indexOf(fieldName)
        if (fieldIndex === -1) {
            error("Field not found: " + fieldName)
            return false
        }
        
        // Update the field
        speciesLayer.startEditing()
        speciesLayer.changeAttributeValue(featureId, fieldIndex, value)
        
        var commitSuccess = speciesLayer.commitChanges()
        if (!commitSuccess) {
            console.error("Commit errors:", speciesLayer.commitErrors())
            error("Failed to save field " + fieldName)
            speciesLayer.rollBack()
            return false
        }
        
        return true
    }
    
}
