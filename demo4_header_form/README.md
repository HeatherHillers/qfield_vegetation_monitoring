# demo4 header form

demo4_header_form: This adds a form to the tabWidget's header page.  It is used to save changes to a non spatial header table row for the plot selected in the menu.  Some more custom components are added, as well as a configurable data model for dynamically loading our field inputs, and a centralized style.

Note: This plugin is being developed for use on an iPad in landscape.  At this point the view on an iPhone does get cramped.  

## Features of the plugin

### Header Table

The private nonspatial layer plot_header has been added to the project.  This is where we will store information about strata coverage and vegetation height for our selected plot.  We start with an empty table.  There is no historical data in this example.  As to the fields themselves, the biologists tell me what they want.  I'm just a code monkey. 

### Header Page Component

We add d4_headerpage.qml to hold the form for the header input. The tabWidget delegates handling updates to the plot id to the headerpage component.  The d4_stratapage.qml is just a stub until our next demo, when it will hold the contents of all of our species tabs.

### Form Data Model

The header has a lot of inputs.  Writing them all out would be gnarly.  The data model in d4_form_data_model.qml lets us load group boxes and fields dynamically, as well as saving and loading thier values.  It also makes it much easier to change labels and field names.  The automatically generated values for fid, f_uid and log_date are not in the model.

### Style

We had to make a lot of components here, so it was time to unify the style.  d4_plugin_style.qml serves as the css for the plugin.

### Roll Your Own Spin Box
I have a definite opinion about a language developed by an organisation that develops libraries to make user interfaces that forces you to code your own spin box because it truly does not support decimal spin boxes because it doesn't think that would be important.  Luckily QField has a range type in it's source code and I could use that as a basis for range.qml.  


## Running the demonstration

See the instructions in qfield_vegetation_monitoring/README.md

