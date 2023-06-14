/*
  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>.
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5

Page {
    id: derivativePage

    allowedOrientations: derivativeScreenOrientation
    property bool debug: true
    property string showEquator: 'true'

    function calculateResultSolver() {
        result_TextArea.text = 'Calculating ...'
        py.call('solver.calculate_Solver', [expressionLeft.text,expressionRight.text,var1_TextField.text,var2_TextField.text,var3_TextField.text,numColumns,showEquator,showTime,numerApprox,numDigText,simplifyResult_index,outputTypeResult_index], function(result) {
            result_TextArea.text = result;
        })
    }

    onOrientationChanged:  {
        if ( orientation === Orientation.Portrait ) {
            if (debug) console.debug("port")
            tAreaH =  800
            numColumns = 40    // Portrait
        } else {
            if (debug) console.debug("land")
            tAreaH = 450
            numColumns= 100
        }
        if (debug) console.debug(Orientation.Portrait)
        //console.debug(numColumns)
        calculateResultSolver()
    }
    PageHeader {
        title: qsTr("Solver")
    }
    SilicaFlickable {
        id: container
        anchors.fill: parent
        height: childrenRect.height
        width: parent.width

        Component.onCompleted: {
            cName = "Solver"
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
                onClicked: pageStack.replace(Qt.resolvedUrl("Integral.qml"))
            }
            MenuItem {
                text: "Limit"
                onClicked: pageStack.replace(Qt.resolvedUrl("Limit.qml"))
            }
        }

        FontLoader { id: dejavusansmono; source: "file:DejaVuSansMono.ttf" }

        Column {
            id : derivative_Column
            width: parent.width
            height: parent.height * 0.45 - Theme.paddingLarge // childrenRect.height
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
                    const txt = '<FONT COLOR="lightblue" SIZE="16px"><pre>'
                    txt = txt + text + '<pre></FONT>'
                    return txt
                }
            }
// Try top
          Column {
            id : input_Column
            width: parent.width
            height:  parent.height * .55 - Theme.paddingLarge
            spacing: Theme.paddingSmall
            //anchors.top: derivative_Column.bottom
            //anchors.bottomMargin: Theme.paddingLarge
            Row{
            //anchors.leftMargin: Theme.paddingLarge
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: Theme.paddingLarge
            TextField {
                id: expressionLeft
                width: parent.width / 2 - Theme.paddingLarge
                inputMethodHints: Qt.ImhNoAutoUppercase
                label: qsTr("Exp. Left")
                placeholderText: "6/(5-sqrt(x))"
                text: "6/(5-sqrt(x))"
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: expressionRight.focus = true
            }
            TextField {
                id: expressionRight
                width: parent.width  / 2 - Theme.paddingLarge
                inputMethodHints: Qt.ImhNoAutoUppercase
                label: qsTr("Exp. Right")
                placeholderText: "sqrt(x)"
                text: "sqrt(x)"
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: var1_TextField.focus = true
            }
          }
            Grid {
                id: diffs_Item
                anchors {left: parent.left; right: parent.right}
                width: parent.width
                rows: 1
                columns: 3
                TextField {
                   id: var1_TextField
                   width: parent.width*0.20
                   inputMethodHints: Qt.ImhNoAutoUppercase
                   label: qsTr("Solve for:")
                   placeholderText: "x"
                   text: "x"
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
                   text: ""
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
                   text: ""
                   EnterKey.enabled: text.length > 0
                   EnterKey.iconSource: "image://theme/icon-m-enter-next"
                   EnterKey.onClicked: calculate_Button.focus = true
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
                    onClicked: calculateResultSolver()
                }

            }

            Label {
               id:timer
               visible: orientation == Orientation.Portrait ? 1 : 0
               anchors.horizontalCenter: parent.horizontalCenter
               width: parent.width*0.50
               text: timerInfo
               color: Theme.highlightColor
            }
          }
        }
        VerticalScrollDecorator { flickable: container }
    }

}
