import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Widgets
import qs.popups.bluetooth

Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: 20 + 32  // icon size + 12px left + 20px right pad
    Rectangle {
        id: bluetoothWidget
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 3
        radius: 6
        color: bluetoothPopup.visible ? "#20000000" : "transparent"
    }

    readonly property string iconName: {
        if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled)
            return "bluetooth-disabled";
        return "network-bluetooth-symbolic";
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            bluetoothPopup.visible = !bluetoothPopup.visible;
        }
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: 28
        source: "image://icon/" + root.iconName
    }
    BluetoothPopup {
        id: bluetoothPopup
        visible: false
    }
}
