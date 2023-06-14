import QtQuick 2.6
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5

Page {
    id: mainPage
    allowedOrientations: derivativeScreenOrientation
    property bool debug: true
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
        console.debug(numColumns)
        //calculateResultSolver()
    }
    PageHeader {
       title: cName
    }

    VisualItemModel {
        id: visualModel
        Derivative {}
        Solver {}
        Integral {}
        Limit {}
    }

    SlideshowView {
        id: slideshow
        width: parent.width
        height: parent.height
        //itemWidth: isTablet ? Math.round(parent.width) : parent.width
        //itemHeight: height
        //clip: true
        model: visualModel
        onCurrentIndexChanged: {
            //navigation.slideshowIndexChanged(currentIndex)
        }
        anchors {
            fill: parent
            top: parent.top
            //rightMargin: isPortrait ? 0 : infoPanel.visibleSize
            //bottomMargin: isPortrait ? infoPanel.visibleSize : 0
        }
        Component.onCompleted: {
        }
    }
}
