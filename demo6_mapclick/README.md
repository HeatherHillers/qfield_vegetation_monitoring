# demo6 mapclick

Of course what I really want this to be is a custom form.  This plugin is cool, but I am sure you have noticed it has no connection to the actual map.  

Starting with QField 3.7.2, it becomes possible to click on the map and get the nearest feature, and also override the click behavior so that we can open our plugin and pass it that feature.  It is everything we ever wanted and effectively gives us the ability to produce a custom form.  For the time being at least, stick a fork in it, it's done and ready to go to my favorite biologists.

## What changed in 3.7.2
It is worth pinning here the pull request from Mathieu_Pellerin (nirvn) in case it may help you with the key code for clicking and getting a feature.  Note: The example code here forgot to close the iterator.  Remember to add a it.close() after you get your feature or you will catastrophically crash QField after about the 4th time you click!

https://github.com/opengisch/QField/pull/6516


## Features of the plugin

### Using the QField MapCanvasPointHandler pointHandler Object

The clicking on the map part of the plugin is way in the front in demo6_mapclick.qml.  Here we use nirvn's example to register a pointHandler.  The  function registered reacts to a click on the map by activating (opening) the pluginLoader and calling the setPlotId function on it's item (the d6_plugin_component).

### Passing the properties

the d6_plugin_component passes the plotId to the setPlotId function of the searchBarComponent, where it is needed.

### Setting the selection of a combobox by text

the setPlotId function of d6_searchbar then calls selectByIdentifier, which searches through the plotInput comboBox for an index with a label matching the plotId.  It sets the selection by setting the currentIndex.  This then triggers the onCurrentIndexChanged slot of plotInput, triggering the appropriate loading of all the tab widgets.





## Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md

