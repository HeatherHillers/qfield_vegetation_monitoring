  
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
    // The pluginFrame defines a vanilla colored frame over which the 
    // Text Area is displayed.
    id: pluginFrame
    anchors.fill: parent
    color: PluginTheme.vanilla

    // Signal to the parent component to deactivate the plugin
    signal closed()

    function setPlotId(plotId) {
        messageBox.text = "Plot loaded: " + plotId
        console.log("component loaded with plot ID:", plotId)
    }

    ColumnLayout {
        anchors.centerIn: parent
        // define width on the column layout to control child element widths
        width: parent.width * 0.8
        spacing: 20

        Rectangle {   
            id: messageBoxFrame
            width: parent.width
            height: 100
            color: PluginTheme.green
            Layout.alignment: Qt.AlignHCenter
            Text {
                id: messageBox
                anchors.centerIn: parent
                color: PluginTheme.white
                font.pixelSize: 16
            }
        }

        Button {
            id: closeButton
            contentItem: Text {
                text: "Ok"
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