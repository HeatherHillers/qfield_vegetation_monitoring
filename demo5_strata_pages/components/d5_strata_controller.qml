import QtQuick

/**
 * Strata Controller
 * 
 * Mediates between data layer and UI for species entry management.
 * Manages the list of entry widgets without QField API details.
 * 
 * Responsibilities:
 * - Track created entry widgets
 * - Coordinate between data controller and UI
 * - Handle widget lifecycle (create/remove)
 * - No QField API calls - delegates to data controller
 */
QtObject {
    id: strataController
    
    // Reference to data controller
    property var dataController: null
    
    // Track created entry widgets
    property var entryWidgets: []
    
    // Signals
    signal widgetCreated(var widget)
    signal widgetRemoved(var widget)
    
    /**
     * Request creation of a new entry
     * Delegates to data controller
     */
    function createNewEntry() {
        if (!dataController) {
            return
        }
        
        dataController.createNewEntry()
    }
    
    /**
     * Register a widget in the tracking list
     */
    function registerWidget(widget) {
        entryWidgets.push(widget)
        widgetCreated(widget)
    }
    
    /**
     * Unregister and destroy a widget
     */
    function removeWidget(widget) {
        var index = entryWidgets.indexOf(widget)
        if (index > -1) {
            entryWidgets.splice(index, 1)
        }
        
        if (widget && typeof widget.destroy === "function") {
            widget.destroy()
        }
        
        widgetRemoved(widget)
    }
    
    /**
     * Clear all widgets
     */
    function clearAllWidgets() {
        
        for (var i = 0; i < entryWidgets.length; i++) {
            if (entryWidgets[i] && typeof entryWidgets[i].destroy === "function") {
                entryWidgets[i].destroy()
            }
        }
        
        entryWidgets = []
    }
    
    /**
     * Get count of current widgets
     */
    function getWidgetCount() {
        return entryWidgets.length
    }
}
