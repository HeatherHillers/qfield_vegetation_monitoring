# demo1_hello

This is the simplest version.  It contains a hello world rectangle that is opened and closed by a plugin button.  Start here to get the basic skeleton for your plugin.

## Features of the plugin

### Component Structure

The main qml must have the name of the project.  Any component.qml that you write must be stored in a subdirectory, name not important.  Otherwise it will not be found.  This directory must be added as an attachment directory in the QField project.  

Additionally, you have to go into the project page on qfield.cloud and click on "On demand attachment files download". 

### Main template structure

vegetation_monitoring.qml just contains the main Item component, a button to open it, and a loader to load it.  It is equivalent to the main class of any QGIS plugin.

### Turn it On and Off again

The QfToolButton with the id pluginButton opens and closes the plugin.  I used the camera icon for convenience.  The button will appear on the right side of the screen under the search button.  This area is the PluginsToolbar.  You can keep clicking this on/off button for a while if you are stressed out.  It is a bit calming to watch something that is working, even if it is quite small.

### A Loader

The Loader waits until the pluginButton is clicked to load your plugincomponent, which will contain the main widget.

### The Plugin component

plugincomponent.qml is pretty much equivalent to the main dialog in most QGIS plugins.  This is loaded and opened by the Loader in vegetation_monitoring.qml when the pluginButton is clicked.

### Log Messages 

iface.logMessage prints to the message log from the Loader when the button is clicked, and from the plugincomponent when the component is loaded

## Data and Project, Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md

