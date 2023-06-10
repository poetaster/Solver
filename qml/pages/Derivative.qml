/*
  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtSensors 5.0
import QtQuick.Layouts 1.1

import io.thp.pyotherside 1.5

Page {
    id: derivativePage

    allowedOrientations: derivativeScreenOrientation
    function calculateResultDerivative() {
        result_TextArea.text = 'Calculating ...'
        py.call('solver.calculate_Derivative', [expression_TextField.text,var1_TextField.text,numVar1_TextField.text,var2_TextField.text,numVar2_TextField.text,var3_TextField.text,numVar3_TextField.text,numColumns,showDerivative,showTime,numerApprox,numDigText,simplifyResult_index,outputTypeResult_index], function(result) {
            result_TextArea.text = result;
        })
    }
    // 0=unknown, 1=portrait, 2=portrait inverted, 3=landscape, 4=landscape inverted
    property int _orientation: OrientationReading.TopUp
    property int _pictureRotation;

    OrientationSensor {
        id: orientationSensor
        active: true
        onReadingChanged: {
            if (reading.orientation >= OrientationReading.TopUp
                    && reading.orientation <= OrientationReading.RightUp) {
                _orientation = reading.orientation
                console.log("Orientation:", reading.orientation, _orientation);
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
            numColumns= 80
        }
        console.debug(_pictureRotation)
        console.debug(numColumns)
        calculateResultDerivative()
    }
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: container
        anchors.fill: parent
        //contentHeight: contentItem.childrenRect.height
        height: derivative_Column.height
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
                text: "Integral"
                onClicked: pageStack.push(Qt.resolvedUrl("Integral.qml"))
            }
            MenuItem {
                text: "Limit"
                onClicked: pageStack.push(Qt.resolvedUrl("Limit.qml"))
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Copy result")
                onClicked: Clipboard.text = result_TextArea.text
            }
            MenuItem {
                text: qsTr("Copy formula")
                onClicked: Clipboard.text = expression_TextField.text
            }
        }

        Column {
            id : derivative_Column
            width: derivativePage.width
            height: childrenRect.height
            spacing: Theme.paddingSmall


            PageHeader {
                title: qsTr("Derivative")
            }

            FontLoader { id: dejavusansmono; source: "file:DejaVuSansMono.ttf" }
            TextArea {
                id: result_TextArea
                height: tAreaH
                width: parent.width
                anchors {
                }

                //height: 3000
                readOnly: true
                font.family: dejavusansmono.name
                font.pixelSize: Theme.fontSizeExtraSmall
                text : 'Loading Python and SymPy, it takes some seconds...'
                color: 'lightblue'
                Component.onCompleted: {
                    //_editor.textFormat = Text.RichText;
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
// Try top
            TextField {
                id: expression_TextField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                label: qsTr("Expression")
                placeholderText: "sqrt(x/(x**3+1))"
                text: "sqrt(x/(x**3+1))"
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
            Button {
                id: calculate_Button
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width*0.60
                text: qsTr("Calculate")
                focus: true
                onClicked: calculateResultDerivative()
            }
            Separator {
                id : derivative_Separator
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width*0.9
                color: Theme.primaryColor
            }

            Label {
               id:timer
               anchors.horizontalCenter: parent.horizontalCenter
               width: parent.width*0.50
               text: timerInfo
               color: Theme.highlightColor
            }
        }
        VerticalScrollDecorator { flickable: derivative_Column }
    }

}
