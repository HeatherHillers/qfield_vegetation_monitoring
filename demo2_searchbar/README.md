# demo2_searchbar

This demo builds on demo1_hello.  It adds a menu that allows the user to select from all the objects in a project layer.  It then changes the title Text according to the selection.  You get a bit of interface, a bit of widgets, and a bit of signal handling.

## Features of the plugin

### Plugin Component

Adds a Loader for the search bar and handles signals from the searchbar, which are sent when an item is selected.  Updates the pluginTitle according to the searchBar selection.

### Searchbar Component

In the components directory there is a new component d2_searchbar.qml.  This component is loaded by d2_plugin_component.  The searchbar has signals which are emitted when a plot is selected.

### Get Layer By Name

The d2_searchbar.qml contains a function which queries the project for the layer named "plots" and returns the QgsVectorLayer object.

### Get Features By Expression

To populate the menu, the searchbar uses the LayerUtils function createFeatureIteratorFromExpression, using an expression that will retrieve all objects.

To search the feature for a plot id, the LayerUtils function createFeatureIteratorFromExpression is again used. 

Remember to always close the feature iterator.  Failure to do so will hang QField.

### Signal Handling

Enjoy the interaction between Feature Selection and the pluginTitle.  

## Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md

