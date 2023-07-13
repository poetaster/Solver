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
    property string welcome: ''

    notificationObj: pageStack.currentPage.notification
    initialPage: Component { Integral{} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    /* strip var from the result formula to present */
    function filterVariables(text) {
        const re0 = /·/g;
        const re1 = /π/g;
        const re2 = /√/g;
        const re3 = /φ/g;
        // rad2deg in exprtk
        const re5 = /deg/g;
        // log is ln natural e in exprtk
        const re6 = /ln/g;
        const newtxt = text.replace(re0, "*")
        newtxt = newtxt.replace(re1, "pi")
        newtxt = newtxt.replace(re2, "sqrt")
        newtxt = newtxt.replace(re3, "phi")
        //newtxt = newtxt.replace(re5, "rad2deg")
        //newtxt = newtxt.replace(re6, "log")
        return newtxt
    }


    Python {
        id: py

        Component.onCompleted: {

            // Add the Python library directory to the import path
            setHandler('timerPush', timerPushHandler);

            var pythonpath = Qt.resolvedUrl('python').substr('file://'.length);
            addImportPath(pythonpath);

            // Asynchronous module importing
            importModule('solver', function() {
                welcome ='Python ' + evaluate('solver.versionPython') + '.\n'
                welcome +='SymPy ' + evaluate('solver.versionSymPy') + '\n'
                welcome += evaluate('("loaded in %fs" % solver.loadingtimeSymPy)')
                // This is just anoying since it's slower to show than eval!
                notificationObj.notify(welcome)
            });
        }
        // shared via timerInfo with cover
        function timerPushHandler(pTimer) {
            timerInfo =  pTimer + ' elapsed'
        }

        function engineLoadedHandler(){
            //notificationObj.notify(welcome);
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


