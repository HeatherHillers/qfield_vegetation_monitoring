  
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
    id: pluginFrame
    anchors.fill: parent
    property color background_color: "#ffecd1"
    property color text_color: "#6baa75"
    color: background_color

    // Properties to store references to loaded components
    property var searchBarComponent: null
    property var tabWidgetComponent: null

    Column {
        anchors.centerIn: parent
        spacing: 20
        
        
        // Search bar component loaded from searchbar.qml
        Loader {
            id: searchBarLoader
            width: pluginFrame.width * 0.8
            height: 100  // Fixed height for search bar
            source: "d3_searchbar.qml"

            // Handle signals from the loaded searchbar component
            onLoaded: {
                if (item) {
                    searchBarComponent = item
                    
                    // Connect searchbar signals to plugin frame handlers
                    item.plotNotFound.connect(function(plotId) {
                        // Forward to tabwidget if it's loaded
                        if (tabWidgetComponent) {
                            tabWidgetComponent.handlePlotNotFound(plotId)
                        }
                    })
                    item.plotLoaded.connect(function(plotId) {
                        // Forward to tabwidget if it's loaded
                        if (tabWidgetComponent) {
                            tabWidgetComponent.handlePlotLoaded(plotId)
                        }
                    })
                }else{
                    iface.logMessage("No item - searchbar component not loaded")
                }
            }
        }
        
        // TabWidget to display search results
        Loader {
            id: tabWidgetLoader
            width: pluginFrame.width * 0.8
            height: pluginFrame.height * 0.6
            source: "d3_tabwidget.qml"

            Component.onCompleted: {
                console.log("TabWidget Loader created, attempting to load d3_tabwidget.qml")
            }

            onLoaded: {
                console.log("TabWidget Loader onLoaded triggered, item:", item)
                if (item) {
                    tabWidgetComponent = item
                    console.log("TabWidget loaded successfully")
                } else {
                    console.log("TabWidget failed to load")
                }
            }
        }
    }
}