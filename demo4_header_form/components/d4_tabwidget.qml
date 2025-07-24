import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tabWidget
    // Properties
    property string currentPlotId: ""
    property bool plotFound: false  // Initially false - header will be invisible until a plot is loaded

    // Import centralized style
    Loader {
        id: styleLoader
        source: "d4_plugin_style.qml"
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


    ListModel {
        id: tabModel
        ListElement { name: "Header";}
        ListElement { name: "Tree 1";}
        ListElement { name: "Tree 2";}
        ListElement { name: "Shrub";}
        ListElement { name: "Herb";}
        ListElement { name: "Moss";}
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
                source: "d4_headerpage.qml"
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
            
            ScrollView {
                id: strataScrollView
                contentWidth: strataPageLoader.width
                contentHeight: strataPageLoader.item ? strataPageLoader.item.implicitHeight : 0
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                
                Loader {
                    id: strataPageLoader
                    source: "d4_stratapage.qml"
                    width: strataScrollView.availableWidth
                    
                    onLoaded: {
                        if (item) {
                            // Pass properties to the loaded component
                            item.strataName = tabModel.get(index + 1).name  // +1 to skip Header
                            item.currentPlotId = Qt.binding(function() { return tabWidget.currentPlotId })
                            item.plotFound = Qt.binding(function() { return tabWidget.plotFound })
                            item.style = Qt.binding(function() { return tabWidget.style })
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
    
    function updateStrataTabsForPlot(plotId) {
        // Future implementation: update each strata tab with plot-specific data
        // For now, just log that strata tabs should be updated
        console.log("Strata tabs should be updated for plot:", plotId)
    }
    
    function clearContent() {
        // Clear the header page content
        if (headerPageLoader.item && headerPageLoader.item.clearForm) {
            headerPageLoader.item.clearForm()
        }
        
        // Header status will show "Plot not found" automatically through property bindings
        // When plotFound becomes false, headerStatus shows "Plot not found"
        // When currentPlotId changes, headerTitle updates accordingly
        
        console.log("Content cleared for plot:", currentPlotId)
    }
}