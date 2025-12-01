  
  /*
    This plugin component is just a rectangle.
    It's size is the full size of it's parent widget, which
    is the pluginLoader in demo1_hello.
    The Rectangle contains a Text Component with a title string.
    */
 
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems
Rectangle {
    id: pluginFrame
    anchors.fill: parent
    color: PluginTheme.vanilla
    Text {
        text: "Demo 1 Vegetation Monitoring: Plugin Component"
        color: PluginTheme.green
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter             
        anchors.centerIn: parent
    }
    Component.onCompleted: {
        //setup menu list models
        iface.logMessage("d1_plugin_component.qml loaded")
    }
}