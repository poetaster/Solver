import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: aboutPage

    allowedOrientations: derivativeScreenOrientation

     Item {
        id: aboutInfos
        property string version:'0.8.2'
        property string text: if(orientation === Orientation.Portrait) {
                                  '<style>a:link { color: ' + Theme.primaryColor  + '; }</style>' +
                                  'Derivative calculates mathematical<br>derivatives symbolically and numerically<br>(in next versions, also vector derivatives like<br>gradient, divergence, curl and Laplacian).' +
                                  '<br><br>This version of Derivative is written using<br>Python 3, SymPy, PyOtherSide, Qt5,<br>Qt Quick 2 (Silica Components).' +
                                  '<br><br>© 2011-2014 by Roberto Colistete Jr.' +
                                  '<br>Free & Open Source :' +
                                  '<br><a href="http://www.gnu.org/licenses/lgpl-3.0.html"><b>License LGPLv3</b></a>' +
                                  '<br><br>For more information, see the web site :' +
                                  '<br><a href="https://github.com/rcolistete/derivative-sailfish"><b>Derivative</b></a>' +
                                  '<br><br><FONT COLOR="violet">In l&hearts;ving memory of my wife Lorena</FONT>'
                               } else {
                                  '<style>a:link { color: ' + Theme.primaryColor  + '; }</style>' +
                                  'Derivative calculates mathematical derivatives symbolically<br>and numerically (in next versions, also vector derivatives<br>like gradient, divergence, curl and Laplacian).' +
                                  '<br><br>This version of Derivative is written using Python 3, SymPy, <br>PyOtherSide, Qt5, Qt Quick 2 (Silica Components).' +
                                  '<br><br>© 2011-2014 by Roberto Colistete Jr.' +
                                  '<br>Free & Open Source :' +
                                  '<br><a href="http://www.gnu.org/licenses/lgpl-3.0.html"><b>License LGPLv3</b></a>' +
                                  '<br><br>For more information, see the web site :' +
                                  '<br><a href="https://github.com/rcolistete/derivative-sailfish"><b>Derivative</b></a>' +
                                  '<br><br><FONT COLOR="violet">In l&hearts;ving memory of my wife Lorena</FONT>'
                              }
    }

    SilicaFlickable {
        id: aboutFlick
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        contentWidth: aboutFlick.width

        VerticalScrollDecorator { flickable: aboutFlick }

        Column {
            id: aboutColumn
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr('About Derivative')
            }
            Label {
                id:title
                text: 'Derivative  v' + aboutInfos.version
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                id: slogan
                text: qsTr('for Sailfish OS')
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Item {
                width: 1
                height: Theme.paddingMedium
            }
            Label {
                id: content
                text: aboutInfos.text
                width: aboutFlick.width
                // wrapMode: TextEdit.WordWrap
                horizontalAlignment: Text.AlignHCenter;
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.RichText
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
