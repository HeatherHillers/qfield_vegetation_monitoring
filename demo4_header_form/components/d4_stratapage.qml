import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Theme  

/**
 * Strata Page Component
 * 
 * Individual strata page for vegetation monitoring tabs (Tree 1, Tree 2, Shrub, Herb, Moss)
 * Integrates with the centralized plugin styling system.
 */
Rectangle {
    id: strataPage
    
    // Properties to be set by parent
    property string strataName: "Strata"
    property string currentPlotId: ""
    
    
    // Computed style properties with fallbacks
    color: PluginTheme.white
    border.color: PluginTheme.red
    border.width: 1
    
    Column {
        id: strataColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 10
        
        Text {
            text: strataPage.strataName + " Details"
            font.pixelSize: PluginTheme.titleFontSize
            font.bold: true
            color: Theme.darkGray
        }
        
        Text {
            id: strataDetailsText
            text: "Tab content - Plot: " + strataPage.currentPlotId
            color: Theme.darkGray
        }
        
        // Placeholder for future form fields specific to this strata
        Text {
            text: "Form fields for " + strataName + " data entry will go here"
            color: Theme.darkGray
            font.italic: true
        }
    }
    
    // Handler methods to be called from parent component
    function setPlotId(plotId) {
        currentPlotId = plotId
        console.log("StrataPage (" + strataName + "): Updated for plot", plotId)
    }
}
