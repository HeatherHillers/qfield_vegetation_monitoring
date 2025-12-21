import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Theme

Rectangle {
    id: tabWidget
    color: PluginTheme.vanilla
    // Properties
    property string plotId: ""
    property var strataPages: []  // Array to store references to loaded strata pages
    
    // Model for tab names and stratum codes
    ListModel {
        id: tabModel
        ListElement { name: "Header"; stratum_code: ""; }
        ListElement { name: "Tree 1"; stratum_code: "1B"; }
        ListElement { name: "Tree 2"; stratum_code: "2B"; }
        ListElement { name: "Shrub"; stratum_code: "1S"; }
        ListElement { name: "Herb"; stratum_code: "KS"; }
        ListElement { name: "Moss"; stratum_code: "MS"; }
    }    

    TabBar {
        id: tabBar
        width: parent.width
        height: 40
        Repeater {
            model: tabModel
            TabButton {
                id: tabButton
                anchors.verticalCenter: parent.verticalCenter
                height: tabBar.height
                background: Rectangle { color: Theme.darkGray}
                contentItem: Text {
                    text: model.name // Set text of tab from the tabModel property
                    color: tabButton.checked ? PluginTheme.green : PluginTheme.white
                    font.pixelSize: 18
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
        anchors.margins: 10
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
            contentHeight: headerPageLoader.item.implicitHeight
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            
            Loader {
                id: headerPageLoader
                source: "d5_headerpage.qml"
                width: headerScrollView.availableWidth
                
                onLoaded: {
                    item.plotId = Qt.binding(function() { return tabWidget.plotId })
                }
            }
        }

        // Strata Tab Content (remaining items)
        Repeater {
            id: strataRepeater
            model: tabModel.count - 1  // Exclude the first item (Header)
            
            ScrollView {
                id: strataScrollView
                contentWidth: strataPageLoader.width
                contentHeight: 0 //strataPageLoader.item.implicitHeight
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                
                Loader {
                    id: strataPageLoader
                    source: "d5_stratapage.qml"
                    width: strataScrollView.availableWidth
                    
                    onLoaded: {
                        item.strataCode = tabModel.get(index + 1).stratum_code  // +1 to skip header
                        item.strataName = tabModel.get(index + 1).name  // +1 to skip header
                        
                        // Use binding so plotId updates automatically when tabWidget.plotId changes
                        item.plotId = Qt.binding(function() { return tabWidget.plotId })
                        // Store reference to the loaded item
                        tabWidget.strataPages.push(item)
                    }
                }
            }
        }       
    }
}