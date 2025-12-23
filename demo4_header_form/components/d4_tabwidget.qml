import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tabWidget
    color: PluginTheme.vanilla
    // Properties
    property string plotId: parent.plotId
    property var strataPages: []  // Array to store references to loaded strata pages
    
    // UI Constants
    
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
        height: 40
        Repeater {
            model: tabModel
            TabButton {
                id: tabButton
                anchors.verticalCenter: parent.verticalCenter
                height: tabBar.height
                background: Rectangle { color: "black"}
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
            contentHeight: headerPageLoader.item ? headerPageLoader.item.implicitHeight : 0
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            
            Loader {
                id: headerPageLoader
                property string plotId: tabWidget.plotId
                source: "d4_headerpage.qml"
                width: headerScrollView.availableWidth
            }
        }

        // Strata Tab Content (remaining items)
        Repeater {
            id: strataRepeater
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
                    property string plotId: tabWidget.plotId
                    property string strataName: tabModel.get(index + 1).name  // +1 to skip header
                    source: "d4_stratapage.qml"
                    width: strataScrollView.availableWidth
                    
                    onLoaded: {
                        // store reference to loaded strata page
                        tabWidget.strataPages.push(item)
                    }
                }
            }
        }       
    }
      
}