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
    property var plotsLayer: null  // set in Component.onCompleted

    // Contents of plot search menu
    ListModel {
        id: plot_model
    }

    // Signals to communicate with parent component
    signal plotNotFound(string plotId)
    signal plotLoaded(string plotId)
    signal layerLoadError(string message)

    // Import centralized style
    Loader {
        id: styleLoader
        source: "d5_plugin_style.qml"
    }
    
    // Use centralized style instead of hardcoded values
    property var style: styleLoader.item
    
    // Computed style properties with fallbacks (cleaner than inline fallbacks)
    color: style ? style.searchBar.background : "#6baa75"
    readonly property color titleTextColor: style ? style.searchBar.titleColor : "white"
    readonly property int titleFontSize: style ? style.searchBar.titleFontSize : 20
    readonly property int inputFontSize: style ? style.searchBar.inputFontSize : 16
    readonly property int layoutSpacing: style ? style.layout.defaultSpacing : 10

    RowLayout {
        anchors.centerIn: parent
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: layoutSpacing

        Label {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            text: "Plot: "
            color: titleTextColor
            font.pixelSize: titleFontSize
            font.bold: true
        }
        ComboBox {
            font.pixelSize: inputFontSize
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
                    plotNotFound(plot_id + " (Error: " + error + ")");
                }
            }
        } 
    }

    Component.onCompleted: {
        plotsLayer = qgisProject.mapLayersByName("plots")[0]
        if (!plotsLayer) {
            layerLoadError("Plots layer not found in project")
            return
        }
        try {
            plot_model.clear()
            // Get all features from the plots layer : there is no function to get all features, so we use an expression
            // so you have to use a catchall expression
            var feature_iterator = LayerUtils.createFeatureIteratorFromExpression(plotsLayer, "plot_id IS NOT NULL");
            
            while (feature_iterator.hasNext()) {
                var feature = feature_iterator.next()
                var plot_id = feature.attribute("plot_id")
                if (plot_id) {
                    plot_model.append({"label": plot_id})
                }
            }
            feature_iterator.close()
            if (count === 0) {
                layerLoadError("No plots found with plot_id attribute")
            }
        } catch (error) {
            layerLoadError("Error loading plot data: " + error)
        }
    }
} // /searchBar Rectangle




