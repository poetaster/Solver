/* Copyright (C) 2023  Mark Washeim <blueprint@poetaster.de> */

import QtQuick 2.6
import Sailfish.Silica 1.0
import QtSensors 5.0
import QtQuick.Layouts 1.1
import io.thp.pyotherside 1.2

Page {
    id: page

    allowedOrientations: derivativeScreenOrientation
    // To enable PullDownMenu, place our content in a SilicaFlickable
    // 0=unknown, 1=portrait, 2=portrait inverted, 3=landscape, 4=landscape inverted
    property int _orientation: OrientationReading.TopUp
    property int _pictureRotation;
    property bool debug: true
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
            tAreaH = page.height * 1.2 //1000
        } else {
            tAreaH = 450
            numColumns= 80
        }
        if (debug) console.debug(_pictureRotation)
        if (debug) console.debug(numColumns)
        calculateResultLimit()
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
            height: parent.height * .54
            spacing: Theme.paddingSmall
            topPadding: Theme.paddingLarge * 5

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
        Column {
            id : input_Column
            width: parent.width
            height:  parent.height * .45
            spacing: Theme.paddingSmall
            anchors.top: limit_Column.bottom

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
                    text : "0"
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: limit_Column.calculateResultLimit()
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
                    width: parent.width*0.42
                    text: qsTr("Copy")
                    onClicked: Clipboard.text = result_TextArea.text
                }
                Button {
                    id: calculate_Button
                    width: parent.width*0.55
                    text: qsTr("Calculate")
                    focus: true
                    onClicked: calculateResultLimit()
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
}
