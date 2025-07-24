import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    property bool plotFound: false
    
    // Load centralized styling
    property var style: null
    property var computedStyle: style?.tabWidget || {
        "contentBackground": "#f0f0f0",
        "titleColor": "#ffffff",
        "fontSizeTabs": 18
    }
    
    // Computed style properties with fallbacks
    color: computedStyle.contentBackground
    border.color: "#ccc"
    border.width: 1
    
    Column {
        id: strataColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: style?.layout?.defaultSpacing || 10
        spacing: style?.layout?.defaultSpacing || 10
        
        Text {
            text: strataPage.strataName + " Details"
            font.pixelSize: strataPage.computedStyle.fontSizeTabs
            font.bold: true
            color: strataPage.computedStyle.titleColor
        }
        
        Text {
            id: strataDetailsText
            text: "Tab content - Plot: " + (strataPage.currentPlotId || "None selected")
            color: strataPage.computedStyle.titleColor
        }
        
        // Placeholder for future form fields specific to this strata
        Text {
            text: plotFound ? 
                  "Form fields for " + strataName + " data entry will go here" :
                  "Select a plot to enter " + strataName + " data"
            color: strataPage.computedStyle.titleColor
            font.italic: true
        }
    }
    
    // Function to update content when plot changes
    function updateForPlot(plotId, found) {
        currentPlotId = plotId
        plotFound = found
        
        console.log("StrataPage (" + strataName + "): Updated for plot", plotId, "found:", found)
        
        // Here you would typically:
        // 1. Query database for existing strata data for this plot
        // 2. Populate form fields with existing data
        // 3. Enable/disable form based on plot found status
    }
}
