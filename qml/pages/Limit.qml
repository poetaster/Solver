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
    SilicaFlickable {
        Component.onCompleted:  {
            cName = "Limit"
        }

        id: container
        anchors.fill: parent
        //height: contentItem.childrenRect.height
        width: page.width

        VerticalScrollDecorator { flickable: container }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
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
                onClicked: pageStack.push(Qt.resolvedUrl("Derivative.qml"))
            }
            MenuItem {
                text: "Integral"
                onClicked: pageStack.push(Qt.resolvedUrl("Integral.qml"))
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
            id : limit_Column
            width: page.width
            spacing: Theme.paddingSmall
            PageHeader {
                title: qsTr("Limit")
            }
            FontLoader { id: dejavusansmono; source: "file:DejaVuSansMono.ttf" }
            TextArea {
                id: result_TextArea

                height: tAreaH
                width: parent.width
                readOnly: true
                font.family: dejavusansmono.name
                color: 'lightblue'
                font.pixelSize: Theme.fontSizeSmallBase
                text : 'Loading Python and SymPy ...'
                Component.onCompleted: {
                    //_editor.textFormat = Text.RichText;
                }

                /* for the cover we hold the value */
                onTextChanged: {
                    console.log(implicitHeight)
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
            TextField {
                id: expression_TextField
                inputMethodHints: Qt.ImhNoAutoUppercase
                placeholderText: "sin(x)/x"
                label: qsTr("Limit expression")
                width: parent.width
                text : "sin(x)/x"
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: variable_TextField.focus = true
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
                width: parent.width
                ComboBox {
                    id: direction_ComboBox
                    width: page.width*0.55
                    label: qsTr("Direction ")
                    currentIndex: 0
                    menu: ContextMenu {
                        MenuItem { text: "Bilateral" }
                        MenuItem { text: "Left" }
                        MenuItem { text: "Right" }
                    }
                }
                Button {
                    id: calculate_Button
                    width: parent.width*0.35
                    text: qsTr("Calculate")
                    focus: true
                    onClicked: calculateResultLimit()
                }
            }
            Separator {
                id : limit_Separator
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width*0.9
                color: Theme.primaryColor
            }

            Label {
               id:timer
                anchors {
                    left: limit_Separator.left
                    topMargin: 2 * Theme.paddingLarge
                    bottomMargin: 2 * Theme.paddingLarge
                }
               width: parent.width  - Theme.paddingLarge
               text: timerInfo
               color: Theme.highlightColor
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
                    importModule('limit', function() {
                        //console.log('Python version: ' + evaluate('limit.versionPython'));
                        //console.log('SymPy version ' + evaluate('limit.versionSymPy') + evaluate('(" loaded in %f seconds.\n" % limit.loadingtimeSymPy)'));
                        result_TextArea.text='Python version ' + evaluate('limit.versionPython') + '.\n'
                        result_TextArea.text+='SymPy version ' + evaluate('limit.versionSymPy') + '\n'
                        timerInfo = evaluate('("loaded in %f seconds." % limit.loadingtimeSymPy)')
                    });
                }

                // shared via timerInfo with cover
                function timerPushHandler(pTimer) {
                    timerInfo = "Calculated in: " + pTimer
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
}
