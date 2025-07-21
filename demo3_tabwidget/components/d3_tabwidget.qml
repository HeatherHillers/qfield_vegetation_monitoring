import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tabWidget
    
    // Properties
    property string currentPlotId: ""
    property bool plotFound: false
    property color search_bar_main_color: "#6baa75"

    // UI Constants
    readonly property int tabHeight: 40
    readonly property int fontSize_title: 20
    readonly property int fontSize_normal: 16
    readonly property int fontSize_tabs: 18
    readonly property int defaultSpacing: 10

    ListModel {
        id: tabModel
        ListElement { name: "Header";}
        ListElement { name: "Tree 1";}
        ListElement { name: "Tree 2";}
        ListElement { name: "Shrub";}
        ListElement { name: "Herb";}
        ListElement { name: "Moss";}
    }    

    color: "#f0f0f0"
    
    TabBar {
        id: tabBar
        width: parent.width
        height: tabWidget.tabHeight
        Repeater {
            model: tabModel
            TabButton {
                id: tabButton
                anchors.verticalCenter: parent.verticalCenter
                height: tabWidget.tabHeight
                background: Rectangle { color: "black"}
                contentItem: Text {
                    text: model.name // Set text of tab from the tabModel property
                    color: tabButton.checked ? search_bar_main_color : "white"
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
            id: headerPage
            
            Rectangle {
                color: "white"
                border.color: "#ccc"
                border.width: 1
                width: headerPage.width
                height: Math.max(headerPage.height, headerColumn.height + 20)
                
                Column {
                    id: headerColumn
                    anchors.centerIn: parent
                    spacing: tabWidget.defaultSpacing
                    
                    Text {
                        id: headerTitle
                        text: currentPlotId ? "Plot: " + currentPlotId : "No plot selected"
                        font.pixelSize: tabWidget.fontSize_title
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        id: headerStatus
                        text: plotFound ? "Plot found and loaded" : "Plot not found"
                        font.pixelSize: tabWidget.fontSize_normal
                        color: plotFound ? "green" : "red"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // Strata Tab Content (remaining items)
        Repeater {
            id: strataRepeater
            model: tabModel.count - 1  // Exclude the first item (Header)
            
            ScrollView {
                id: strataPage
                
                Rectangle {
                    color: "white" 
                    border.color: "#ccc"
                    border.width: 1
                    width: strataPage.width
                    height: Math.max(strataPage.height, strataColumn.height + 20)
                    
                    Column {
                        id: strataColumn
                        anchors.fill: parent
                        anchors.margins: tabWidget.defaultSpacing
                        spacing: tabWidget.defaultSpacing   
                        
                        Text {
                            text: tabModel.get(index + 1).name + " Details"  // +1 to skip Header
                            font.pixelSize: tabWidget.fontSize_tabs
                            font.bold: true
                        }
                        
                        Text {
                            id: strataDetailsText
                            // Simple reactive text that updates when currentPlotId changes
                            text: "Tab content - Plot: " + (tabWidget.currentPlotId || "None selected")
                        }
                    }
                }
            }
        }       
    }
    
    // Handler methods to be called from parent component
    function handlePlotLoaded(plotId) {
        console.log("TabWidget: Plot loaded -", plotId)
        currentPlotId = plotId
        plotFound = true
        
        // Update content based on the loaded plot
        updateContentForPlot(plotId)
    }
    
    function handlePlotNotFound(plotId) {
        console.log("TabWidget: Plot not found -", plotId)
        currentPlotId = plotId
        plotFound = false
        
        // Clear or show error content
        clearContent()
    }
    
    function updateContentForPlot(plotId) {
        console.log("Updating content for plot:", plotId)
        
        // Header updates automatically through property bindings (currentPlotId and plotFound)
        // The headerTitle and headerStatus Text elements are bound to these properties
        
        // For now, we'll just log that the content should be updated
        // In a real implementation, you would:
        // 1. Query the database/layer for plot-specific data
        // 2. Update each strata tab with relevant data
        
        console.log("Content updated for all tabs with plot:", plotId)
    }
    
    function clearContent() {
        console.log("Clearing content for:", currentPlotId)
        
        // Header clears automatically through property bindings
        // When plotFound becomes false, headerStatus shows "Plot not found"
        // When currentPlotId changes, headerTitle updates accordingly
        
        console.log("Content cleared for plot:", currentPlotId)
    }
}