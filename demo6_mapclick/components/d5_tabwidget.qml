import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.qfield  
import org.qgis
import Theme  
import "qrc:/qml" as QFieldItems

Rectangle {
    id: tabWidget
    // Properties
    property string currentPlotId: ""
    property bool plotFound: false  // Initially false - header will be invisible until a plot is loaded

    property var species_layer : get_layer_by_name("species")
    property var species_menu_layer : get_layer_by_name("species_menu")
    property var abundance_layer : get_layer_by_name("abundance_menu")

    // species menu entries: general
    ListModel {
        id: species_menu_model
    }

    // species menu entries: kraut
    ListModel {
        id: species_herb_menu_model
    }

    // species menu entries: moos
    ListModel {
        id: species_moss_menu_model
    }

    // abundance menu entries
    ListModel {
        id: abundance_menu_model
    }
    

    // Import centralized style
    Loader {
        id: styleLoader
        source: "d5_plugin_style.qml"
    }
    
    // Use centralized style instead of hardcoded values
    property var style: styleLoader.item
    
    // Computed style properties with fallbacks (cleaner than inline fallbacks)
    // cream color applies to what is behind the tabs, creating an outline effect
    color: style ? style.primaryBackground : "#ffecd1" 
    readonly property int tabHeight: style ? style.tabWidget.tabHeight : 40
    readonly property color activeColor: style ? style.tabWidget.tabActiveBackground : "#6baa75"
    readonly property color inactiveColor: style ? style.tabWidget.tabInactiveBackground : "#333333"
    readonly property color activeTextColor: style ? style.tabWidget.tabActiveText : "#333333"
    readonly property color tabTextColor: style ? style.tabWidget.tabText : "#ffffff"
    readonly property color pageBackgroundColor: style ? style.tabWidget.contentBackground : "#f0f0f0"
    readonly property color titleTextColor: style ? style.tabWidget.titleColor : "white"
    readonly property int layoutSpacing: style ? style.layout.defaultSpacing : 10

    // UI Constants
    
    readonly property int fontSize_title: style ? style.fontSizeTitle : 20
    readonly property int fontSize_normal: style ? style.fontSizeNormal : 16
    readonly property int fontSize_tabs: style ? style.tabWidget.fontSizeTabs : 18
    readonly property int defaultSpacing: style ? style.layout.defaultSpacing : 10

    // Model for tab names and stratum codes
    ListModel {
        id: tabModel
        ListElement { name: "Header"; stratum_code: ""; }
        ListElement { name: "Tree 1"; stratum_code: "1B"; }
        ListElement { name: "Tree 2"; stratum_code: "2B"; }
        ListElement { name: "Shrub"; stratum_code: "1S"; }
        ListElement { name: "Herb"; stratum_code: "KS"; }
        ListElement { name: "Moss"; stratum_code: "MS"; }
    }    

    
    TabBar {
        id: tabBar
        width: parent.width
        height: tabWidget.tabHeight
        Repeater {
            model: tabModel
            TabButton {
                id: tabButton
                anchors.verticalCenter: parent.verticalCenter
                height: parent.tabHeight
                background: Rectangle { color: tabButton.checked ? tabWidget.activeColor : tabWidget.inactiveColor }
                contentItem: Text {
                    text: model.name // Set text of tab from the tabModel property
                    color: tabButton.checked ? tabWidget.activeTextColor : tabWidget.tabTextColor
                    font.pixelSize: tabWidget.fontSize_tabs
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }   
        // Connect TabBar's currentIndex to SwipeView's currentIndex
        onCurrentIndexChanged: {
            if (swipeView.currentIndex !== currentIndex) {  // Prevent infinite loops
                swipeView.currentIndex = currentIndex;
            }
        }     
    } // tabBar


    SwipeView {
        id: swipeView
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: tabWidget.defaultSpacing
        clip: true  // This ensures only the current page is visible
        interactive: true
         // Ensure SwipeView is interactive
        currentIndex: tabBar.currentIndex
         // Connect SwipeView's currentIndex to TabBar's currentIndex
        onCurrentIndexChanged: {
            if (tabBar.currentIndex !== currentIndex) { // Prevent infinite loops
                tabBar.currentIndex = currentIndex;
            }
        }       
        // Header Tab Content (first item)
        ScrollView {
            id: headerScrollView
            contentWidth: headerPageLoader.width
            contentHeight: headerPageLoader.item ? headerPageLoader.item.implicitHeight : 0
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            
            Loader {
                id: headerPageLoader
                source: "d5_headerpage.qml"
                width: headerScrollView.availableWidth
                
                onLoaded: {
                    if (item) {
                        // Pass properties to the loaded component
                        item.currentPlotId = Qt.binding(function() { return tabWidget.currentPlotId })
                        item.plotFound = Qt.binding(function() { return tabWidget.plotFound })
                    } else {
                        console.error("Failed loading headerpage.qml")
                    }
                }
            }
        }

        // Strata Tab Content (remaining items)
        Repeater {
            model: tabModel.count - 1  // Exclude the first item (Header)
            
            Component.onCompleted: {
                console.log("Repeater created with model count:", model)
                console.log("Expected strata pages:", (tabModel.count - 1))
            }
            
            ScrollView {
                id: strataScrollView
                contentWidth: strataPageLoader.width
                contentHeight: strataPageLoader.item ? strataPageLoader.item.implicitHeight : 0
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                
                Component.onCompleted: {
                    console.log("ScrollView created for index:", index)
                }
                
                Loader {
                    id: strataPageLoader
                    source: "d5_stratapage.qml"
                    width: strataScrollView.availableWidth
                    
                    Component.onCompleted: {
                        console.log("Loader created for index:", index, "source:", source)
                    }
                    
                    onLoaded: {
                        console.log("Loader onLoaded called for index:", index)
                        if (item) {
                            // Pass properties to the loaded component
                            var stratumCode = tabModel.get(index + 1).stratum_code
                            item.strataName = tabModel.get(index + 1).name  // +1 to skip Header
                            item.currentPlotId = Qt.binding(function() { return tabWidget.currentPlotId })
                            item.plotFound = Qt.binding(function() { return tabWidget.plotFound })
                            item.style = Qt.binding(function() { return tabWidget.style })
                            item.abundance_menu_model = Qt.binding(tabWidget.get_abundance_menu_model)
                            item.species_menu_model = Qt.binding(function() { return tabWidget.get_species_menu_model(stratumCode) })
                            item.species_layer = Qt.binding(function() { return tabWidget.species_layer })
                            
                            // Add this loader to the tracking array
                            console.log("Registering strata page loader for:", item.strataName)
                            console.log("Current strataPageLoaders array length before push:", tabWidget.strataPageLoaders.length)
                            tabWidget.strataPageLoaders.push(strataPageLoader)
                            console.log("Current strataPageLoaders array length after push:", tabWidget.strataPageLoaders.length)
                            
                            // Check if we have a pending plot update waiting for loaders to be ready
                            tabWidget.checkPendingPlotUpdate()
                        } else {
                            console.error("Failed loading d4_stratapage.qml for", tabModel.get(index + 1).name)
                        }
                    }
                }
            }
        }       
    }
    
    // Handler methods to be called from parent component
    function handlePlotLoaded(plotId) {
        currentPlotId = plotId
        plotFound = true
        
        // Clear existing content and load new plot data
        clearAndLoadPlotContent(plotId)
    }
    
    function handlePlotNotFound(plotId) {
        currentPlotId = plotId
        plotFound = false
        
        // Clear or show error content
        clearContent()
    }
    
    function clearAndLoadPlotContent(plotId) {
        // First clear the header page content
        if (headerPageLoader.item && headerPageLoader.item.clearForm) {
            headerPageLoader.item.clearForm()
        }
        
        // Then load the new plot data
        if (headerPageLoader.item && headerPageLoader.item.load) {
            headerPageLoader.item.load()
        }
        
        // Update strata tabs (for future implementation)
        updateStrataTabsForPlot(plotId)
        
        console.log("Content cleared and loaded for plot:", plotId)
    }
    
    function updateContentForPlot(plotId) {
        
        // Header updates automatically through property bindings (currentPlotId and plotFound)
        // The headerTitle and headerStatus Text elements are bound to these properties
        
        // For now, we'll just log that the content should be updated
        // In a real implementation, you would:
        // 1. Query the database/layer for plot-specific data
        // 2. Update each strata tab with relevant data
        console.log("Content updated for all tabs with plot:", plotId)
    }
    
    // Track strata page loaders for direct access
    property var strataPageLoaders: []  // Initialize as empty array
    property string pendingPlotUpdate: ""  // Store plot ID if update is called before loaders are ready

    function updateStrataTabsForPlot(plotId) {
        
        // If loaders aren't ready yet, store the plot ID for later
        if (strataPageLoaders.length === 0) {
            pendingPlotUpdate = plotId
            return
        }
        
        // Clear any pending update since we're processing now
        pendingPlotUpdate = ""
        
        // Update each strata tab with plot-specific data
        for (var i = 0; i < strataPageLoaders.length; i++) {
            var strataPageLoader = strataPageLoaders[i]
            if (strataPageLoader && strataPageLoader.item) {
                
                // Call updateForPlot on each strata page
                if (strataPageLoader.item.updateForPlot) {
                    strataPageLoader.item.updateForPlot(plotId, true)
                } else {
                    console.warn("updateForPlot function not found on strata page:", strataPageLoader.item.strataName)
                }
            } else {
                console.warn("Strata page loader", i, "not loaded or item is null")
            }
        }
    }
    
    function checkPendingPlotUpdate() {
        // Check if we have a pending plot update and all expected loaders are ready
        // We expect 5 strata loaders (tabModel has 6 items: Header + 5 strata)
        var expectedLoaderCount = 5
        if (pendingPlotUpdate !== "" && strataPageLoaders.length === expectedLoaderCount) {
            var plotId = pendingPlotUpdate
            pendingPlotUpdate = ""
            updateStrataTabsForPlot(plotId)
        }
    }
    
    function clearContent() {
        // Clear the header page content
        if (headerPageLoader.item && headerPageLoader.item.clearForm) {
            headerPageLoader.item.clearForm()
        }
        
        // Header status will show "Plot not found" automatically through property bindings
        // When plotFound becomes false, headerStatus shows "Plot not found"
        // When currentPlotId changes, headerTitle updates accordingly
        
        // Also update strata pages to show "plot not found" state
        // Use false for plotExists parameter to trigger "not found" state
        for (var i = 0; i < strataPageLoaders.length; i++) {
            var strataPageLoader = strataPageLoaders[i]
            if (strataPageLoader && strataPageLoader.item && strataPageLoader.item.updateForPlot) {
                strataPageLoader.item.updateForPlot(currentPlotId, false)  // false = plot not found
            }
        }
        
        console.log("Content cleared for plot:", currentPlotId)
    }
    
    // Initialize models once when component is created
    Component.onCompleted: {
        // Don't reset strataPageLoaders here - they're already registered by the loaders
        // Initialize only the pending plot update
        pendingPlotUpdate = ""
        populateAbundanceMenuModel()
        populateSpeciesMenuModels()
    }
    
    function populateAbundanceMenuModel() {
        if (!abundance_layer) {
            console.error("Abundance layer not found")
            return
        }
        
        // Clear existing model
        abundance_menu_model.clear()
        
        // Get all features from abundance_menu layer
        var iterator = LayerUtils.createFeatureIteratorFromExpression(abundance_layer, "label_text is not null")
        var count = 0
        while (iterator.hasNext()) {
            var feature = iterator.next()
            var label = feature.attribute("label_text") || ""
            var value = feature.attribute("data_text") || ""
            
            // Ensure data types are strings to avoid ListModel role issues
            abundance_menu_model.append({
                "label": String(label),
                "value": String(value)
            })
            count++
        }
        iterator.close()
        
    }
    
    function populateSpeciesMenuModels() {
        if (!species_menu_layer) {
            console.error("Species menu layer not found")
            return
        }
        
        
        // Clear existing models
        species_menu_model.clear()
        species_herb_menu_model.clear()
        species_moss_menu_model.clear()
        
        // Get all features from species_menu layer
        var iterator = LayerUtils.createFeatureIteratorFromExpression(species_menu_layer, "cat is not null")
        var totalCount = 0
        while (iterator.hasNext()) {
            var feature = iterator.next()
            var labelText = feature.attribute("label_text") || ""
            var stratum = feature.attribute("cat") || ""
            
            // Ensure data types are strings to avoid ListModel role issues
            var entry = {
                "label": String(labelText),
                "value": String(labelText)
            }
            
            // Add to appropriate model based on stratum
            switch(String(stratum)) {
                case 'KS':  // Herb
                    species_herb_menu_model.append(entry)
                    break
                case 'MS':  // Moss
                    species_moss_menu_model.append(entry)
                    break
                default:    // General (trees, shrubs)
                    species_menu_model.append(entry)
                    break
            }
            totalCount++
        }
        iterator.close()
        
    }

    function get_abundance_menu_model() {
        return abundance_menu_model
    }
    
    function get_species_menu_model(stratumCode) {
        // Return appropriate species model based on stratum
        switch(stratumCode) {
            case 'KS':  // Herb layer
                return species_herb_menu_model
            case 'MS':  // Moss layer
                return species_moss_menu_model
            case '1B':  // Tree 1
            case '2B':  // Tree 2  
            case '1S':  // Shrub
            default:
                return species_menu_model  // General species model for trees/shrubs
        }
    }
    
    function get_layer_by_name(name){
        // retrieve a QgsMapLayer from the project by its name
        // qgisProject is the global variable that holds the current qfield project
        var layers = ProjectUtils.mapLayers(qgisProject)
        for (var layer_id in layers){
            var l = layers[layer_id]
            if (l.name == name){
                return l
            }
        }
        // qgisProject.mapLayersByName(name)
        return null
    }
}