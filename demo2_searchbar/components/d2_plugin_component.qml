  
/*
  This plugin component contains a column layout holding a search bar and a Rectangle frame used to display messages.
  It's size is the full size of it's parent widget, which
  is the pluginLoader in demo2_searchbar.
  */
 
 // Qt Alignment Properties are imported from QtQuick
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

Rectangle {
    // The pluginFrame defines a vanilla colored frame over which the 
    // ColumnLayout will be centered.
    // If the pluginFrame was transparent, we could eliminate it 
    // and use the ColumnLayout as the root element.
    // But then we would see the map canvas behind the plugin, and we want to block it out.
    id: pluginFrame
    anchors.fill: parent
    color: PluginTheme.vanilla

    ColumnLayout {
        anchors.centerIn: parent
        // define width on the column layout to control child element widths
        width: parent.width * 0.8
        spacing: 20
        
        // Search bar component loaded from searchbar.qml
        Loader {
            id: searchBarLoader
            width: parent.width
            height: 100
            Layout.alignment: Qt.AlignHCenter
            source: "d2_searchbar.qml"

            // Handle signals from the loaded searchbar component
            onLoaded: {
                if (item) {
                    item.plotNotFound.connect(function(plotId) {
                        messageBox.text = "Plot not found: " + plotId
                    })
                    item.plotLoaded.connect(function(plotId) {
                        messageBox.text = "Plot loaded: " + plotId
                    })
                }else{
                    iface.logMessage("No item - component not loaded")
                }
            }
        }
       
        // This Rectangle displays texts for this demo.  It is also a layout placeholder for the tab widget we will add later.
        Rectangle {
            id: textFrame
            width: parent.width
            height: 100
            color: PluginTheme.green
            Layout.alignment: Qt.AlignHCenter

    
            Text {
                id: messageBox
                anchors.centerIn: parent
                text: "Demo 2 Search Bar"
                color: PluginTheme.white
                font.pixelSize: 16
            }
        }
    } 

}