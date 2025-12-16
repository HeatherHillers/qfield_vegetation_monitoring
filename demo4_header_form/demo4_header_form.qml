import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems
/*  demo4_header_form demonstrates feature insert and update.
    A hidden layer plot_header has been added to the project.
    When the plugin is activated and the tab widget is opened with its plot_id,
    if a row does not exist in plot_header for that plot_id, an empty row will be created. 
    When the user edits a header element in the header tab form, an update occurs automatically on the row.
    There is no save button necessary.  Eliminating the save button prevents the user from losing changes 
    if they forget to save before closing the form.
    */

Item {  
  id: plugin
  parent: iface.mapCanvas() 
  anchors.fill: parent 

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/d4_plugin_component.qml')
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
