pragma Singleton
import QtQuick

// Data model defining all form fields and their configuration
QtObject {
    id: formDataModel
    
    // Comment/text field configuration
    readonly property var commentFields: [
        { id: "comment", label: "Comments (max 255 characters)", fieldType: "text", maxLength: 255 }
    ]
    
    readonly property var deckungFields: [
        { id: "t1_cover", label: "1. Canopy", stepSize: 5 },
        { id: "t2_cover", label: "2. Canopy", stepSize: 5 },
        { id: "s_cover", label: "Shrub Layer", stepSize: 5 },
        { id: "h_cover", label: "Herb Layer", stepSize: 5 },
        { id: "m_cover", label: "Moss Layer", stepSize: 5 },
        { id: "tm_cover", label: "Total Sphagnum", stepSize: 5 },
        { id: "wp_cover", label: "Water Plants", stepSize: 5 },
        { id: "indicators", label: "Indicator Species", stepSize: 5 }
    ]
    
    readonly property var vegetationHeightFields: [
        { id: "t1_h", label: "1. Canopy", stepSize: 5 },
        { id: "t2_h", label: "2. Canopy", stepSize: 5 },
        { id: "s_h", label: "Shrub Layer", stepSize: 1, isDecimal: true }
    ]
    
    readonly property var areaPercentageFields: [
        { id: "ob_percent", label: "Open Water", stepSize: 5 },
        { id: "ow_percent", label: "Open Ground", stepSize: 5 },
        { id: "th_percent", label: "Dead Wood > 10%",   stepSize: 5 }
    ]
    
    // Group box configurations
    readonly property var groupBoxes: [
        {
            id: "comments",
            title: "General Information",
            fields: commentFields
        },
        {
            id: "deckung",
            title: "Area Coverage (%)",
            fields: deckungFields
        },
        {
            id: "vegetation_height", 
            title: "Vegetation Height [m]",
            fields: vegetationHeightFields
        },
        {
            id: "area_percentage",
            title: "Misc. Coverage [%]", 
            fields: areaPercentageFields
        }
    ]
    
    // Helper function to get all fields as a flat array
    function getAllFields() {
        return commentFields.concat(deckungFields).concat(vegetationHeightFields).concat(areaPercentageFields)
    }
    
}
