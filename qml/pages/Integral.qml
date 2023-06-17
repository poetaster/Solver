/*
  Copyright (C) 2023  Mark Washeim <blueprint@poetaster.de>
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.2
import "../components"
Page {
    id: page
    function calculateResultIntegral() {
        result_TextArea.text = 'Calculating ...'
        py.call('solver.calculate_Integral', [
                    integrand_TextField.text,diff1_TextField.text,diff2_TextField.text,diff3_TextField.text,
                    limSup1_TextField.text,limSup2_TextField.text,limSup3_TextField.text,
                    limInf1_TextField.text,limInf2_TextField.text,limInf3_TextField.text,
                    integralType_index,numDimensions_index+1,numColumns,
                    showIntegral,showTime,numDigText,numerIntegralType_index,simplifyResult_index,outputTypeResult_index
                ], function(result) {
                   result_TextArea.text = result;
        })
    }
    allowedOrientations: derivativeScreenOrientation
    property bool debug: false

    onOrientationChanged:  {
        if ( orientation === Orientation.Portrait ) {
            drawer.open = true
            //drawer.height = 1/3 * container.height  // * _screenHeight //- Theme.paddingLarge
            if (debug) console.debug("port")
            tAreaH = _screenHeight * 2/3 //derivative_Column.childrenRect.height * .6
            numColumns = 40    // Portrait
        } else {
            if (debug) console.debug("land")
            tAreaH = _screenHeight * 1/5 + Theme.paddingLarge
            drawer.height = 1/4 * page.height + Theme.paddingLarge  // * _screenHeight //- Theme.paddingLarge
            drawer.open = false
            numColumns= 100
        }
        if (debug) console.debug(numColumns)
        calculateResultIntegral()
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
          title: qsTr("Integral")
    }
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: container
        anchors.fill: parent
        //height: integral_Column.height  //Theme.paddingLarge
        height: childrenRect.height
        width: page.width

        Component.onCompleted: {
            cName = "Integral"
            result_TextArea.text = resultText
        }
        VerticalScrollDecorator { flickable: container }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
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
                text: "Limit"
                onClicked: pageStack.replace(Qt.resolvedUrl("Limit.qml"))
            }
        }
        FontLoader {
            id: dejavusansmono
            source: "DejaVuSansMono.ttf"
        }

        Column {
            id: textCol
            width: parent.width
            height: 1/2 * parent.height // childrenRect.height
            spacing: Theme.paddingSmall
            //topPadding: Theme.paddingLarge
            TextArea {
                    id: result_TextArea
                    height: parent.height //tAreaH
                    width: parent.width
                    readOnly: true
                    font.family: dejavusansmono.name
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color:'lightblue'
                    placeholderText: "Integral calculation result"
                    text : 'Loading Python and SymPy ...'
                    Component.onCompleted: {
                        // _editor.textFormat = Text.RichText;
                        //if (debug) console.log(implicitHeight)
                        //height = implicitHeight
                    }

                    /* for the cover we hold the value */
                    onTextChanged: {
                        if (debug) console.log(implicitHeight)
                        if (debug) console.log(implicitWidth)
                        resultText = scaleText(text)
                        //height = implicitHeight
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
            height: 1/3 *  parent.height
            //dock: Dock.bottom // default
            //anchors {left: parent.left; right: parent.right}
            Column {
                id : integral_Column
                width: parent.width
                topPadding: Theme.paddingSmall
                Row {
                    id: grand
                    width: parent.width
                    //spacing: Theme.paddingSmall
                    TextField {
                        id: integrand_TextField
                        width: parent.width * 1/2  //*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.48 : 0.57) : 0.73)
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        //label: qsTr("Integrand")
                        placeholderText: "sin(x)**10"
                        text: "sin(x)**10"
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: diff1_TextField.focus = true
                    }
                    ComboBox {
                        id: integralType_ComboBox
                        width: parent.width * 1/3
                        //label: qsTr("Integral type ")
                        currentIndex: integralType_index
                        menu: ContextMenu {
                            MenuItem { text: qsTr("Indefinite") }
                            MenuItem { text: qsTr("Definite") }
                            MenuItem { text: qsTr("Numerical") }
                            onActivated: {
                                integralType_index = index
                                //if (index > 0 && isLandscape)
                                    //drawer.height =  2/3 * _screenHeight
                            }
                        }
                    }
                    ComboBox {
                        id: numDimensions_ComboBox
                        width: parent.width * 1/5
                        currentIndex: numDimensions_index
                        menu: ContextMenu {
                            MenuItem { text: qsTr("1D") }
                            MenuItem { text: qsTr("2D") }
                            MenuItem { text: qsTr("3D") }
                            onActivated: {
                                numDimensions_index = index
                                if (index == 0)
                                    limits.columns = 2
                                if (index == 1)
                                    limits.columns = 4
                                if (index == 2)
                                    limits.columns = 6
                            }
                        }
                    }
                }

                Row {
                    id: diffs
                    width: parent.width
                    //scale: 9/10
// GRID
                    Grid {
                        id: limits
                        columns: 2
                        width: parent.width
                        Label {
                            id: diff1_Label
                            horizontalAlignment: "AlignHCenter"
                            padding: Theme.paddingMedium
                            width: diffs.width * 1/6
                            text: qsTr("  d")
                        }
                        TextField {
                            id: diff1_TextField
                            width: diffs.width * 1/6
                            //width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.14 : 0.18) : 0.24)
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: "x"
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: {
                                if (numDimensions_index > 0) {
                                    diff2_TextField.focus = true
                                } else if (integralType_index > 0) {
                                    limInf1_TextField.focus = true
                                } else {
                                    calculate_Button.focus = true
                                }
                            }
                        }
                        Label {
                            id: diff2_Label
                            width: diffs.width * 1/6
                            horizontalAlignment: "AlignHCenter"
                            padding: Theme.paddingMedium
                            visible: numDimensions_index >= 1
                            text: qsTr("  d")
                        }
                        TextField {
                            id: diff2_TextField
                            visible: numDimensions_index >= 1
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: "y"
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: {
                                if (numDimensions_index > 1) {
                                    diff3_TextField.focus = true
                                } else if (integralType_index > 0) {
                                    limInf1_TextField.focus = true
                                } else {
                                    calculate_Button.focus = true
                                }
                            }
                        }
                        Label {
                            id: diff3_Label
                            width: diffs.width * 1/6
                            horizontalAlignment: "AlignHCenter"
                            padding: Theme.paddingMedium
                            visible: numDimensions_index >= 2
                            text: qsTr("  d")
                        }
                        TextField {
                            id: diff3_TextField
                            visible: numDimensions_index >= 2
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: "z"
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: {
                                if (integralType_index > 0) {
                                    limInf1_TextField.focus = true
                                } else {
                                    calculate_Button.focus = true
                                }
                            }
                        }
// Limits
                        TextField {
                            id: limInf1_TextField
                            visible: integralType_index > 0
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: "0"
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: {
                                if (integralType_index > 0) {
                                    limSup1_TextField.focus = true
                                } else {
                                    calculate_Button.focus = true
                                }
                            }
                        }
                        TextField {
                            id: limSup1_TextField
                            visible: integralType_index > 0
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercasle
                            text: '1'
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: {
                                if (numDimensions_index > 0) {
                                    limInf2_TextField.focus = true
                                } else {
                                    calculate_Button.focus = true
                                }
                            }
                        }
                        TextField {
                            id: limInf2_TextField
                            visible: (integralType_index > 0) && numDimensions_index > 0
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: "0"
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: {
                                if (numDimensions_index > 1) {
                                    limSup2_TextField.focus = true
                                } else {
                                    calculate_Button.focus = true
                                }
                            }
                        }
                        TextField {
                            id: limSup2_TextField
                            visible: (integralType_index > 0) && numDimensions_index > 0
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: '1'
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: {
                                if (numDimensions_index > 1) {
                                    limInf3_TextField.focus = true
                                } else {
                                    integrand_TextField.focus = true
                                }
                            }
                        }
                        TextField {
                            id: limInf3_TextField
                            visible: (integralType_index > 0) && numDimensions_index > 1
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: "0"
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: limSup3_TextField.focus = true
                        }
                        TextField {
                            id: limSup3_TextField
                            visible: (integralType_index > 0) && numDimensions_index > 1
                            width: diffs.width * 1/6
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: "1"
                            EnterKey.enabled: text.length > 0
                            EnterKey.iconSource: "image://theme/icon-m-enter-next"
                            EnterKey.onClicked: calculate_Button.focus = true
                        }


                    }
                    // End grid
                }

                Row {
                    id: buttonRow
                    spacing: Theme.paddingLarge
                    //width: parent.width
                    anchors {left: parent.left; right: parent.right}
                    anchors.leftMargin: Theme.paddingLarge

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
                        onClicked: calculateResultIntegral()
                    }

                }

                Label {
                    id:timer
                    visible: showTime && isPortrait //orientation == Orientation.Portrait ? 1 : 0
                    anchors.horizontalCenter: parent.horizontalCenter
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
/*
    states: [
        State {
            name: "inLandscape"
            when: orientation === Orientation.Landscape
            PropertyChanges {
                target: limSup1_TextField
                width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.29 : 0.435) : 0.87)
            }
            PropertyChanges {
                target: limSup2_TextField
                width: parent.width*(numDimensions_index == 1 ? 0.435 : 0.29)
            }
        },
        State {
            name: "inPortrait"
            when: orientation === Orientation.Portrait
            PropertyChanges {
                target: limSup1_TextField
                width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.25 : 0.38) : 0.75)
            }
            PropertyChanges {
                target: limSup2_TextField
                width: parent.width*(numDimensions_index == 1 ? 0.38 : 0.25)
            }
        }
    ]
*/
}
