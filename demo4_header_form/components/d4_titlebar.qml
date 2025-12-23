/*
  This is the title bar for the vegetation monitoring plugin.
  It displays the current plot id and has a close button.
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
    // The titleBar defines a vanilla colored frame over which the 
    // Text Area and close button are displayed.
    id: titleBar
    anchors.fill: parent
    color: PluginTheme.vanilla
    property string plotId: parent.plotId

    // Signal to the parent component to deactivate the plugin
    signal closed()

    Label {
        id: titleText
        anchors.centerIn: parent
        color: PluginTheme.green
        font.pixelSize: PluginTheme.titleFontSize
        font.bold: true
        text: "Plot: " + plotId
    }
    
    QfToolButton {
        id: closeButton
        x: parent.width - (width * 2.2)
        anchors.top: parent.top
        anchors.topMargin: 5
        bgcolor: PluginTheme.red
        round: true
        contentItem: Text {
            text: "X"
            font.pixelSize: PluginTheme.titleFontSize
            color: PluginTheme.white
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: {
            closed()
        }
    }

} // /titleBar Rectangle
