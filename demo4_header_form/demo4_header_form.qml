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

  property var mapCanvas: iface.mapCanvas() 
  property var pointHandler: iface.findItemByObjectName("pointHandler")

  Loader {
    id: pluginLoader
    active: false
    anchors.fill: parent
    source: Qt.resolvedUrl('./components/d4_plugin_component.qml')
  }  

  Connections {
    target: pluginLoader.item
    function onClosed() {
      pluginLoader.active = false
    }
  }  


  Component.onCompleted: {
 
    // Map Selection: 3. register the point handler and define its callback
    pointHandler.registerHandler("demo4_header_form", (point, type, interactionType) => {
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
    pointHandler.deregisterHandler("demo4_header_form");
  }

} 
