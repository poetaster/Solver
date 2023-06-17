import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: popup
    anchors.top: parent.top

    property int padding: Theme.paddingLarge
    property int labelMargin: Theme.paddingLarge

    width: parent.width
    height: message.paintedHeight + padding

    property alias title: message.text
    property alias timeout: hideTimer.interval
    property alias background: bg.color

    property color defaultColor: "cyan"
    property color textColor: "white"

    property real rectOpacity: 0.9
    property int pixelSize:48

    visible: opacity > 0
    opacity: 0.0

    Behavior on opacity {
        //FadeAnimation {}
    }

    Rectangle {
        id: bg
        anchors.fill: parent
    }

    Timer {
        id: hideTimer
        triggeredOnStart: false
        repeat: false
        interval: 5000
        onTriggered: popup.hide()
    }

    function hide() {
        if (hideTimer.running)
            hideTimer.stop()
        popup.opacity = 0.0
    }

    function show() {
        popup.opacity = 1.0
        hideTimer.restart()
    }

    function notify(text, color) {
        popup.title = text
        if (color && (typeof(color) != "undefined"))
            bg.color = color
        else
            bg.color = Qt.rgba(defaultColor.r, defaultColor.g, defaultColor.b , rectOpacity)
        show()
    }

    Label {
        id: message

        anchors.verticalCenter: popup.verticalCenter

        anchors.left: parent.left
        anchors.leftMargin: labelMargin
        anchors.right: parent.right
        anchors.rightMargin: labelMargin

        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        wrapMode: Text.Wrap

        font.pixelSize: popup.pixelSize
        color: textColor
    }

    onClicked: hide()
}
