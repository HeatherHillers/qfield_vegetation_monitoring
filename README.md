# QField Vegetation Monitoring
A demonstration of a qfield project plugin for the purpose of sampling vegetaton in plots.  The purpose of this code is to show how to write a qfield project plugin.

Note: This plugin is being developed for use on an iPad.  At about demo3 the view on an iPhone does get cramped.

## Documentation
For full documentation and workshop materials in english and in german, please visit our GitHub Pages site:

https://heatherhillers.github.io/workshop_qfield_plugins_de/

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


