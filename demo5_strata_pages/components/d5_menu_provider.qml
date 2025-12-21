pragma Singleton

import QtQuick
import org.qfield
import org.qgis
import "."

/**
 * Menu Provider - Singleton for shared menu data
 * 
 * This singleton loads menu layers once and provides ListModels
 * that can be accessed by any component in the plugin.
 * 
 * Usage in any component:
 *   import "."  // Import the components directory
 *   
 *   ComboBox {
 *       model: MenuProvider.species_menu_model
 *   }
 * 
 * This eliminates prop drilling and parent chain navigation.
 */
QtObject {
    id: menuProvider
    
    // ===================================================================
    // MENU LAYERS - Load once from QGIS project
    // ===================================================================
    
    property var species_menu_layer: qgisProject.mapLayersByName("species_menu")[0]
    property var abundance_layer: qgisProject.mapLayersByName("abundance_menu")[0]
    
    // ===================================================================
    // MENU MODELS - Populated once when component is created
    // ===================================================================
    
    property ListModel species_menu_model: ListModel {}
    property ListModel abundance_menu_model: ListModel {}
    
    // ===================================================================
    // INITIALIZATION
    // ===================================================================
    
    Component.onCompleted: {
        populateAbundanceMenuModel()
        populateSpeciesMenuModel()
    }
    
    // ===================================================================
    // PRIVATE METHODS
    // ===================================================================
    
    function populateAbundanceMenuModel() {
        if (!abundance_layer) {
            console.error("d5_menu_provider: Abundance menu layer not found")
            return
        }
        
        abundance_menu_model.clear()
        
        var iterator = LayerUtils.createFeatureIteratorFromExpression(abundance_layer, "data_text is not null")
        var count = 0
        while (iterator.hasNext()) {
            var feature = iterator.next()
            var label = feature.attribute("label_text") || ""
            var value = feature.attribute("data_text") || ""
            
            abundance_menu_model.append({
                "label": String(label),
                "value": String(value)
            })
            count++
        }
        iterator.close()  // CRITICAL: Always close iterator
        console.log("d5_menu_provider: Loaded", count, "abundance menu entries")
    }
    
    function populateSpeciesMenuModel() {
        if (!species_menu_layer) {
            console.error("d5_menu_provider: Species menu layer not found")
            return
        }
        
        species_menu_model.clear()
        
        var iterator = LayerUtils.createFeatureIteratorFromExpression(species_menu_layer, "cat is not null")
        var count = 0
        while (iterator.hasNext()) {
            var feature = iterator.next()
            var labelText = feature.attribute("label_text") || ""
            
            species_menu_model.append({
                "label": String(labelText),
                "value": String(labelText)
            })
            count++
        }
        iterator.close()  // CRITICAL: Always close iterator
        console.log("d5_menu_provider: Loaded", count, "species menu entries")
    }
}
