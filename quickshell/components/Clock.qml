import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.popups.clock
import ".."

Item {
    Variables { id: v }
    id: root
    Layout.leftMargin: 6

    Layout.rightMargin: 3
    Layout.fillHeight: true
    implicitWidth: clockLabel.implicitWidth + 24  // 6px left + 18px right

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: clockPopup.visible ? v.widgetHighlight : "transparent"
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
        color: v.textColor
        renderType: Text.NativeRendering
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            clockPopup.visible = !clockPopup.visible;
            clockPopup.updatesEnabled = clockPopup.visible;
        }
    }
    ClockPopup {
        id: clockPopup
        visible: false
    }
}
