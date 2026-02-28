/*
    Form Data Model*/

pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts  

import QtCore

import org.qfield  
import org.qgis
import Theme  

import "qrc:/qml" as QFieldItems

QtObject{

    property var fields: [{"name":"name", "label":"Entry Name"},
                          {"name":"s1", "label":"Thoughts"},
                          {"name":"s2", "label":"Feelings"}]
    
}