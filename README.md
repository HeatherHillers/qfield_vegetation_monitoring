# qfield_vegetation_monitoring
A demonstration of a qfield project plugin for the purpose of sampling vegetaton in plots.  The purpose of this code is to show how to write a qfield project plugin.


## Code Demonstrations

Each Demo* project in this repository is an increasingly complex version of the vegetation_monitoring project plugin.  

1. demo1_hello: This is the simplest version.  It contains a hello world rectangle that is opened and closed by a plugin button.  Start here to get the basic skeleton for your plugin.
2. demo2_searchbar: This adds a searchbar to the project which has a menu populated with the plot_ids of all objects in the plots layer.  Selection of a plot changes the text of the title widget.  The menu is editable and has autocomplete.


## Running the demonstration

1. clone the repository.
2. choose one of the demo projects
5. Open the project in QGIS
6. Use the QField Sync Plugin to configure and synchronise the project and plugin to your QField client.
7. Refer to the README.md in the demo* directory for further instructions.  

## General Recommendations for writing plugins

1. It can be tricky to get the components and their updates to be found by qfield.  To be on certain, make sure components have unique names across projects, and test the loading of the components first before adding any functionality to them.
2. Start QField from the command line to get qml errors. Program errors are not printed in the client's log.
3. A synchronisation is usually not sufficient to get plugin updates.  Completely restart qfield, delete your project and download it fresh to make sure you have your latest change.
4. Dont name properties layer, as this may clash with a qt reserved property name.