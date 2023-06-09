/*
  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.6
import "pages"


ApplicationWindow {
    property int orientation_index: 2
    property bool showDerivative: true
    property bool showTime: true
    property bool numerApprox: false
    property string numDigText: '15'
    property int simplifyResult_index: 2
    property int numColumns:42
    property int outputTypeResult_index: 1
    property string resultText: ''
    property string timerInfo: ''
    property int derivativeScreenOrientation: Orientation.Portrait | Orientation.Landscape

    initialPage: Component { Derivative { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Python {
        id: py

        Component.onCompleted: {
            // Add the Python library directory to the import path

            setHandler('timerPush', timerPushHandler);

            var pythonpath = Qt.resolvedUrl('python').substr('file://'.length);
            addImportPath(pythonpath);

            //console.log(pythonpath);

            // Asynchronous module importing
            importModule('solver', function() {
                result_TextArea.text='Python version ' + evaluate('derivative.versionPython') + '.\n'
                result_TextArea.text+='SymPy version ' + evaluate('derivative.versionSymPy') + '\n'
                timerInfo = evaluate('("loaded in %fs" % solver.loadingtimeSymPy)')
               /*
                console.log('Python version: ' + evaluate('derivative.versionPython'));
                result_TextArea.text+='<FONT COLOR="LightGreen">Using Python version ' + evaluate('derivative.versionPython') + '.</FONT>'
                console.log('SymPy version ' + evaluate('derivative.versionSymPy') + evaluate('(" loaded in %f seconds." % derivative.loadingtimeSymPy)'));
                result_TextArea.text+='<FONT COLOR="LightGreen">SymPy version ' + evaluate('derivative.versionSymPy') + evaluate('(" loaded in %f seconds." % derivative.loadingtimeSymPy)') + '</FONT><br>'
                */
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
}


