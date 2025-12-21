import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

/**
 * Demo5: Species Entry Feature Insert and Update, Delete
 * 
 * Adds the strata page forms to the vegetation monitoring demo.
 *
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
    source: Qt.resolvedUrl('./components/d5_plugin_component.qml')
  }  

  Connections {
    target: pluginLoader.item
    function onClosed() {
      pluginLoader.active = false
    }
  }  


  Component.onCompleted: {
    // Register map click handler for opening plugin on plot click
    pointHandler.registerHandler("demo5_strata_pages", (point, type, interactionType) => {
      // Platform-specific handling:
      // - Desktop (windows): Use single click
      // - Mobile (iOS/Android): Use double-click (single click conflicts with QField's map interaction)
      // Note: Desktop QField doesn't register double-clicks properly, but mobile does
      // See: https://github.com/opengisch/QField/issues/6866
      
      var shouldHandle = (Qt.platform.os === "windows" && interactionType === "clicked") ||
                         (Qt.platform.os !== "windows" && interactionType === "doubleClicked")
      
      if (shouldHandle) {
        // Create buffer area around click point for spatial query
        let tl = mapCanvas.mapSettings.screenToCoordinate(Qt.point(point.x - 20, point.y - 20))
        let br = mapCanvas.mapSettings.screenToCoordinate(Qt.point(point.x + 20, point.y + 20))

        // Find plots intersecting the buffer area
        let expression = "intersects(geom_from_wkt('POLYGON(("+tl.x+" "+tl.y+", "+br.x+" "+tl.y+", "+br.x+" "+br.y+", "+tl.x+" "+br.y+", "+tl.x+" "+tl.y+"))'), $geometry)"
        let plotsLayer = qgisProject.mapLayersByName("plots")[0]
        let it = LayerUtils.createFeatureIteratorFromExpression(plotsLayer, expression)
        
        if (it.hasNext()) {
          const feature = it.next()
          it.close()  // CRITICAL: Always close iterator to prevent crashes
          
          // Open plugin with selected plot
          pluginLoader.active = true
          pluginLoader.item.plotId = feature.attribute("plot_id")
          return true  // Signal that click was handled
        }
        it.close()  // CRITICAL: Close even when no features found
      }
      return false  // Click not handled by this plugin
    })
  }

  Component.onDestruction: {
    // Clean up: Deregister handler when plugin is destroyed
    pointHandler.deregisterHandler("demo5_strata_pages")
  }
}