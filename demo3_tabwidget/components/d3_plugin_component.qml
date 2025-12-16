  
/*
  This plugin component is a rectangle containing a header rectangle and a tab widget.
  It is designed to be the full size of its parent widget, which is the map canvas
  The header rectangle will contain a title message with the plot id and a close button.
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
    color: PluginTheme.vanilla

     // Signal to the parent component to deactivate the plugin
    signal closed()
    
    function setPlotId(plotId) {
        titleBarLoader.item.setPlotId(plotId)
        tabWidgetLoader.item.setPlotId(plotId)
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width
        spacing: 20

        // Title bar component loaded from d3_titlebar.qml
        Loader {
            id: titleBarLoader
            width: pluginFrame.width 
            height: 100  // Fixed height for title bar
            source: "d3_titlebar.qml"
        }

        // Close button is inside the title bar.  Pass along its closed signal to the plugin.
        Connections {
            target: titleBarLoader.item
            function onClosed() {
                closed()
            }
        }
        
        // TabWidget to display search results
        Loader {
            id: tabWidgetLoader
            width: pluginFrame.width
            height: pluginFrame.height - titleBarLoader.height - 20
            source: "d3_tabwidget.qml"
        }
    }
}