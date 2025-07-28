import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

/**
 * Page Component
 * 
 * Individual strata page for vegetation monitoring tabs (Tree 1, Tree 2, Shrub, Herb, Moss)
 * Integrates with the centralized plugin styling system.
 */
Rectangle {
    id: strataPage
    
    // Properties to be set by parent
    property string strataName: "Strata"
    property string currentPlotId: ""
    property bool plotFound: false
    property var style: null
    property var abundance_menu_model: null
    property var species_menu_model: null
    property var species_layer: null 
    
    // Keep track of created entries for easy cleanup
    property var createdEntries: [] 

    // Load centralized styling
    property color contentBackground: style ? style.secondaryBackground : "#6baa75" 
    property color titleColor: style ? style.secondaryText : "#ffffff"   
    property int defaultSpacing: style ? style.layout.defaultSpacing : 15
    property int fontSize: style ? style.fontSizeLarge : 18
    property int labelSize: style ? style.fontSizeSmall : 14
    property int menuLabelSize: style ? style.fontSizeSmall: 14

    property color buttonColor: style ? style.tertiaryBackground : "#333333" // Default button color if style is not loaded

    // Watch for plot changes and refresh content
    onCurrentPlotIdChanged: {
        if (species_layer && currentPlotId !== "") {
            updateForPlot(currentPlotId, plotFound)
        } else {
            console.log("d5_stratapage: Not updating for", strataName, "- species_layer:", !!species_layer, "currentPlotId:", currentPlotId)
        }
    }
    
    // Also watch for species_layer changes in case that comes first
    onSpecies_layerChanged: {
        if (species_layer && currentPlotId !== "") {
            updateForPlot(currentPlotId, plotFound)
        }
    }
    
    // Component to load species entry from external file
    Component {
        id: speciesEntryComponent
        
        Rectangle {
            id: speciesEntryWrapper
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            
            // Properties that can be set from outside
            property var plotId: null
            property var feature: null
            property var stratum: null
            property var abundance_menu_model: null
            property var species_menu_model: null
            property var species_layer: null
            
            // Callback for deletion requests from child
            property var onDeleteRequestedFromChild: null
            
            Loader {
                id: speciesLoader
                source: "d5_species.qml"
                anchors.fill: parent
                
                onLoaded: {
                    if (item) {
                        updateLoadedProperties()
                    } else {
                        console.error("d5_stratapage: Failed to load d5_species.qml")
                    }
                }
                
                function updateLoadedProperties() {
                    if (item) {
                        item.plotId = speciesEntryWrapper.plotId
                        item.feature = speciesEntryWrapper.feature
                        item.species_layer = speciesEntryWrapper.species_layer
                        item.stratum = speciesEntryWrapper.stratum
                        item.abundance_menu_model = speciesEntryWrapper.abundance_menu_model
                        item.species_menu_model = speciesEntryWrapper.species_menu_model
                        
                        // Set up deletion callback
                        item.onDeleteRequested = function() {
                            if (speciesEntryWrapper.onDeleteRequestedFromChild) {
                                speciesEntryWrapper.onDeleteRequestedFromChild()
                            }
                        }
                    }
                }
            }
            
            // Property watchers to update loaded component when wrapper properties change
            onPlotIdChanged: {
                if (speciesLoader.item) speciesLoader.updateLoadedProperties()
            }
            onFeatureChanged: {
                if (speciesLoader.item) speciesLoader.updateLoadedProperties()
            }
            onSpecies_layerChanged: {
                if (speciesLoader.item) speciesLoader.updateLoadedProperties()
            }
            onStratumChanged: {
                if (speciesLoader.item) speciesLoader.updateLoadedProperties()
            }
            onAbundance_menu_modelChanged: {
                if (speciesLoader.item) speciesLoader.updateLoadedProperties()
            }
            onSpecies_menu_modelChanged: {
                if (speciesLoader.item) speciesLoader.updateLoadedProperties()
            }
        }
    }
    
    // Computed style properties with fallbacks
    color: contentBackground
    border.color: style ? style.borderColor : "#ccc"
    border.width: style ? style.borderWidth : 1

                
    Column {
        id: strataColumn
        anchors.fill: parent
        anchors.margins: strataPage.defaultSpacing
        spacing: strataPage.defaultSpacing 
        
        Label {
            id: pageError
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Qt.AlignHCenter 
            visible: false
            color: strataPage.titleColor
            text: "Error Message"
            font.pixelSize: strataPage.fontSize
        }
        Label {
            id: pageTitle
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Qt.AlignHCenter 
            text: strataName
            color: strataPage.titleColor
            visible: true
            font.pixelSize: strataPage.fontSize
        }
        Button {
            id: addEntryButton
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            background: Rectangle { anchors.fill: parent;
                                    color: strataPage.buttonColor;
                                    radius: 10;}

            contentItem: Text {
                text: "New Entry" // Set text of tab from the tabModel property
                color: addEntryButton.pressed ? strataPage.titleColor : "white"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter 
                verticalAlignment: Text.AlignVCenter
            
            }
            onClicked: {
                strataPage.add_entry()
            }
        }    
        ColumnLayout {
            id: entriesLayout
            width: parent.width
            spacing: strataPage.defaultSpacing 
            visible: false // Initially hidden, will be shown when a plot is selected
                    // column layout functions

        }
    }
    
    // Function to update content when plot changes
    function updateForPlot(plotId, found) {
        currentPlotId = plotId
        plotFound = found
        pageTitle.text = plotId ? strataName  + " " + currentPlotId : strataName
        addEntryButton.visible = plotId && found // Show button only if plot is valid and found
        entriesLayout.visible = plotId && found
        pageError.visible = !(plotId && found)
        pageTitle.visible = !(plotId && found)
        if (!(plotId && found)) {
            console.log("d5_stratapage: No plot selected or plot not found - hiding entries")
            return
        }
        
        // Clear the species entries from entriesLayout
        for (var i = 0; i < createdEntries.length; i++) {
            if (createdEntries[i] && typeof createdEntries[i].destroy === "function") {
                createdEntries[i].destroy()
            }
        }
        createdEntries = [] // Reset the array
        
        // add existing entries to the layout
        var iterator = LayerUtils.createFeatureIteratorFromExpression(species_layer, "plot_id = '" + plotId + "' and stratum = '" + strataName + "'")
        while (iterator.hasNext()) {
            var feature = iterator.next()
            create_widget(plotId, feature)
        }
        iterator.close();
    }
    function add_entry(){
        
        // Validate required properties
        if (!species_layer) {
            console.error("d5_stratapage: Cannot add entry - species_layer is null")
            return
        }
        if (!currentPlotId) {
            console.error("d5_stratapage: Cannot add entry - currentPlotId is empty")
            return
        }
        
        species_layer.startEditing() // Use species_layer consistently
        var feature = FeatureUtils.createFeature(species_layer)
        
        // Validate feature creation
        if (!feature) {
            console.error("d5_stratapage: Failed to create new feature")
            species_layer.rollBack()
            return
        }
        
        feature.setAttribute("f_uid", StringUtils.createUuid().replace(/[\{\}]/g, ""))
        feature.setAttribute("plot_id", currentPlotId) // Use component properties
        feature.setAttribute("stratum", strataName)    // Use component properties
        feature.setAttribute("year", new Date().getFullYear())
        LayerUtils.addFeature(species_layer, feature)
        var commitSuccess = species_layer.commitChanges() // commit the changes to the layer
        
        if (!commitSuccess) {
            console.error("d5_stratapage: Failed to commit feature to database")
            species_layer.rollBack()
            return
        }

        // After commit, retrieve the feature with its permanent ID using the UUID
        var f_uid = feature.attribute("f_uid")
        
        var feature_iterator = LayerUtils.createFeatureIteratorFromExpression(species_layer, "f_uid = '" + f_uid + "'")
        if (feature_iterator.hasNext()) {
            var committedFeature = feature_iterator.next()
            feature_iterator.close()
            
            try {
                // Ensure entriesLayout is visible
                entriesLayout.visible = true
                pageTitle.visible = false
                
                create_widget(currentPlotId, committedFeature)
            } catch (createError) {
                console.error("d5_stratapage: Error creating new entry:", createError)
            }
        } else {
            console.error("d5_stratapage: Failed to retrieve committed feature")
            feature_iterator.close()
            return
        }
    }
    function create_widget(plotId, feature){
        // Validate inputs
        if (!feature) {
            console.error("d5_stratapage: Cannot create widget - feature is null")
            return
        }
        if (!plotId) {
            console.error("d5_stratapage: Cannot create widget - plotId is null")
            return
        }
        if (!entriesLayout) {
            console.error("d5_stratapage: Cannot create widget - entriesLayout is null")
            return
        }
        
        // Create a new species entry widget and add it to the entriesLayout
        try {
            // Create the component without initial properties
            var entryLoader = speciesEntryComponent.createObject(entriesLayout)
            
            if (entryLoader == null) {
                console.error("d5_stratapage: Failed to create species entry component");
                return;
            }
            
            // Add to tracked entries for cleanup
            createdEntries.push(entryLoader)
            
            // Set properties individually
            entryLoader.plotId = plotId
            entryLoader.feature = feature
            entryLoader.species_layer = species_layer
            entryLoader.stratum = strataName
            entryLoader.abundance_menu_model = abundance_menu_model
            entryLoader.species_menu_model = species_menu_model
            
            // Add a deletion callback so the component can notify us when it's deleted
            entryLoader.onDeleteRequestedFromChild = function() {
                remove_widget(entryLoader)
            }
            
        } catch (error) {
            console.error("d5_stratapage: Error creating widget:", error)
        }
    }
    
    function remove_widget(entryLoader) {
        console.log("d5_stratapage: Removing widget from layout")
        
        // Remove from tracked entries array
        var index = createdEntries.indexOf(entryLoader)
        if (index > -1) {
            createdEntries.splice(index, 1)
        }
        
        // Destroy the component
        if (entryLoader && typeof entryLoader.destroy === "function") {
            entryLoader.destroy()
        }
        
        console.log("d5_stratapage: Widget removed, remaining entries:", createdEntries.length)
    }
    function error(message){
        pageError.text = message
        pageError.visible = true
        entriesLayout.visible = false
        pageTitle.visible = false
        addEntryButton.visible = false; // Hide the add entry button
        console.error("d5_stratapage: Error -", message)
    }

}

