/*
  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>.
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5

Page {
    id: page

    allowedOrientations: derivativeScreenOrientation
    function calculateResultDerivative() {
        result_TextArea.text = 'Calculating ...'
        py.call('solver.calculate_Derivative', [expression_TextField.text,var1_TextField.text,numVar1_TextField.text,var2_TextField.text,numVar2_TextField.text,var3_TextField.text,numVar3_TextField.text,numColumns,showDerivative,showTime,numerApprox,numDigText,simplifyResult_index,outputTypeResult_index], function(result) {
            result_TextArea.text = result;
        })
    }
    property bool debug: true
    onOrientationChanged:  {
        if ( orientation === Orientation.Portrait ) {
            if (debug) console.debug("port")
            drawer.open = true
            tAreaH = _screenHeight * 3/5 //derivative_Column.childrenRect.height * .6
            numColumns = 40    // Portrait
        } else {
            if (debug) console.debug("land")
            tAreaH = _screenHeight * 1/5
            numColumns= 100
            drawer.height = 1/4 * page.height + Theme.paddingLarge  // * _screenHeight //- Theme.paddingLarge
            drawer.open = false
        }
        if (debug) console.debug(Orientation.Portrait)//_pictureRotation)
        //console.debug(numColumns)
        calculateResultDerivative()
    }
    PageHeader {
        title: qsTr("Derivative")
    }
    SilicaFlickable {
        id: container
        anchors.fill: parent
        height: childrenRect.height
        width: parent.width

        Component.onCompleted: {
            cName = "Derivative"
        }
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
                text: "Integral"
                onClicked: pageStack.replace(Qt.resolvedUrl("Integral.qml"))
            }
            MenuItem {
                text: "Limit"
                onClicked: pageStack.replace(Qt.resolvedUrl("Limit.qml"))
            }
        }

        VerticalScrollDecorator { flickable: container }
        FontLoader { id: dejavusansmono; source: "file:DejaVuSansMono.ttf" }

        Column {
            id : derivative_Column
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
                font.pixelSize: Theme.fontSizeExtraSmall
                text : 'Loading Python and SymPy, it takes some seconds...'
                color: 'lightblue'
                clip: true
                Component.onCompleted: {
                    //_editor.textFormat = Text.RichText;
                    if(debug) console.debug(implicitHeight)
                    if(debug) console.debug(height)
                }
                /* for the cover we hold the value */
                onTextChanged: {
                    resultText = scaleText(text)
                }
                /* for the cover we scale font px values */
                /* on the cover we can use html */
                function scaleText(text) {
                    const txt = '<FONT COLOR="lightblue" SIZE="10px"><pre>'
                    txt = txt + text + '<pre></FONT>'
                    return txt
                }
            }
        }
        DockedPanel{
            id: drawer
            width: parent.width
            height: 1/4 *  parent.height
            dock: Dock.bottom // default
            //anchors {left: parent.left; right: parent.right}
            Column {
                id: textInput
                width: parent.width
                spacing: Theme.paddingSmall
                TextField {
                    id: expression_TextField
                    width: parent.width
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    label: qsTr("Expression")
                    placeholderText: "sqrt(x/(x**3+1))"
                    text: "x * sin(x**2) + 1"
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: var1_TextField.focus = true
                }
                Grid {
                    id: diffs_Item
                    anchors {left: parent.left; right: parent.right}
                    width: parent.width
                    rows: 1
                    columns: 6
                    TextField {
                        id: var1_TextField
                        width: parent.width*0.20
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        label: qsTr("Var.1")
                        placeholderText: "x"
                        text: "x"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: numVar1_TextField.focus = true
                    }
                    TextField {
                        id: numVar1_TextField
                        width: parent.width*0.13
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 0; top: 9999 }
                        label: "#"
                        placeholderText: "1"
                        text: "1"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: var2_TextField.focus = true
                    }
                    TextField {
                        id: var2_TextField
                        width: parent.width*0.20
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        label: qsTr("Var.2")
                        placeholderText: "y"
                        text: "y"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: numVar2_TextField.focus = true
                    }
                    TextField {
                        id: numVar2_TextField
                        width: parent.width*0.13
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 0; top: 9999 }
                        label: "#"
                        placeholderText: "0"
                        text: "0"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: var3_TextField.focus = true
                    }
                    TextField {
                        id: var3_TextField
                        width: parent.width*0.20
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        label: qsTr("Var.3")
                        placeholderText: "z"
                        text: "z"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: numVar3_TextField.focus = true
                    }
                    TextField {
                        id: numVar3_TextField
                        width: parent.width*0.13
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 0; top: 9999 }
                        label: "#"
                        placeholderText: "0"
                        text: "0"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                        EnterKey.onClicked: derivative_Column.calculateResultDerivative()
                    }
                }
                Row {
                    anchors.leftMargin: Theme.paddingLarge
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    spacing: Theme.paddingLarge
                    Button {
                        id: copy_Button
                        width: parent.width * 1/3 - Theme.paddingLarge
                        text: qsTr("Copy")
                        onClicked: Clipboard.text = result_TextArea.text
                    }
                    Button {
                        anchors.leftMargin: Theme.paddingLarge
                        id: calculate_Button
                        width: parent.width * 2/3 - Theme.paddingLarge
                        text: qsTr("Calculate")
                        focus: true
                        onClicked: calculateResultDerivative()
                    }

                }

                Label {
                    id:timer
                    visible: showTime && isPortrait
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width*0.50
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
