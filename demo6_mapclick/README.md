# demo6 mapclick

Of course what I really want this to be is a custom form.  This plugin is cool, but I am sure you have noticed it has no connection to the actual map.  That is still an unexplored area of the api.  I am going to try to use some kind advice from the OpenGIS folks to get as close as I can to clicking on the map and opening the plugin with the nearest plot already selected in the search bar.  This may be an ongoing development type of thing.  If you have a better idea than what I have here, then do let me know!

## What was the kind advice?

It is worth pinning here the post from Mathieu_Pellerin (nirvn) on community.qfield.org in case it may help you:

https://community.qfield.org/t/plugins-launching-from-feature-selection/1072

## Features of the plugin

### Using the QField MapCanvasPointHandler

This qml class should get us as far as clicking on the map and getting some coordinates.



### Strata Pages

d5_stratapage.qml will now define the contents of the strata tabs.  The New Entry button will load a new species entry widget to a list container and adds an empty row to the species table.

### Species Entry Widget

d5_species.qml governs the loading and saving of one row in the species table.  It has a delete button as well.

### Autosave

The header page requires a click of the save button to save features, but in the strata pages I have employed an autosave whenever a value is changed.  This was at the request of my users.  In the species entries there are only 3 inputs, so this works out fine, but I felt that in the header page, with about 15 inputs, it might be inefficient.  So, now you can see both methods and decide for yourself.

## Things I learned the hard way

The internal attribute index for a feature in qfield can be different than its attribute index in qgis, and it can change.  So you have to check the attribute index before you set a value.  Do not rely on hard coded attribute indexes.


## Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md

