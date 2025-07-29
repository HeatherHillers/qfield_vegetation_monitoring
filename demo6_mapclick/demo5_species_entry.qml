import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems
/* This is the sidecar plugin for the demo5_species_entry project.  */

Item {  
  id: plugin
  parent: iface.mapCanvas() 
  anchors.fill: parent 

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/d5_plugin_component.qml')
  }  

  // open and close the Plugin
  QfToolButton {
    id: pluginButton
    bgcolor: Theme.darkGray
    iconSource: Theme.getThemeVectorIcon('ic_camera_photo_black_24dp')
    iconColor: Theme.mainColor
    round: true

    onClicked: {
      pluginLoader.active = !(pluginLoader.active)
    }
  }

  // load the buttons
  Component.onCompleted: {
    iface.addItemToPluginsToolbar(pluginButton)
  }

} 
