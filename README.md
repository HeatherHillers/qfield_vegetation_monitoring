# QField Vegetation Monitoring
A demonstration of a qfield project plugin for the purpose of sampling vegetaton in plots.  The purpose of this code is to show how to write a qfield project plugin.

Note: This plugin is being developed for use on an iPad.  At about demo3 the view on an iPhone does get cramped.

## Code Demonstrations

Each Demo* project in this repository is an increasingly complex version of the vegetation_monitoring project plugin.  

1. demo1_hello: This is the simplest version.  It contains a hello world rectangle that is opened and closed by a plugin button.  This plugin can be used as a basis for any static messaging plugin. (Yeah, not very useful.)

2. demo2_selection: This adds a point handler to the plugin.  The plugin button has been removed.  The user can now open the plugin by double clicking on a plot object.  Feature attribute values (plot id) are retrieved from the object and displayed in the popup text.  A close button has been added to the popup.  This plugin can be used as a basis for any custom reports plugin. (Pretty useful.)
   
3. demo3_tab_widget: This adds a very slick swiping tab widget.  The Tab widget uses a Repeater as a for loop to replicate the strata tabs which are going to have the same functionality, as well as for the tab buttons.  The plugin communicates the current object selection to the tabWidget, using it to populate the pages with information.
  
4. demo4_header_form: THe header tab contains a custom form with a save button that inserts or updates entries in an auxilliary table (plot_header) for the given plot_id.  THe strata tabs contain only a title in this demo.  With this demo you should be able to build any custom input plugin. (Very useful.)

5. demo5_strata_pages: This demonstration completes the plugin with the implementation of species entry in the strata tabs.  

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
