/* Copyright (C) 2023  Mark Washeim <blueprint@poetaster.de> */

import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.2
import "../components"

Page {
    id: page

    allowedOrientations: derivativeScreenOrientation
    property bool debug: false
    function calculateResultLimit() {
        result_TextArea.text = 'Calculating limit...'
        py.call('solver.calculate_Limit', [expression_TextField.text,variable_TextField.text,point_TextField.text,direction_ComboBox.value,orientation!==Orientation.Landscape,showLimit,showTime,numerApprox,numDigText,simplifyResult_index,outputTypeResult_index], function(result) {
            result_TextArea.text = result;
        })
    }
    function copyResult() {
        result_TextArea.selectAll()
        result_TextArea.copy()
        result_TextArea.deselect()
    }
    onOrientationChanged:  {
        if ( orientation === Orientation.Portrait ) {
            if (debug) console.debug("port")
            drawer.open = true
            tAreaH = _screenHeight * 3/5 //derivative_Column.childrenRect.height * .6
            numColumns = 40    // Portrait
        } else {
            if (debug) console.debug("land")
            tAreaH = _screenHeight * 2/5
            numColumns= 100
            drawer.height = 1/5 * page.height + Theme.paddingLarge  // * _screenHeight //- Theme.paddingLarge
            drawer.open = false
        }
        if (debug) console.debug(numColumns)
        calculateResultLimit()
    }
    property alias notification: popup
    Popup {
        id: popup
        z: 10
        timeout: 3000
        padding: Theme.paddingSmall
        defaultColor: Theme.highlightColor
        labelMargin: Theme.paddingSmall
    }
    PageHeader {
        id: header
        title: qsTr("Limit")
    }
    SilicaFlickable {
        Component.onCompleted:  {
            cName = "Limit"
        }
        id: container
        anchors.fill: parent
        height: childrenRect.height
        width: page.width

        VerticalScrollDecorator { flickable: container }

        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: "Help"
                onClicked: pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
            }
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: "Solver"
                onClicked: pageStack.replace(Qt.resolvedUrl("Solver.qml"))
            }
            MenuItem {
                text: "Derivative"
                onClicked: pageStack.replace(Qt.resolvedUrl("Derivative.qml"))
            }
            MenuItem {
                text: "Integral"
                onClicked: pageStack.replace(Qt.resolvedUrl("Integral.qml"))
            }
        }
        FontLoader { id: dejavusansmono; source: "DejaVuSansMono.ttf" }

        Column {
            id : limit_Column
            width: parent.width
            height: parent.height * 3/5 - Theme.paddingLarge // childrenRect.height
            spacing: Theme.paddingSmall
            topPadding: Theme.paddingLarge * 3

            TextArea {
                id: result_TextArea
                height: tAreaH
                width: parent.width
                readOnly: true
                font.family: dejavusansmono.name
                color: 'lightblue'
                font.pixelSize: Theme.fontSizeSmallBase
                text : '...'
                Component.onCompleted: {
                    //_editor.textFormat = Text.RichText;
                }

                /* for the cover we hold the value */
                onTextChanged: {
                    if (debug) console.log(implicitHeight)
                    if (debug) console.log(parent.height)
                    resultText = scaleText(text)
                }
                /* for the cover we scale font px values */
                /* on the cover we can use html */
                function scaleText(text) {
                    const txt = '<FONT COLOR="lightblue" SIZE="16px"><pre>'
                    txt = txt + text + '<pre></FONT>'
                    return txt
                }
            }
        }
        DockedPanel{
            id: drawer
            width: parent.width
            height: 1/4 * parent.height
            dock: Dock.bottom
            Column {
                id : input_Column
                width: page.width
                spacing: Theme.paddingSmall

                Row {
                    width: parent.width
                    TextField {
                        id: expression_TextField
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        placeholderText: "sin(x)/x"
                        label: qsTr("Limit expression")
                        width: parent.width * 0.5
                        text : "sin(x)/x"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: variable_TextField.focus = true
                    }
                    ComboBox {
                        id: direction_ComboBox
                        width: page.width*0.5
                        label: qsTr("Direction")
                        currentIndex: 0
                        menu: ContextMenu {
                            MenuItem { text: "Bilateral" }
                            MenuItem { text: "Left" }
                            MenuItem { text: "Right" }
                        }
                    }
                }
                Row {
                    width: parent.width
                    TextField {
                        id: variable_TextField
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        width: parent.width*0.5
                        placeholderText: "x"
                        label: qsTr("Variable")
                        text : "x"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: point_TextField.focus = true
                    }
                    TextField {
                        id: point_TextField
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        width: parent.width*0.5
                        placeholderText: "0"
                        label: qsTr("Point")
                        text : "5"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                        EnterKey.onClicked: calculateResultLimit()
                    }
                }
                Row {
                    spacing: Theme.paddingLarge
                    anchors {
                        //parent.horizontalCenter
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingLarge
                    }
                    Button {
                        id: copy_Button
                        width: parent.width * 1/3 - Theme.paddingLarge
                        text: qsTr("Copy")
                        onClicked: Clipboard.text = result_TextArea.text
                    }
                    Button {
                        id: calculate_Button
                        width: parent.width * 2/3 - Theme.paddingLarge
                        text: qsTr("Calculate")
                        focus: true
                        onClicked: calculateResultLimit()
                    }

                }
                Label {
                    id:timer
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: showTime && isPortrait
                    width: parent.width*0.50
                    //width: parent.width  - Theme.paddingLarge
                    text: timerInfo
                    color: Theme.highlightColor
                }

            }
        }
    }
    IconButton{
        id: upB
        anchors {
            horizontalCenter: page.horizontalCenter;
            bottom: page.bottom
        }
        visible: ! drawer.open
        icon.source: "image://theme/icon-m-up"
        onClicked: drawer.open = true

    }
}
