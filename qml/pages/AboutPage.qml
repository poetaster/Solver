import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: aboutPage

    allowedOrientations: derivativeScreenOrientation

     Item {
        id: aboutInfos
        property string version:'0.1.0'
        property string text:  if(true) {
                '<style>a:link { color: ' + Theme.primaryColor  + '; }</style>' +
                        'Solver calculates Derivatives, Integrals and Limits<br>derivatives symbolically and numerically<br>' +
                        '<br><br>Solver is written using<br>Python 3, SymPy, PyOtherSide, Qt5,<br>Qt Quick 2 (Silica Components).' +
                        '<br><br>It is based in large part by work from © 2011-2014 by Roberto Colistete Jr.' +
                        '<br>Free & Open Source :' +
                        '<br><a href="http://www.gnu.org/licenses/lgpl-3.0.html"><b>License LGPLv3</b></a>' +
                        '<br><br>Source :' +
                        '<br><a href="https://github.com/poetaster/Solver"><b>Solver</b></a>'
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
                title: qsTr('About Solver')
            }
            Label {
                id:title
                text: 'Solver  v' + aboutInfos.version
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
