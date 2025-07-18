# qfield_vegetation_monitoring
A demonstration of a qfield project plugin for the purpose of sampling vegetaton in plots.  The purpose of this code is to show how to write a qfield project plugin.


## Code Demonstrations

Each Demo* project in this repository is an increasingly complex version of the vegetation_monitoring project plugin.  

1. demo1_hello: This is the simplest version.  It contains a hello world rectangle that is opened and closed by a plugin button.  Start here to get the basic skeleton for your plugin.

## Data and Project

The data and the project are the same for each demonstration.  Copy the contents of the project directory into each demo directory to run it.

- vegetation_monitoring.qgs: contains a single point layer where each point is a sample plot in the field.  It also contains the nonspatial database layers, which are hidden in the project.
- vegetation.gpkg contains all of the project data.

## Running the demonstration

1. clone the repository.
2. create a working directory for your qfield project
3. copy the contents of the project/ directory into your working directory
4. copy the contents of one of the demo* directories into your working directory.
5. Open the project in QGIS
6. Use the QField Sync Plugin to configure and synchronise the project and plugin to your QField client.
7. Refer to the README.md in the demo* directory for further instructions.  