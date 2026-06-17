import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs.popups.battery

Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: batteryIcon.implicitWidth + 32  // 12px left + 20px right pad

    readonly property var battery: UPower.displayDevice

    readonly property bool charging: {
        let s = battery.state;
        return s === UPowerDeviceState.Charging || s === UPowerDeviceState.FullyCharged || s === UPowerDeviceState.PendingCharge;
    }
    Rectangle {
        id: batteryWidget
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 3

        radius: 6
        color: batteryPopup.visible ? "#20000000" : "transparent"
    }

    readonly property string iconName: {
        let pct = battery.ready ? Math.round(battery.percentage * 10) * 10 : 0;
        pct = Math.max(0, Math.min(100, pct));
        let padded = pct.toString().padStart(3, "0");
        return "battery-" + padded + (charging ? "-charging" : "");
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            batteryPopup.visible = !batteryPopup.visible;
        }
    }

    IconImage {
        id: batteryIcon
        anchors.centerIn: parent
        implicitSize: 32
        source: "image://icon/" + root.iconName
    }
    BatteryPopup {
        id: batteryPopup
        visible: false
    }
}
