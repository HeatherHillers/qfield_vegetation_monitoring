import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.qfield  
import org.qgis
import Theme  
import "qrc:/qml" as QFieldItems

Rectangle {
    id: speciesEntryFrame
    Layout.fillWidth: true    // Makes the Rectangle use the width allocated by ColumnLayout
    Layout.preferredHeight: 60 // Set a specific preferred height for each entry
                                // Or, base it on content: e.g., speciesEntryTitle.implicitHeight + 20
    Loader {
        id: styleLoader
        source: "d6_plugin_style.qml"
    }
    property var style: styleLoader.item
    color: style ? style.secondaryBackground : "#6baa75" // Default color if style is not loaded
    property int spacing: (style && style.layout) ? style.layout.defaultSpacing : 10 // Default spacing if style is not loaded
    property color buttonColor: style ? style.tertiaryBackground : "#333333" // Default button color if style is not loaded
    property int fontSize: style ? style.fontSizeNormal : 16 // Default font size if style is not loaded
    // passed props
    property var plotId: null
    property var feature: null // Reference to the feature object
    property var species_layer: null // Reference to the species layer 
    property var stratum: null // Stratum type (e.g., 'KS', 'MS')
    property var abundance_menu_model: null
    property var species_menu_model: null
    
    // Callback function for deletion - to be set by parent
    property var onDeleteRequested: null
    
    Component.onCompleted: {
        // Initialization will be handled by property watchers
        // Also try immediate initialization in case properties are already set
        Qt.callLater(function() {
            // Check if properties exist and are valid before initializing
            // Use try-catch to handle any reference errors gracefully
            try {
                if (speciesEntryFrame && speciesEntryFrame.species_layer && speciesEntryFrame.feature) {
                    initializeComponent()
                }
            } catch (error) {
                console.log("d6_species: Properties not yet available, will wait for property watchers")
            }
        })
    }
    
    // Watch for species_layer property changes and initialize when available
    onSpecies_layerChanged: {
        if (species_layer && feature) {
            initializeComponent()
        }
    }
    
    // Watch for feature property changes and initialize when available  
    onFeatureChanged: {
        if (species_layer && feature) {
            initializeComponent()
        }
    }
    
    function initializeComponent() {
        // Validate required properties
        if (!species_layer) {
            console.error("d6_species: species_layer property is required")
            return
        }
        if (!feature) {
            console.error("d6_species: feature property is required")
            return
        }
        
        
        // Load feature data if available
        load_feature_data(feature)
    }
    RowLayout {
        id: speciesEntryLayout
        anchors.fill: parent
        //anchors.margins: speciesEntryFrame.spacing
        ComboBox {
            id: species_combo
            font.pixelSize: speciesEntryFrame.fontSize
            model: species_menu_model
            textRole: "label"
            valueRole: "value"
            Layout.preferredWidth: 300
            Layout.alignment: Qt.AlignVCenter // Vertically center the ComboBox

            editable: true
            property var field_name: fieldNames.species // attribute name for species
            onAccepted: {
                save_feature(field_name, currentText);
            }
            onActivated: {
                save_feature(field_name, currentText);
            }
        } 
        ComboBox {
            id: abundance_combo
            font.pixelSize: speciesEntryFrame.fontSize
            Layout.preferredWidth: 350
            model: abundance_menu_model
            textRole: "label"
            valueRole: "value"
            property var field_name: fieldNames.abundance // attribute name for abundance
            Layout.alignment: Qt.AlignVCenter // Vertically center the ComboBox
            onAccepted: { // This signal is usually for when the user confirms an entry, e.g., by pressing Enter in an editable ComboBox
            // Or when a selection is made and the popup closes.
            // abundance_combo.currentValue refers to the 'value' property of the selected item from the model.
            if (abundance_combo.currentIndex !== -1) { // Check if an item is actually selected
                save_feature(field_name, abundance_combo.currentValue);
            }
            }
            onActivated: function(index) { // This signal is emitted when an item is selected from the popup.
            if (index >= 0 && abundance_combo.model && index < abundance_combo.model.count) {
                var selectedItemValue = abundance_combo.model.get(index).value;
                save_feature(field_name, selectedItemValue);
            }
            }

        }
        TextField {
            id: comment_Input
            font.pixelSize: speciesEntryFrame.fontSize
            property var field_name: fieldNames.comment // Name for the comment attribute
            Layout.alignment: Qt.AlignVCenter // Vertically center the ComboBox
            onEditingFinished: {
                save_feature(field_name, comment_Input.text);
            }


        }
        Button {
            id: deleteButton
            Layout.alignment: Qt.AlignVCenter // Vertically center the button
            background: Rectangle { anchors.fill: parent;
                                    color: speciesEntryFrame.buttonColor;
                                    radius: 10;}

            contentItem: Text {
                text: "X" // Delete button text
                color: "white"
                font.pixelSize: speciesEntryFrame.fontSize
                horizontalAlignment: Text.AlignHCenter 
                verticalAlignment: Text.AlignVCenter
            
            }
            onClicked: {
                console.log("Delete button clicked for feature ID:", feature ? feature.id : "null")
                
                // Delete from database first
                if (feature && species_layer) {
                    try {
                        console.log("Starting deletion process...")
                        species_layer.startEditing()
                        
                        // Verify feature exists before attempting deletion
                        var featureExists = species_layer.getFeature(feature.id)
                        if (featureExists && featureExists.id > 0) {  // Check if feature has valid ID instead of isValid()
                            var deleteSuccess = species_layer.deleteFeature(feature.id)
                            console.log("Delete operation result:", deleteSuccess)
                            
                            if (deleteSuccess) {
                                var commitSuccess = species_layer.commitChanges()
                                console.log("Commit result:", commitSuccess)
                                
                                if (commitSuccess) {
                                    console.log("Successfully deleted species entry with ID:", feature.id)
                                } else {
                                    console.error("Failed to commit deletion:", species_layer.commitErrors())
                                    species_layer.rollBack()
                                    return // Don't remove UI if database deletion failed
                                }
                            } else {
                                console.error("Failed to delete feature from layer")
                                species_layer.rollBack()
                                return // Don't remove UI if database deletion failed
                            }
                        } else {
                            console.log("Feature no longer exists in layer, skipping database deletion")
                        }
                    } catch (error) {
                        console.error("Error during deletion:", error)
                        try {
                            species_layer.rollBack()
                        } catch (rollbackError) {
                            console.error("Error during rollback:", rollbackError)
                        }
                        return // Don't remove UI if there was an error
                    }
                }
                
                // Notify parent to remove this widget from the layout
                if (onDeleteRequested && typeof onDeleteRequested === "function") {
                    console.log("Calling parent deletion callback")
                    onDeleteRequested()
                } else {
                    console.warn("No deletion callback available, component may not be properly removed")
                }
            }
        }

    } // /RowLayout

    function load_feature_data(feature){
        var speciesValue = feature.attribute("species") || "";
        species_combo.currentIndex = -1; // Reset/default to no selection

        // Try to find and select the item in the model (with null check)
        if (species_combo.model && species_combo.model.count > 0) {
            for (var i = 0; i < species_combo.model.count; i++) {
                if (species_combo.model.get(i).label === speciesValue) {
                    species_combo.currentIndex = i;
                    break;
                }
            }
        }

        // If no item was found in the model, but the ComboBox is editable,
        // set the editText to the feature's value.
        if (species_combo.currentIndex === -1 && species_combo.editable) {
            species_combo.editText = speciesValue;
        }
        comment_Input.text = feature.attribute("comment") || "";
        // Set abundance_combo based on its value
        var abundanceValue = feature.attribute("abundance");
        abundance_combo.currentIndex = -1; // Default to no selection
        if (abundanceValue !== null && abundanceValue !== undefined) {
            if (abundance_combo.model && abundance_combo.model.count > 0) {
                for (var i = 0; i < abundance_combo.model.count; i++) {
                    if (abundance_combo.model.get(i).value === abundanceValue) {
                        abundance_combo.currentIndex = i;
                        break;
                    }
                }
            }
        }
    }
    function save_feature(field_name, value){
        // never trust a field index.
        var field_index = feature.fields.indexOf(field_name);
        if (!species_layer || !feature) {
            console.error("Cannot save: missing species_layer or feature")
            return
        }
        
        try {
            species_layer.startEditing()
            species_layer.changeAttributeValue(feature.id, field_index, value)
            species_layer.commitChanges()
            feature = species_layer.getFeature(feature.id)
            console.log("Saved field", field_index, "with value:", value)
            console.log("Saved feature:", feature.id, "Field index:", field_index, "Value:", value)
            console.log("Feature f_uid:", feature.attribute("f_uid"))
            console.log("Feature plot_id:", feature.attribute("plot_id"))
            console.log("Feature year:", feature.attribute("year"))
            console.log("Feature stratum:", feature.attribute("stratum"))
            console.log("Feature species:", feature.attribute("species"))
            console.log("Feature comment:", feature.attribute("comment"))
            console.log("Feature abundance:", feature.attribute("abundance"))
        } catch (error) {
            console.error("Error saving feature:", error)
            species_layer.rollBack() // Rollback changes on error
        }
    }
    
    // RECOMMENDATION: Define field name constants
    readonly property QtObject fieldNames: QtObject {
        readonly property string species: "species"
        readonly property string abundance: "abundance" 
        readonly property string comment: "comment"
    }
} // /speciesEntryFrame
