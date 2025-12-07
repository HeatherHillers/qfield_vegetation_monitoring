import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems
/* demo2_searchbar demonstrates selection of features from a layer.  The user can select a plot
   either by selecting it from a dropdown list, or by clicking on it in the map canvas.
*/
  id: plugin
  parent: iface.mapCanvas() 
  anchors.fill: parent 

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/d2_plugin_component.qml')
  }  

  // open and close the Plugin
  QfToolButton {
    id: pluginButton
    bgcolor: Theme.darkGray
    iconSource: Theme.getThemeVectorIcon('ic_camera_photo_black_24dp')
    iconColor: Theme.mainColor
    round: true

    onClicked: {
      // removed logging information from demo1_hello
      pluginLoader.active = !(pluginLoader.active)
    }
  }

  // load the buttons
  Component.onCompleted: {
    iface.addItemToPluginsToolbar(pluginButton)
  }

} 
