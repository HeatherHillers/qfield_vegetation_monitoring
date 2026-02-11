import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems
/* 
  demo3_tabwidget demonstrates the use of a cool swipey tab widget.   
*/



Item {  
  id: plugin
  parent: iface.mainWindow().contentItem
  anchors.fill: parent 
  // Map Selection: 1. Hold a reference to the map canvas
  property var mapCanvas: iface.mapCanvas() 
  // Map Selection: 2. add the pointHandler to the plugin
  property var pointHandler: iface.findItemByObjectName("pointHandler")

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/d3_plugin_component.qml')
  }  

  Connections {
    target: pluginLoader.item
    function onClosed() {
      pluginLoader.active = false
    }
  }  

  Component.onCompleted: {
 
    // Map Selection: 3. register the point handler and define its callback
    pointHandler.registerHandler("demo3_tabwidget", (point, type, interactionType) => {
      // do not use the clicked signal, as it will conflict with qfield's own map click handling
      // qfield.exe doesnt register doubleclicks or point and hold properly, but ios does.
      // https://github.com/opengisch/QField/issues/6866
      
      var shouldHandle = (Qt.platform.os === "windows" && interactionType === "clicked") ||
                         (Qt.platform.os !== "windows" && interactionType === "doubleClicked")
      if (shouldHandle) {
        // create a pair of point that'll represent a buffer area within which features are to be searched. 
        let tl = mapCanvas.mapSettings.screenToCoordinate(Qt.point(point.x - 20, point.y - 20))
        let br = mapCanvas.mapSettings.screenToCoordinate(Qt.point(point.x + 20, point.y + 20))

        let expression = "intersects(geom_from_wkt('POLYGON(("+tl.x+" "+tl.y+", "+br.x+" "+tl.y+", "+br.x+" "+br.y+", "+tl.x+" "+br.y+", "+tl.x+" "+tl.y+"))'), $geometry)"
        let it = LayerUtils.createFeatureIteratorFromExpression(qgisProject.mapLayersByName("plots")[0], expression)
        if (it.hasNext()) {
          const feature = it.next()
          console.log(feature.id)
          it.close()
          pluginLoader.active = true
          // pass the plot id to the plugin component
          pluginLoader.item.plotId = feature.attribute("plot_id")
          return true
        }
        it.close();
      }
      return false
    });
  }

  // Map Selection: 4. Deregister the point handler on destruction (should be on project close)
  Component.onDestruction: {
    pointHandler.deregisterHandler("demo3_tabwidget");
  }
} 
