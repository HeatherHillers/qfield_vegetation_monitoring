# qfield_vegetation_monitoring
A demonstration of a qfield project plugin for the purpose of sampling vegetaton in plots.  The purpose of this code is to show how to write a qfield project plugin.

Note: This plugin is being developed for use on an iPad.  At about demo3 the view on an iPhone does get cramped.

## Code Demonstrations

Each Demo* project in this repository is an increasingly complex version of the vegetation_monitoring project plugin.  

1. demo1_hello: This is the simplest version.  It contains a hello world rectangle that is opened and closed by a plugin button.  Start here to get the basic skeleton for your plugin.

2. demo2_searchbar: This adds a searchbar to the project which has a menu populated with the plot_ids of all objects in the plots layer.  Selection of a plot changes the text of the title widget.  The menu is editable and has autocomplete.

3. demo3_tabwidget:  This adds a very slick swiping tab widget.  The Tab widget uses a Repeater as a for loop to replicate the strata tabs which are going to have the same functionality, as well as for the tab buttons.  The plugin communicates the current searchBar selection to the tabWidget, using it to populate the pages with information (just the plot id).  No new api stuff here, just ui magic.

4. demo4_header_form: This adds a form to the tabWidget's header page.  It is used to save a non spatial header table row for the plot selected in the menu.  Some more custom components are added, as well as a configurable data model for dynamically loading our field inputs, and a centralized style.

5. demo5_species_entry:  This adds a nice species entry widget to each strata page, with autosave.  It's pretty neat, I think.  The component communication gets a bit complicated.

6. demo6_mapclick: This plugin adds the critical ability to click on the map and open the plugin with the nearest object's plot id selected in the search bar.  Custom Form, voila!


## What's wrong with demo6_mapclick

In the desktop qfield on Ubuntu, when I open the plugin, the attribute drawer does not appear. On ios, however, both the plugin and the attribute form are appearing.  You can click on the plugin component and the attribute form will disappear, but it is not ideal.  I haven't figured out how to fix that yet.

## Running the demonstration

1. clone the repository.
2. choose one of the demo projects
5. Open the project in QGIS
6. Use the QField Sync Plugin to configure and synchronise the project and plugin to your QField client.
7. Refer to the README.md in the demo* directory for further instructions.  

## General Recommendations for writing plugins

1. It can be tricky to get the components and their updates to be found by qfield.  To be on certain, make sure components have unique names across projects, and test the loading of the components first before adding any functionality to them.
2. Start QField from the command line to get qml errors. Program errors are not printed in the client's log.
3. A synchronisation is usually not sufficient to get plugin updates.  Completely restart qfield, delete your project and download it fresh to make sure you have your latest change.  Sometimes it will become necessary to completely delete your project from qfieldcloud in order to get an update through.
4. Dont name properties layer, as this may clash with a qt reserved property name.
5. The internal attribute index for a feature in qfield can be different than its attribute index in qgis, and it can change.  So you have to check the attribute index before you set a value.  Do not rely on hard coded attribute indexes.
6. Always remember to close your feature iterators. Failure to do so will catastrophically crash QField after about the 4th execution.