import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

/* demo1_hello demonstrates the structure of a basic hello world QField project level plugin.  
   It depends on qml files loaded from the directory ./components.
   Installation:   
   The components directory must be configured as an attachment directory in your qfield project.
   Put this file and the components directory in the same directory as your qfield project. 
   Use the qfieldsync plugin to synchronise the project.  
   Your plugin updates will be delivered along with your project updates.*/

Item {  
  id: plugin
  parent: iface.mapCanvas() 
  anchors.fill: parent 

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/d1_plugin_component.qml')
    
    onStatusChanged: {
      if (pluginLoader.status === Loader.Loading) {
        iface.logMessage("Loader status: Loading component from " + source)
      } else if (pluginLoader.status === Loader.Ready) {
        iface.logMessage("Loader status: Ready - Component loaded successfully")
      } else if (pluginLoader.status === Loader.Error) {
        iface.logMessage("Loader status: ERROR - Failed to load component: " + pluginLoader.sourceComponent.errorString())
      } else if (pluginLoader.status === Loader.Null) {
        iface.logMessage("Loader status: Null - No component loaded")
      }
    }
    
    onLoaded: {
      iface.logMessage("Loader: Component successfully loaded and instantiated")
    }
  }  

  // open and close the Plugin
  QfToolButton {
    id: pluginButton
    bgcolor: Theme.darkGray
    iconSource: Theme.getThemeVectorIcon('ic_camera_photo_black_24dp')
    iconColor: Theme.mainColor
    round: true

    onClicked: {
      if (pluginLoader.active){
          iface.logMessage("Unloading d1_plugin_compononent.qml")
      }
      else {
          iface.logMessage("Loading d1_plugin_component.qml")
      }
      pluginLoader.active = !(pluginLoader.active)
    }
  }

  // load the buttons
  Component.onCompleted: {
    iface.addItemToPluginsToolbar(pluginButton)

  }

} 
