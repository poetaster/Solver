/*
  Copyright (C) 2023  Mark Washeim <blueprint@poetaster.de>
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSensors 5.0
import QtQuick.Layouts 1.1
import io.thp.pyotherside 1.2

Page {
    id: page
    function calculateResultIntegral() {
        result_TextArea.text = 'Calculating ...'
        py.call('solver.calculate_Integral', [integrand_TextField.text,diff1_TextField.text,diff2_TextField.text,diff3_TextField.text,
                limSup1_TextField.text,limSup2_TextField.text,limSup3_TextField.text,limInf1_TextField.text,limInf2_TextField.text,limInf3_TextField.text,
                integralType_index,numDimensions_index+1,numColumns,
                showIntegral,showTime,numDigText,numerIntegralType_index,simplifyResult_index,outputTypeResult_index], function(result) {
            result_TextArea.text = result;
        })
    }
    allowedOrientations: derivativeScreenOrientation
    // 0=unknown, 1=portrait, 2=portrait inverted, 3=landscape, 4=landscape inverted
    property int _orientation: OrientationReading.TopUp
    property int _pictureRotation;
    property bool debug: true

    OrientationSensor {
        id: orientationSensor
        active: true
        onReadingChanged: {
            if (reading.orientation >= OrientationReading.TopUp
                    && reading.orientation <= OrientationReading.RightUp) {
                _orientation = reading.orientation
                if (debug) console.log("Orientation:", reading.orientation, _orientation);
            }
            switch (reading.orientation) {
            case OrientationReading.TopUp:
                _pictureRotation = 0; break
            case OrientationReading.TopDown:
                _pictureRotation = 180; break
            case OrientationReading.LeftUp:
                _pictureRotation = 270; break
            case OrientationReading.RightUp:
                _pictureRotation = 90; break
            default:
                // Keep device orientation at previous state
            }
        }
    }
    onOrientationChanged:  {
        if (_pictureRotation === 0 || _pictureRotation === 180) {
            numColumns = 40    // Portrait
            tAreaH = 1000
        } else {
            tAreaH = 450
            numColumns= 100
        }
        if (debug) console.debug(_pictureRotation)
        if (debug) console.debug(numColumns)
        calculateResultIntegral()
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
        }
        VerticalScrollDecorator { flickable: container }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Help")
                onClicked: pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
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
            width: page.width
            height:  parent.height * .55
            spacing: Theme.paddingSmall
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

        Column {
            id : integral_Column
            anchors {
                top: textCol.bottom
            }

            width: page.width
            height:  parent.height * .45
            spacing: Theme.paddingSmall
            Row {
                ComboBox {
                    id: integralType_ComboBox
                    width: page.width*0.7
                    label: qsTr("Integral type ")
                    currentIndex: integralType_index
                    menu: ContextMenu {
                        MenuItem { text: qsTr("Indefinite") }
                        MenuItem { text: qsTr("Definite") }
                        MenuItem { text: qsTr("Numerical") }
                        onActivated: {
                            integralType_index = index
                        }
                    }
                }
                ComboBox {
                    id: numDimensions_ComboBox
                    width: page.width*0.3
                    currentIndex: numDimensions_index
                    menu: ContextMenu {
                        MenuItem { text: qsTr("1D") }
                        MenuItem { text: qsTr("2D") }
                        MenuItem { text: qsTr("3D") }
                        onActivated: {
                            numDimensions_index = index
                        }
                    }
                }
            }
            Row {
                visible: integralType_index > 0
                anchors {left: parent.left; right: parent.right}
                width: parent.width*0.80
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                Label {
                    id: upperLimit_Label
                    text: qsTr("Upper limit")
                }
                TextField {
                   id: limSup1_TextField
                   width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.25 : 0.38) : 0.75)
                   inputMethodHints: Qt.ImhNoAutoUppercase
                   text: '1'
                   EnterKey.enabled: text.length > 0
                   EnterKey.iconSource: "image://theme/icon-m-enter-next"
                   EnterKey.onClicked: {
                       if (numDimensions_index > 0) {
                           limSup2_TextField.focus = true
                       } else {
                           integrand_TextField.focus = true
                       }
                   }
                }
                TextField {
                   id: limSup2_TextField
                   visible: numDimensions_index >= 1
                   width: parent.width*(numDimensions_index == 1 ? 0.38 : 0.25)
                   inputMethodHints: Qt.ImhNoAutoUppercase
                   text: '1'
                   EnterKey.enabled: text.length > 0
                   EnterKey.iconSource: "image://theme/icon-m-enter-next"
                   EnterKey.onClicked: {
                       if (numDimensions_index > 1) {
                           limSup3_TextField.focus = true
                       } else {
                           integrand_TextField.focus = true
                       }
                   }
                }
                TextField {
                   id: limSup3_TextField
                   visible: numDimensions_index >= 2
                   width: parent.width*0.25
                   inputMethodHints: Qt.ImhNoAutoUppercase
                   text: "1"
                   EnterKey.enabled: text.length > 0
                   EnterKey.iconSource: "image://theme/icon-m-enter-next"
                   EnterKey.onClicked: integrand_TextField.focus = true
                }
            }
            Row {
                anchors {left: parent.left; right: parent.right}
                TextField {
                    id: integrand_TextField
                    width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.48 : 0.57) : 0.73)
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    label: qsTr("Integrand")
                    placeholderText: "sin(x)**10"
                    text: "sin(x)**10"
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: diff1_TextField.focus = true
                }
                Label {
                    id: diff1_Label
                    text: qsTr("d")
                }
                TextField {
                   id: diff1_TextField
                   width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.14 : 0.18) : 0.24)
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
                    visible: numDimensions_index >= 1
                    text: qsTr("d")
                }
                TextField {
                   id: diff2_TextField
                   visible: numDimensions_index >= 1
                   width: parent.width*(numDimensions_index == 1 ? 0.18 : 0.14)
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
                    visible: numDimensions_index >= 2
                    text: qsTr("d")
                }
                TextField {
                   id: diff3_TextField
                   visible: numDimensions_index >= 2
                   width: parent.width*0.14
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
            }
            Row {
                visible: integralType_index > 0
                anchors {left: parent.left; right: parent.right}
                width: parent.width*0.80
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                Label {
                    id: lowerLimit_Label
                    text: qsTr("Lower limit")
                }
                TextField {
                   id: limInf1_TextField
                   width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.25 : 0.38) : 0.77)
                   inputMethodHints: Qt.ImhNoAutoUppercase
                   text: "0"
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
                   visible: numDimensions_index >= 1
                   width: parent.width*(numDimensions_index == 1 ? 0.38 : 0.25)
                   inputMethodHints: Qt.ImhNoAutoUppercase
                   text: "0"
                   EnterKey.enabled: text.length > 0
                   EnterKey.iconSource: "image://theme/icon-m-enter-next"
                   EnterKey.onClicked: {
                       if (numDimensions_index > 1) {
                           limInf3_TextField.focus = true
                       } else {
                           calculate_Button.focus = true
                       }
                   }
                }
                TextField {
                   id: limInf3_TextField
                   visible: numDimensions_index >= 2
                   width: parent.width*0.25
                   inputMethodHints: Qt.ImhNoAutoUppercase
                   text: "0"
                   EnterKey.enabled: text.length > 0
                   EnterKey.iconSource: "image://theme/icon-m-enter-next"
                   EnterKey.onClicked: calculate_Button.focus = true
                }
            }
            Row {
                id: buttonRow
                spacing: Theme.paddingLarge
                anchors.leftMargin: Theme.paddingLarge
                anchors {
                    left: parent.left
                    right: parent.right
                }
                Button {
                    id: copy_Button
                    width: parent.width*0.42
                    text: qsTr("Copy")
                    onClicked: Clipboard.text = result_TextArea.text
                }
                Button {
                    id: calculate_Button
                    anchors.leftMargin: Theme.paddingLarge
                    width: parent.width*0.55
                    text: qsTr("Calculate")
                    focus: true
                    onClicked: calculateResultIntegral()
                }

            }

            Label {
               id:timer
               visible: _pictureRotation === 0
               anchors.horizontalCenter: parent.horizontalCenter
               width: parent.width*0.50
               //width: parent.width  - Theme.paddingLarge
               text: timerInfo
               color: Theme.highlightColor
            }

        }
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
            PropertyChanges {
                target: limSup3_TextField
                width: parent.width*0.29
            }
            PropertyChanges {
                target: integrand_TextField
                width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.525 : 0.605) : 0.745)
            }
            PropertyChanges {
                target: limInf1_TextField
                width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.29 : 0.435) : 0.87)
            }
            PropertyChanges {
                target: limInf2_TextField
                width: parent.width*(numDimensions_index == 1 ? 0.435 : 0.29)
            }
            PropertyChanges {
                target: limInf3_TextField
                width: parent.width*0.29
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
            PropertyChanges {
                target: limSup3_TextField
                width: parent.width*0.25
            }
            PropertyChanges {
                target: integrand_TextField
                width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.48 : 0.57) : 0.73)
            }
            PropertyChanges {
                target: limInf1_TextField
                width: parent.width*(numDimensions_index >= 1 ? (numDimensions_index == 2 ? 0.25 : 0.38) : 0.75)
            }
            PropertyChanges {
                target: limInf2_TextField
                width: parent.width*(numDimensions_index == 1 ? 0.38 : 0.25)
            }
            PropertyChanges {
                target: limInf3_TextField
                width: parent.width*0.25
            }
        }
    ]
*/
}
