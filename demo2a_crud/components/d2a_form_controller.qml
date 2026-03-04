/*
    FormController component definition
    1. Provides a statusMessage property that the view usees to display messages to the user.
    2. Provides access to the data model of the form, which is used to configure the form inputs and to store the values of the inputs. The data model is updated by the form controller when entries are loaded or created, and is used by the view to populate the form inputs.
    3. Functions for loading entries, creating entries, saving entries, and deleting entries. These functions are called from the view with signals from the buttons and inputs, and they update the statusMessage property to confirm actions or display error messages.
*/
 
 // Qt Alignment Properties are imported from QtQuick
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

QtObject{

    property string statusMessage: ""
    property var plotId: ""
    signal select(string f_uid)

    property var currentFuid: ""
    property var fieldValues: ({})   // plain JS map used as edit buffer
    property ListModel entryListModel: ListModel{}
    property var layer: qgisProject.mapLayersByName("entries")[0]

    function updateField(fieldName, value) {
        // store edit 
        fieldValues[fieldName] = value
        fieldValuesChanged()  // notify bindings
    }

    function saveEntry() {
        try {
            if (!currentFuid) {
                statusMessage = "Error: No entry loaded"
                return
            }
            // fetch a fresh live feature reference for the save
            let it = LayerUtils.createFeatureIteratorFromExpression(layer, "f_uid = '" + currentFuid + "'")
            if (!it.hasNext()) {
                it.close()
                statusMessage = "Error: Entry not found in layer"
                return
            }
            let feature = it.next()
            it.close()
            // apply all edits from the JS map to the feature
            for (var key in fieldValues) {
                feature.setAttribute(key, fieldValues[key])
            }
            layer.startEditing()
            var fid = feature.id
            var fields = feature.fields
            for (var key in fieldValues) {
                var fieldIndex = fields.indexOf(key)
                if (fieldIndex >= 0) {
                    layer.changeAttributeValue(fid, fieldIndex, fieldValues[key])
                }
            }
            layer.commitChanges()
            loadEntries(plotId) // refresh dropdown with updated names
            select(currentFuid) // re-select the just-saved entry
            statusMessage = "Entry saved successfully!"
        } catch(e) {
            statusMessage = "Save error: " + e
            if (layer.isEditable()) layer.rollBack()
        }
    }

    function deleteEntry() {
        /**
         * Delete the currently loaded entry from the layer.
         * Demonstrates: layer editing workflow, deleteFeature
         * Exercise: add a Delete button to the form that calls controller.deleteEntry()
         */
        try {
            if (!currentFuid) {
                statusMessage = "Error: No entry loaded"
                return
            }
            let it = LayerUtils.createFeatureIteratorFromExpression(layer, "f_uid = '" + currentFuid + "'")
            if (!it.hasNext()) {
                it.close()
                statusMessage = "Error: Entry not found in layer"
                return
            }
            let fid = it.next().id
            it.close()
            layer.startEditing()
            layer.deleteFeature(fid)
            layer.commitChanges()
            // clear selection and form
            currentFuid = ""
            fieldValues = {}
            fieldValuesChanged()
            loadEntries(plotId)
            statusMessage = "Entry deleted."
        } catch(e) {
            statusMessage = "Delete error: " + e
            if (layer.isEditable()) layer.rollBack()
        }
    }

    function createEntry() {
    /**
     * Create a new feature with initial values
     * Demonstrates: FeatureUtils.createFeature, setAttribute, LayerUtils.addFeature
     */
        
        layer.startEditing()
        
        var newFeature = FeatureUtils.createFeature(layer)
        newFeature.setAttribute("f_uid", StringUtils.createUuid().replace(/[\{\}]/g, ""))
        newFeature.setAttribute("plot_id", plotId)
        newFeature.setAttribute("log_date", new Date().toISOString())
        // set temporary name for display
        newFeature.setAttribute("name", "New Entry " + newFeature.attribute("f_uid").substring(0, 8))
        
        LayerUtils.addFeature(layer, newFeature)
        layer.commitChanges()

        var newUid = newFeature.attribute("f_uid")
        loadEntries(plotId) // reload entries to update the list with the new entry
        loadEntry(newUid)   // populate fieldValues from the new feature
        select(newUid)      // select the new entry in the dropdown
    }
    
    function loadEntry(f_uid) {
        // Fetch feature and copy its values into the JS fieldValues map
        currentFuid = ""
        fieldValues = {}
        fieldValuesChanged()
        let it = LayerUtils.createFeatureIteratorFromExpression(layer, "f_uid = '" + f_uid + "'")
        if (!it.hasNext()) {
            it.close()
            statusMessage = "Error: could not load entry " + f_uid
            return
        }
        let feature = it.next()
        it.close()
        // populate JS map from feature attributes
        var fields = FormDataModel.fields
        var map = {}
        for (var i = 0; i < fields.length; i++) {
            map[fields[i].name] = feature.attribute(fields[i].name) || ""
        }
        fieldValues = map
        fieldValuesChanged()
        currentFuid = f_uid
        statusMessage = ""
    }

    function loadEntries(plotId) {
        // initialize the entry list model with the entries from the database
        entryListModel.clear()
        var expression = "plot_id = '" + plotId + "'"
        let it = LayerUtils.createFeatureIteratorFromExpression(layer, expression)
 
        while (it.hasNext()) {
            let feature = it.next()
            entryListModel.append({"name": feature.attribute("name"), 
                                   "f_uid": feature.attribute("f_uid")})
        }
        it.close()
    }

    Component.onCompleted: {
        if (plotId && layer) {
            loadEntries(plotId)
        }
    }


    
}