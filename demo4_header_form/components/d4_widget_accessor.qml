pragma Singleton
import QtQuick

// Widget Value Accessor Factory
// Creates a simple setValue/getValue API for all widget types used in the header form.
// This reduces the need for type checking and reduces proclivity for type errors
// in the load and save functions.

// a note to Python programmers: these javascript functions internally store
// their parameters.  The returned function closures remember these parameters without#
// their being saved explicitly in object properties.

QtObject {
    /**
     * Create accessor for a text input widget
     */
    function createTextAccessor(textEditItem) {
        return {
            getValue: function() {
                return textEditItem ? (textEditItem.text || "") : ""
            },
            setValue: function(value) {
                if (textEditItem) {
                    textEditItem.text = value || ""
                }
            }
        }
    }
    
    /**
     * Create accessor for a numeric range widget (d4_range.qml)
     * Handles the loader chain complexity
     */
    function createRangeAccessor(loaderItem) {
        // Helper to navigate loader chain
        function getRangeItem(loader) {
            if (!loader) return null
            
            if (loader.item) {
                // Try direct access first (loader.item might BE the range component)
                if (loader.item.realValue !== undefined) {
                    return loader.item
                }
                
                // Try nested access (loader.item.item)
                if (loader.item.item && loader.item.item.realValue !== undefined) {
                    return loader.item.item
                }
            }
            
            return null
        }
        
        return {
            getValue: function() {
                var rangeItem = getRangeItem(loaderItem)
                if (rangeItem && rangeItem.realValue !== undefined) {
                    return rangeItem.realValue
                }
                return 0
            },
            setValue: function(value) {
                var rangeItem = getRangeItem(loaderItem)
                if (rangeItem && rangeItem.realValue !== undefined) {
                    rangeItem.realValue = value || 0
                }
            }
        }
    }
}
