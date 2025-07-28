# demo5 species entry

This demo implements the strata pages of the tab widget.  These pages will have a dynamic list of entry widgets, each responsible for the load and set of one species entry for the strata.  At this point, the plugin becomes basically complete and useable for vegetation monitoring.  The only component that is missing is to generate the feature selection from the map instead of from the search bar.  That will come in the next demo.

Note: This plugin is being developed for use on an iPad in landscape.  


## Features of the plugin

### Species Table

The private nonspatial layer species has been added to the project.  This is where we will store information about abundance of a particular species found in a given strata of the plot.  We start with an empty table.  There is no historical data in this example.  As to the fields themselves, the biologists tell me what they want.  I'm just a code monkey. 

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

