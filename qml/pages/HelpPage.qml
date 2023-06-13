import QtQuick 2.6
import Sailfish.Silica 1.0


Page {
    id: helpPage

    allowedOrientations: derivativeScreenOrientation

     Item {
        id: helpInfos
        property string text: if(orientation === Orientation.Portrait) {
                                  '<style>a:link { color: ' + Theme.primaryColor  + '; }</style>' +
                                  '<i>Mathematical operators :</i>' +
                                  '<br>+ - * / ** (power)' +
                                  '<br><br><i>Examples of functions :</i>' +
                                  '<br>sqrt, exp, log, sin, acos' +
                                  '<br><br><i>Examples of expressions :</i>' +
                                  '<br>1/x**n, sqrt(x/(x**3+1)),<br>q/(4*pi*epsilon0*r**2),<br>exp(-(x-x_0)**2/(2*sigma**2))' +
                                  '<br><br><i>Examples of variables (beta and<br>gamma can\'t be variables because<br>they are already used as functions) :</i>' +
                                  '<br>x, y, z, t, rho, theta, phi, Omega' +
                                  '<br><br>Look at the SymPy site :</FONT>' +
                                  '<br><a href="http://sympy.org"><b>http://sympy.org</b></a>'
                             } else {
                                  '<style>a:link { color: ' + Theme.primaryColor  + '; }</style>' +
                                  '<i>Mathematical operators :</i>' +
                                  '<br>+ - * / ** (power)' +
                                  '<br><br><i>Examples of functions :</i>' +
                                  '<br>sqrt, exp, log, sin, acos' +
                                  '<br><br><i>Examples of expressions :</i>' +
                                  '<br>1/x**n, sqrt(x/(x**3+1)),q/(4*pi*epsilon0*r**2),<br>exp(-(x-x_0)**2/(2*sigma**2))' +
                                  '<br><br><i>Examples of variables (beta and gamma can\'t be variables <br>because they are already used as functions) :</i>' +
                                  '<br>x, y, z, t, rho, theta, phi, Omega' +
                                  '<br><br>Look at the SymPy site :</FONT>' +
                                  '<br><a href="http://sympy.org"><b>http://sympy.org</b></a>'
                             }
    }

    SilicaFlickable {
        id: helpFlick
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        contentWidth: helpFlick.width

        VerticalScrollDecorator { flickable: helpFlick }

        Column {
            id: helpColumn
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr('Help on Operations')
            }
            Label {
                id: content
                text: helpInfos.text
                textFormat: Text.RichText
                width: helpFlick.width
                horizontalAlignment: Text.AlignHCenter;
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }
        }
    }
}

