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
Item {
  id: plugin
  parent: iface.mapCanvas() 
  anchors.fill: parent 
  // Map Selection: 1. Hold a reference to the map canvas
  property var mapCanvas: iface.mapCanvas() 
  // Map Selection: 2. add the pointHandler to the plugin
  property var pointHandler: iface.findItemByObjectName("pointHandler")

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

  Component.onCompleted: {
    // load the plugin button into the plugins toolbar
    iface.addItemToPluginsToolbar(pluginButton)
 
    // Map Selection: 3. register the point handler and define its callback
    pointHandler.registerHandler("demo2_searchbar", (point, type, interactionType) => {
      // do not use the clicked signal, as it will conflict with qfield's own map click handling
      if (interactionType === "doubleClicked") {
        // create a pair of point that'll represent a buffer area within which features are to be searched. 
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
          // pass the plot id to the plugin component
          pluginLoader.item.setPlotId(feature.attribute("plot_id"))
          return true
        }
        it.close();
      }
      return false
    });
  }

  // Map Selection: 4. Deregister the point handler on destruction (should be on project close)
  Component.onDestruction: {
    pointHandler.deregisterHandler("demo2_searchbar");
  }
} 
