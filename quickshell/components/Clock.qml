import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    Layout.leftMargin: 6

    Layout.rightMargin: 3
    Layout.fillHeight: true
    implicitWidth: clockLabel.implicitWidth + 24  // 6px left + 18px right

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    Text {
        id: clockLabel
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 6
        }
        text: Qt.formatDateTime(sysClock.date, "ddd MMM d   hh:mm AP")
        font.family: "SF Pro"
        font.pixelSize: 20
        color: "#202020"
        renderType: Text.NativeRendering
    }
}
