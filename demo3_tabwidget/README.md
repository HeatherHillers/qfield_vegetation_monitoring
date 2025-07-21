# demo3 tabwidget

This demo builds on demo2_searchbar.  The selection from the searchBar is now communicated to a very neat swiping tab widget, where it is used to populate the tabs with information.

Note: This plugin is being developed for use on an iPad.  At this point the view on an iPhone does get cramped.

## Features of the plugin

### One loader speaks to another

The plugin component now has a Loader for the searchBar and a Loader for the tabWidget, and sends information from the searchBar to the tabWidget.

### TabWidget Component

This is a very cool ui component that synchronizes a tabBar with a swipe view, so you can click or swipe your way between tabs.  

### Populating pages

Each page gets the selection information and displays it in its text.

### Repeaters

If you are new to qml note the use of the Repeater components.  This is a qml for loop.  Tab Buttons are replicated with just a different name each time, and the strata pages are replicated with a different strata.


## Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md

