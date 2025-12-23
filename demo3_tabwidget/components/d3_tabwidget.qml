import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tabWidget
    color: PluginTheme.white
    // Properties
    property string plotId: parent.plotId

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
                    color: tabButton.checked ? PluginTheme.green : PluginTheme.white
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
                id: headerFrame
                color: PluginTheme.white
                border.color: PluginTheme.white
                border.width: 1
                width: headerPage.width
                
                Column {
                    id: headerColumn
                    anchors.fill: parent
                    anchors.margins: tabWidget.defaultSpacing
                    spacing: tabWidget.defaultSpacing   
                    
                    Text {
                        id: headerTitle

                        text: "Plot: " + plotId 
                        font.pixelSize: 24
                        font.bold: true
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
                    color: PluginTheme.white
                    border.color: "black"
                    border.width: 1
                    width: strataPage.width

                    
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
                            // Simple reactive text that updates when plotId changes
                            text: "Tab content - Plot: " + tabWidget.plotId
                        }
                    }
                }
            }
        }       
    }
        
}