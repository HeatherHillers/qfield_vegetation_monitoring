import QtQuick

// Data model defining all form fields and their configuration
QtObject {
    id: formDataModel
    
    // Comment/text field configuration
    readonly property var commentFields: [
        { id: "comment", label: "Comments (max 255 characters)", attributeIndex: 4, fieldType: "text", maxLength: 255 }
    ]
    
    // Field configuration structure
    readonly property var deckungFields: [
        { id: "t1_cover", label: "1. Canopy", attributeIndex: 5, stepSize: 5 },
        { id: "t2_cover", label: "2. Canopy", attributeIndex: 6, stepSize: 5 },
        { id: "s_cover", label: "Shrub Layer", attributeIndex: 7, stepSize: 5 },
        { id: "h_cover", label: "Herb Layer", attributeIndex: 8, stepSize: 5 },
        { id: "m_cover", label: "Moss Layer", attributeIndex: 9, stepSize: 5 },
        { id: "tm_cover", label: "Total Sphagnum", attributeIndex: 10, stepSize: 5 },
        { id: "wp_cover", label: "Water Plants", attributeIndex: 11, stepSize: 5 },
        { id: "indicators", label: "Indicator Species", attributeIndex: 17, stepSize: 5 }
    ]
    
    readonly property var vegetationHeightFields: [
        { id: "t1_h", label: "1. Canopy", attributeIndex: 12, stepSize: 5 },
        { id: "t2_h", label: "2. Canopy", attributeIndex: 13, stepSize: 5 },
        { id: "s_h", label: "Shrub Layer", attributeIndex: 19, stepSize: 1, isDecimal: true }
    ]
    
    readonly property var areaPercentageFields: [
        { id: "ob_percent", label: "Open Water", attributeIndex: 14, stepSize: 5 },
        { id: "ow_percent", label: "Open Ground", attributeIndex: 15, stepSize: 5 },
        { id: "th_percent", label: "Dead Wood > 10%", attributeIndex: 16, stepSize: 5 }
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
    
    // Helper function to find field by ID
    function getFieldById(fieldId) {
        const allFields = getAllFields()
        return allFields.find(field => field.id === fieldId)
    }
}
