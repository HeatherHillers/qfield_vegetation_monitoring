# demo2_searchbar

This demo builds on demo1_hello and demonstrates feature selection from the map as well as signal handling.  

The user can now open the plugin by double clicking on a plot point.  The id of the selected plot will be displayed on the screen.
- on the windows executable QField, the double click haptic is disabled.  Instead a click on the point will open the plugin.

The pluginButton has been removed.  
  - The plugin is now only activated by double clicking on a point.
  - The plugin is closed using an Ok button that appears on the screen below the text message

With this plugin in hand, you should be able to construct any kind of reporting plugin you would like to create.


## Features of the plugin

### Plugin

Adds a pointHandler to recieve click and doubleclick signals from the map, capture coordinates, and relay them to the plugin component
Removes the pluginButton as it is no longer necessary to open or close the plugin.

### Plugin Component

Adds a setter function to recieve the plotId from the pointHandler and display it in the messageBox.
Adds an ok Button which sends a closed signal to the plugin Item to deactivate the plugin component.

### Get Layer By Name

The pointHandler in demo2_selection.qml queries the project for the layer named "plots" to obtain the QgsVectorLayer object.

### Get Features By Expression

To retrieve the nearest plot object to the user's clicked coordinates, pointHandler uses the LayerUtils function createFeatureIteratorFromExpression, using a spatial query built from the click coordinates.

**Warning**: Remember to always close the feature iterator.  Failure to do so will explode QField.

### Get Attributes from a Feature

The pointHandler retrieves the plot_id attribute to send to the plugin component.

### Signal Handling

Enjoy the interaction between Feature Selection, plugin and ok button.

### Passing the properties

the d2_plugin_component passes the plotId to the setPlotId function of the searchBarComponent, where it is needed.


## Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md


## Important notes for developers
- It is worth pinning here the pull request from Mathieu_Pellerin (nirvn) in case it may help you with the key code for clicking and getting a feature.  Note: The example code here forgot to close the iterator.  

https://github.com/opengisch/QField/pull/6516

- Remember to add a it.close() after you get your feature from any feature iterator or you will catastrophically crash QField after about the 4th time you click!
- You have to set the tolerance on your point handler sufficiently high that it works not only on the desktop qfield with your mouse but also on your mobile device with your fat clumsy fingers.  Try for 20. 





