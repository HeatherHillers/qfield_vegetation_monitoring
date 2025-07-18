  
  /*
    This plugin component is just a rectangle.
    It's size is the full size of it's parent widget, which
    is the map canvas.
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
    property color background_color: "#ffecd1"
    property color text_color: "#6baa75"
    color: background_color
    Text {
        text: "Vegetation Monitoring: Plugin Component"
        color: pluginFrame.text_color
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter             
        anchors.centerIn: parent
    }
    Component.onCompleted: {
      //setup menu list models
      iface.logMessage("Plugin component loaded file found")
    }
  }