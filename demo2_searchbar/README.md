# demo2_searchbar

This demo builds on demo1_hello and demonstrates methods for feature selection.  

The user can now open the plugin by clicking on a plot point.  The id of the selected plot will be automatically loaded in the plugin.

The user can also manually open the plugin by clicking on the camera icon as before.

The Hello World Title box is now replaced with a drop down menu and a smaller text box.

The drop down menu is searchable and contains all plot ids.

If the user opens the plugin by clicking on the map, the plot id will be preselected in the drop down, and its plot id will be displayed in the text box.

If the user manually opened the plugin, or if the user wants to change the selection they can choose another plot from the drop down menu.  

Changing the selection changes the plot id shown in the box.

With this plugin in hand, you should be able to construct any kind of reporting plugin you would like to create.


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

### Using the QField MapCanvasPointHandler pointHandler Object

The clicking on the map part of the plugin is way in the front in demo2_mapclick.qml.  Here we use nirvn's example to register a pointHandler.  The function registered reacts to a click on the map by activating (opening) the pluginLoader and calling the setPlotId function on it's item (the d2_plugin_component).

### Passing the properties

the d2_plugin_component passes the plotId to the setPlotId function of the searchBarComponent, where it is needed.

### Setting the selection of a combobox by text

the setPlotId function of d2_searchbar then calls selectByIdentifier, which searches through the plotInput comboBox for an index with a label matching the plotId.  It sets the selection by setting the currentIndex.  This then triggers the onCurrentIndexChanged slot of plotInput, triggering the appropriate loading of all the tab widgets.


## Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md


## Important notes for developers
- It is worth pinning here the pull request from Mathieu_Pellerin (nirvn) in case it may help you with the key code for clicking and getting a feature.  Note: The example code here forgot to close the iterator.  

https://github.com/opengisch/QField/pull/6516

- Remember to add a it.close() after you get your feature from any feature iterator or you will catastrophically crash QField after about the 4th time you click!
- You have to set the tolerance on your point handler sufficiently high that it works not only on the desktop qfield with your mouse but also on your mobile device with your fat clumsy fingers.  Try for 20. 





