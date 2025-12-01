  
/*
  This plugin component is just a rectangle.
  It's size is the full size of it's parent widget, which
  is the map canvas.
  The Rectangle contains a Text Component with a title string.
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

    Column {
        anchors.centerIn: parent
        spacing: 20
        
        // Search bar component loaded from searchbar.qml
        Loader {
            id: searchBarLoader
            width: pluginFrame.width * 0.8
            height: 100
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
            id: tabFrame
            width: pluginFrame.width * 0.8
            height: 100
            color: "#6baa75"
            
            Text {
                id: messageBox
                anchors.centerIn: parent
                text: "Demo2 Search Bar"
                color: "white"
                font.pixelSize: 16
            }
        }
    } 

}