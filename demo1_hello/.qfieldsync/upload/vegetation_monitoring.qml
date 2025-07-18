import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems
/* This is the sidecar plugin for the bio_okomonitoring project.  
   It depends on components in the directory ./components.
   All components must be in the components directory to be recognised by QField.
   (The directory does not need to be called components)
   Installation:  Add the components directory as an attachment directory in your qfield project.
   Put this file and the components directory in the same directory as your qfield project. And use the qfieldsync plugin to deliver it with your project updates.*/
Item {  
  id: plugin
  parent: iface.mapCanvas() 
  anchors.fill: parent 

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/plugincomponent.qml')
  }  

  // open and close the Plugin
  QfToolButton {
    id: pluginButton
    bgcolor: Theme.darkGray
    iconSource: Theme.getThemeVectorIcon('ic_camera_photo_black_24dp')
    iconColor: Theme.mainColor
    round: true

    onClicked: {
      iface.logMessage("Plugin component loaded now")
      pluginLoader.active = !(pluginLoader.active)
    }
  }

  // load the buttons
  Component.onCompleted: {
    
    iface.addItemToPluginsToolbar(pluginButton)
  }

} 
