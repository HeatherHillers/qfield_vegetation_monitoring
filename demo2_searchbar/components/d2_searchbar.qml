/*
  This is the search bar for the vegetation monitoring plugin.
  It allows the user to search for plots by their Plot Id.
  The component retrieves the layer "plots" from the project and uses it to populate a ComboBox
  with plot_ids of all features in the layer, retrieved from the layer by expression.

  The component is styled using a RowLayout that contains a Label and a ComboBox.
  The ComboBox is editable and has autocompletion enabled.

  Theoretically, it should be filtered by the current view extent, but this is not implemented yet.
  We should also have the default selection set to the current plot, if any.
  This will come in a later demo.
  */
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

Rectangle {
  id: searchBar
  property var plotsLayer: null  // Initialize as null, set in Component.onCompleted
  
  // plot list
  ListModel {
    id: plot_model
  }

  // Signals to communicate with parent component
  signal plotNotFound(string plotId)
  signal plotLoaded(string plotId)
  signal layerLoadError(string message)
  
  // style
  width: parent.width
  height: 100
  color: "#6baa75"


  RowLayout {
    anchors.centerIn: parent
    width: parent.width * 0.8
    spacing: 10

    Label {
      id: title
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignBottom
      text: "Plot: "
      color: "white"
      font.pixelSize: 24
      font.bold: true
    }
    ComboBox {
      id: plotInput
      font.pixelSize: 24
      model: plot_model
      textRole: "label"
      valueRole: "label"
      editable: true
      Layout.preferredWidth: 200
      
      onActivated: {
        search_plot()
      }
      onAccepted: {
        search_plot()
      }
      function search_plot(){
        var plot_id = this.currentText;
        if (!plot_id || plot_id.trim() === "") {
          plotNotFound("Empty plot ID");
          return;
        }
        
        if (!plotsLayer) {
          plotNotFound("Layer not available");
          return;
        }
        
        try {
          var expression = "plot_id = '" + plot_id + "'";
          var feature_iterator = LayerUtils.createFeatureIteratorFromExpression(plotsLayer, expression);

          if (!feature_iterator.hasNext()){
            // error - emit signal to parent
            plotNotFound(plot_id);
            feature_iterator.close();
            return;
          } else{
            // success - emit signal to parent
            plotLoaded(plot_id);
          }
          feature_iterator.close();
        } catch (error) {
          console.log("Error searching for plot:", error);
          plotNotFound(plot_id + " (Error: " + error + ")");
        }
      }
    } 
  }

  Component.onCompleted: {
    // Initialize layer and populate model after component is fully loaded
    plotsLayer = get_layer_by_name("plots")
    populatePlotModel()
  }
  function get_layer_by_name(name){
    // retrieve a QgsMapLayer from the project by its name
    // qgisProject is the global variable that holds the current qfield project
    var layers = ProjectUtils.mapLayers(qgisProject)
    for (var layer_id in layers){
      var l = layers[layer_id]
      if (l.name == name){
        return l
      }
    }
    // qgisProject.mapLayersByName(name)
    return null
  }

  function populatePlotModel() {
    if (!plotsLayer) {
      console.log("Warning: plots layer not found")
      layerLoadError("Plots layer not found in project")
      return
    }
    
    try {
      plot_model.clear()
      
      // Get all features from the plots layer : there is no function to get all features, so we use an expression
      // so you have to use a catchall expression
      var feature_iterator = LayerUtils.createFeatureIteratorFromExpression(plotsLayer, "plot_id IS NOT NULL");
      var count = 0
      
      while (feature_iterator.hasNext()) {
        var feature = feature_iterator.next()
        var plot_id = feature.attribute("plot_id")
        if (plot_id) {
          plot_model.append({"label": plot_id})
          count++
        }
      }
      feature_iterator.close()
      
      console.log("Loaded " + count + " plots into search model")
      
      if (count === 0) {
        layerLoadError("No plots found with plot_id attribute")
      }
    } catch (error) {
      console.log("Error populating plot model:", error)
      layerLoadError("Error loading plot data: " + error)
    }
  }
} // /searchBar Rectangle




