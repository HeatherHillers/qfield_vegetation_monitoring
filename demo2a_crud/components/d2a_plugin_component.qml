  
/*
  This plugin component contains a Rectangle frame used to display messages.
  It's size is the full size of it's parent widget, which
  is the pluginLoader in demo2_selection.
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

Rectangle {
    // The pluginFrame defines a vanilla colored frame.
    // In this frame is a very basic form for demonstrating CRUD actions (Create, Read, Update, Delete).
    // It allows the update of the entries (non geo) table, which has a number of generic string fields.
    // The entries have a geopackage pk of fid, a logical identifier f_uid, and an informal/human friendly logical unique identifier name. 
    // Their foreign key is the plot_id. 
    // On the top of the form is a dashboard frame.
    //   - In the dashboard frame is a Text displaying the plot id of the currently loaded plot.
    //      - it is populated by property bindings to the plotId property of the pluginFrame, which is set by the parent component when a plot is loaded.
    //   - In the dashboard frame is a drop down menu for selecting the entry by name.
    //      - the entry name input is a drop down menu that has the entry name as a display value and the entry f_uid as the underlying value. 
    //      - It is populated by property bindings to the entryListModel of the form controller, which is a ListModel that is updated by the form controller when entries are loaded, created, or deleted.
    //      - The menu sends the selected entry f_uid to the form controller with each select action.
    //   - In the dashboard is a New Entry button, which when clicked sends a create action to the form controller.
    // In the middle of the form is a group box containing inputs for some of the attributes of the entries (s1, s2).
    //      - the inputs are configured by the dataModel of the form controller.
    //      - a load action uses a Repeater to create an FormField object for each field in the dataModel.
    //      - The FormField component binds its text input value to the correct field in thecontrollers' data model.
    //      - a load signal from the form controller triggers the load action.
    //      - a save action from the save button sends a save action to the form controller, which then saves the values in its data model to the database.
    // On the bottom of the form is a status message box, which is a Rectangle with a Text inside.
    //    - the status message confirms save actions, and can be used to display error messages.
    // As an exercise, the workshop participants can add fields to the dataModel, which will automatically create the corresponding inputs in the form, 
    // and send the values of those inputs to the form controller on save actions,
    // As an exercise, participants can implement the delete action, which could be triggered by an additional button in the form, 
    // and would send a delete action to the form controller with the f_uid of the selected entry.
    
    id: pluginFrame
    anchors.fill: parent
    color: PluginTheme.vanilla
    property var fieldModel: FormDataModel.fields

    FormController {
        id: formController
        plotId: pluginFrame.plotId
        onSelect: function(f_uid) {
            for (var i = 0; i < controller.entryListModel.count; i++) {
                if (controller.entryListModel.get(i).f_uid === f_uid) {
                    entrySelector.currentIndex = i
                    break
                }
            }
        }
    }
    property var controller: formController

    // Signal to the parent component to deactivate the plugin
    signal closed()

    // Plot ID property - set from parent, propagates via bindings
    property string plotId: ""

    onPlotIdChanged: {
        if (plotId) {
            controller.loadEntries(plotId)
        }
    }
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 16      
        spacing: 10
        Rectangle {
            id: dashboardFrame
            Layout.alignment: Qt.AlignHCenter

            Layout.preferredWidth: pluginFrame.width * 0.9
            Layout.preferredHeight: dashboardLayout.implicitHeight + 16
            color: PluginTheme.green
            radius: 8
            RowLayout {
                id: dashboardLayout
                anchors.fill: parent
                anchors.margins: 8
                Item { Layout.fillWidth: true }
                Text {
                    id: plotIdText
                    color: PluginTheme.white
                    font.pixelSize: 16
                    text: "Plot loaded: " + pluginFrame.plotId
                }
                Item { Layout.fillWidth: true }
                ComboBox{
                    id: entrySelector
                    model: controller.entryListModel
                    Layout.preferredWidth: 240
                    textRole: "name"
                    currentIndex: -1
                    displayText: currentIndex < 0 ? "— select entry —" : currentText
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0) {
                            var f_uid = model.get(currentIndex).f_uid
                            controller.statusMessage = "[DEBUG] loadEntry: " + model.get(currentIndex).name + " (" + f_uid + ")"
                            controller.loadEntry(f_uid)
                        }
                    }
                }
                Item { Layout.fillWidth: true }
                Button{
                    contentItem: Text {
                        text: "New Entry"
                        font.pixelSize: 16
                        color: PluginTheme.white
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: PluginTheme.green
                        border.color: PluginTheme.white
                        border.width: 1
                        radius: 4
                    }
                    onClicked: {
                        controller.statusMessage = "[DEBUG] createEntry called for plot: " + pluginFrame.plotId
                        controller.createEntry()
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }

        Rectangle {
            id: formFrame
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.preferredWidth: pluginFrame.width * 0.9
            
            border.color: PluginTheme.green
            color: PluginTheme.white
            radius: 8
            border.width: 1

            ColumnLayout {
                id: formLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10
                component FormField: Rectangle{
                    id: formField
                    property var fieldData
                    color: "transparent"
                    Layout.fillWidth: true
                    implicitHeight: fieldRow.implicitHeight
                    RowLayout {
                        id: fieldRow
                        width: parent.width
                        spacing: 4
                        Text {
                            Layout.preferredWidth: formField.width * 0.3
                            color: PluginTheme.green
                            text: fieldData ? fieldData.label : ""
                            font.pixelSize: 16
                        }
                        TextField {
                            id: input
                            color: "black"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "white"
                                border.color: PluginTheme.green
                                border.width: 1
                                radius: 2
                            }
                            text: controller.fieldValues[fieldData.name] !== undefined ? controller.fieldValues[fieldData.name] : ""
                            onTextChanged: {
                                controller.updateField(fieldData.name, text)
                            }
                        }
                    }
                }

                Repeater {
                    model: fieldModel ? fieldModel : []             
                    delegate: FormField {
                        fieldData: modelData
                    }
                }
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    contentItem: Text {
                        text: "Save Entry"
                        color: PluginTheme.white
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: PluginTheme.green
                        radius: 4
                    }
                    onClicked: {
                        controller.statusMessage = "[DEBUG] Save button clicked"
                        controller.saveEntry()
                    }
                }
            }
        }
        Rectangle {
            id: statusMessageBox
            Layout.alignment: Qt.AlignHCenter
            color: PluginTheme.white
            border.color: PluginTheme.green
            border.width: 1
            radius: 8
            Column {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    id: statusMessageText
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: PluginTheme.green
                    font.pixelSize: 16
                    text: controller.statusMessage
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "gray"
                    font.pixelSize: 11
                    text: "fields: " + (fieldModel ? fieldModel.length : "null") +
                          " | currentEntry: " + (controller.currentFuid ? controller.currentFuid.substring(0,8) : "none") +
                          " | entries: " + controller.entryListModel.count
                }
            }
        }
        Button {
            id: closeButton
            contentItem: Text {
                text: "Close Plugin"
                color: PluginTheme.white
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: PluginTheme.green
                radius: 4
            }
            onClicked: {
                closed()
            }
        }
    }
    
}