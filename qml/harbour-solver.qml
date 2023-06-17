/*
  Copyright (C) 2023 Mark Washeim <blueprint@poetaster.de>
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import "pages"
import "components"
import "js/storage.js" as Store

ApplicationWindow {
    id: root
    property int derivativeScreenOrientation: Orientation.Portrait | Orientation.Landscape
    property int orientation_index: 2
    property int integralType_index : 0
    property int numerIntegralType_index : 1
    property int numDimensions_index : 0
    property bool showIntegral: true
    property bool showDerivative: true
    property bool showLimit: true
    property bool showTime: false
    property bool numerApprox: false
    property string numDigText: '10'
    property int simplifyResult_index: 2
    property int numColumns:80
    property int outputTypeResult_index: 1
    property string resultText: ''
    property string timerInfo: ''
    property int tAreaH: 1000
    property string cName: 'Derivative'
    property string showEquator: 'true'
    property var notificationObj
    property var settingsObj

    notificationObj: pageStack.currentPage.notification
    initialPage: Component { Integral{} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")



    Python {
        id: py

        Component.onCompleted: {

            // Add the Python library directory to the import path
            setHandler('timerPush', timerPushHandler);

            var pythonpath = Qt.resolvedUrl('python').substr('file://'.length);
            addImportPath(pythonpath);

            // Asynchronous module importing
            importModule('solver', function() {
                resultText='Python version ' + evaluate('solver.versionPython') + '.\n'
                resultText+='SymPy version ' + evaluate('solver.versionSymPy') + '\n'
                timerInfo = evaluate('("loaded in %fs" % solver.loadingtimeSymPy)')
               notificationObj.notify(resultText + timerInfo)

               /*
                console.log('Python version: ' + evaluate('solver.versionPython'));
                result_TextArea.text+='<FONT COLOR="LightGreen">Using Python version ' + evaluate('solver.versionPython') + '.</FONT>'
                console.log('SymPy version ' + evaluate('solver.versionSymPy') + evaluate('(" loaded in %f seconds." % solver.loadingtimeSymPy)'));
                result_TextArea.text+='<FONT COLOR="LightGreen">SymPy version ' + evaluate('solver.versionSymPy') + evaluate('(" loaded in %f seconds." % solver.loadingtimeSymPy)') + '</FONT><br>'
                */
            });
        }
        // shared via timerInfo with cover
        function timerPushHandler(pTimer) {
            timerInfo =  pTimer + ' elapsed'
        }

        function engineLoadedHandler(){
            notificationObj.notify("Symbolic engine loaded");
            root.engineLoaded = true;

            //changeTrigonometricUnit(settingsObj.angleUnit);
            //changeReprFloatPrecision(settingsObj.reprFloatPrecision);
            //enableSymbolicMode(settingsObj.symbolicMode);
            //enableAutoSimplify(settingsObj.autoSimplify);
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


