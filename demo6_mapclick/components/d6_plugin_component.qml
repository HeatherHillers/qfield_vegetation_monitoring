  
/*
  This plugin component is a rectangle containing a search bar and a tab widget.
  It is designed to be the full size of its parent widget, which is the map canvas
  The Search Bar selection will modify the title in the "Header" tab of the TabWidget.
  */
 
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

Rectangle {
    anchors.fill: parent
    
    // Import centralized style
    Loader {
        id: styleLoader
        source: "d6_plugin_style.qml"
    }
    
    // Use centralized style instead of hardcoded values
    property var style: styleLoader.item
    // Computed style properties with fallbacks (cleaner than inline fallbacks)
    color: style ? style.primaryBackground: "#ffecd1"  
    readonly property int searchBarHeight: style ? style.searchBar.height : 40
    
    function setPlotId(plotId) {
        if (searchBarComponent) {
            searchBarComponent.setPlotId(plotId)
        } else {
            console.error("SearchBar component not loaded yet")
        }
    }
    // Properties to store references to loaded components
    property var searchBarComponent: null
    property var tabWidgetComponent: null

    Column {
        anchors.centerIn: parent
        width: parent.width * 0.8   // Shared width for all child components
        height: parent.height * 0.8 // Shared height constraint for all child components


        // Search bar component loaded from searchbar.qml
        Loader {
            id: searchBarLoader
            width: parent.width 
            height: searchBarHeight
            source: "d6_searchbar.qml"

            // Handle signals from the loaded searchbar component
            onLoaded: {
                if (item) {
                    searchBarComponent = item
                    // Connect signals if tabwidget is ready
                    if (tabWidgetComponent) {
                        connectSearchbarSignals()
                    }
                } else {
                    console.error("SearchBar failed to load")
                }
            }
        }
        
        // TabWidget to display search results
        Loader {
            id: tabWidgetLoader
            width: parent.width  // Use parent (Column) width
            height: parent.height - searchBarLoader.height // Fill remaining Column space
            source: "d6_tabwidget.qml"

            onLoaded: {
                if (item) {
                    tabWidgetComponent = item
                    // Now that tabwidget is loaded, connect searchbar signals if searchbar is ready
                    if (searchBarComponent) {
                        connectSearchbarSignals()
                    }
                } else {
                    console.log("TabWidget failed to load")
                }
            }
        }
    }
    
    // Helper function to connect signals - called when both components are loaded
    function connectSearchbarSignals() {
        if (searchBarComponent && tabWidgetComponent) {

            searchBarComponent.plotNotFound.connect(function(plotId) {
                tabWidgetComponent.handlePlotNotFound(plotId)
            })
            
            searchBarComponent.plotLoaded.connect(function(plotId) {
                tabWidgetComponent.handlePlotLoaded(plotId)
            })
            searchBarComponent.layerLoadError.connect(function(message) {
                console.error("Layer load error:", message)
            })
        }
    }
}