import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems
/* This is the sidecar plugin for the demo6_mapclick project.  */

Item {  
  id: plugin
  parent: iface.mapCanvas() 
  anchors.fill: parent 
  property var mapCanvas: iface.mapCanvas() // Reference to the QField map canvas
  // 1. add the pointHandler to the plugin
  property var pointHandler: iface.findItemByObjectName("pointHandler")

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/d6_plugin_component.qml')
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
    // 2. register the point handler
    pointHandler.registerHandler("demo6_mapclick", (point, type, interactionType) => {
      if (interactionType === "clicked") {
        // create a pair of point that'll represent a buffer area within which features are to be searched
        let tl = mapCanvas.mapSettings.screenToCoordinate(Qt.point(point.x - 20, point.y - 20))
        let br = mapCanvas.mapSettings.screenToCoordinate(Qt.point(point.x + 20, point.y + 20))

        let expression = "intersects(geom_from_wkt('POLYGON(("+tl.x+" "+tl.y+", "+br.x+" "+tl.y+", "+br.x+" "+br.y+", "+tl.x+" "+br.y+", "+tl.x+" "+tl.y+"))'), $geometry)"
        let it = LayerUtils.createFeatureIteratorFromExpression(qgisProject.mapLayersByName("plots")[0], expression)
        if (it.hasNext()) {
          // you've got a feature, play with it! :)
          const feature = it.next()
          console.log(feature.id)
          it.close()
          pluginLoader.active = true
          pluginLoader.item.setPlotId(feature.attribute("plot_id"))
          return true
        }
        it.close();
      }

      return false
    });
  }

  Component.onDestruction: {
    // Deregister bookmark handler
    pointHandler.deregisterHandler("demo6_mapclick");
  }

} 
