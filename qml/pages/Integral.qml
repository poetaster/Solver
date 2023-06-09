/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.2

Page {
    id: page

    allowedOrientations: integralScreenOrientation

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: container
        anchors.fill: parent
        height: integral_Column.height  //Theme.paddingLarge
        width: page.width

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

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id : integral_Column
            width: page.width
            height:  childrenRect.height
            spacing: Theme.paddingSmall

            function calculateResultIntegral() {
                var numColumns
                result_TextArea.text = 'Calculating ...'
                if (orientation==Orientation.Portrait) {
                    numColumns=42      // Portrait
                } else {
                    if (Math.max(page.height,page.width) > 1000) {
                        numColumns=100  // Landscape on Nexus 4 smartphone
                    } else {
                        numColumns=80  // Landscape on Jolla smartphone
                    }
                }
                py.call('solver.calculate_Integral', [integrand_TextField.text,diff1_TextField.text,diff2_TextField.text,diff3_TextField.text,
                        limSup1_TextField.text,limSup2_TextField.text,limSup3_TextField.text,limInf1_TextField.text,limInf2_TextField.text,limInf3_TextField.text,
                        integralType_index,numDimensions_index+1,numColumns,
                        showIntegral,showTime,numDigText,numerIntegralType_index,simplifyResult_index,outputTypeResult_index], function(result) {
                    result_TextArea.text = result;
                })
            }

//            PageHeader {
//                title: qsTr("Integral")
//            }
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
            Button {
                id: calculate_Button
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width*0.60
                text: qsTr("Calculate")
                focus: true
                onClicked: integral_Column.calculateResultIntegral()
            }

            FontLoader {
                id: dejavusansmono
                source: "DejaVuSansMono.ttf"
            }

            Label {
               id:timer
               anchors.horizontalCenter: parent.horizontalCenter
               width: parent.width*0.50
               //width: parent.width  - Theme.paddingLarge
               text: timerInfo
               color: Theme.highlightColor
            }

            TextArea {
                id: result_TextArea
                //height: Math.max(page.width, 800, implicitHeight)
                width: parent.width
                readOnly: true
                font.family: dejavusansmono.name
                font.pixelSize: Theme.fontSizeExtraSmall
                color:'lightblue'
                placeholderText: "Integral calculation result"
                text : 'Loading Python and SymPy ...'
                Component.onCompleted: {
                   // _editor.textFormat = Text.RichText;
                }

                /* for the cover we hold the value */
                onTextChanged: {
                    console.log(implicitHeight)
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

            /*
            Python {
                id: py

                Component.onCompleted: {
                    // Add the Python library directory to the import path
                    var pythonpath = Qt.resolvedUrl('.').substr('file://'.length);
                    addImportPath(pythonpath);
                    console.log(pythonpath);

                    setHandler('timerPush', timerPushHandler);

                    // Asynchronous module importing
                    importModule('integral', function() {
                        result_TextArea.text='Python version ' + evaluate('integral.versionPython') + '.\n'
                        result_TextArea.text+='SymPy version ' + evaluate('integral.versionSymPy') + '\n'
                        timerInfo = evaluate('("loaded in %fs" % integral.loadingtimeSymPy)')

                        //console.log('Python version: ' + evaluate('integral.versionPython'));
                        //result_TextArea.text+='<FONT COLOR="LightGreen">Using Python version ' + evaluate('integral.versionPython') + '.</FONT>'
                        //console.log('SymPy version ' + evaluate('integral.versionSymPy') + evaluate('(" loaded in %f seconds." % integral.loadingtimeSymPy)'));
                        //result_TextArea.text+='<FONT COLOR="LightGreen">SymPy version ' + evaluate('integral.versionSymPy') + evaluate('(" loaded in %f seconds." % integral.loadingtimeSymPy)') + '</FONT><br>'
                    });
                }

                // shared via timerInfo with cover
                function timerPushHandler(pTimer) {
                    timerInfo =  pTimer + ' elapsed'
                }

                onError: {
                    // when an exception is raised, this error handler will be called
                    console.log('python error: ' + traceback);
                }

                onReceived: {
                    // asychronous messages from Python arrive here
                    // in Python, this can be accomplished via pyotherside.send()
                    console.log('got message from python: ' + data);
                }
            }
            */
        }
    }

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
}
