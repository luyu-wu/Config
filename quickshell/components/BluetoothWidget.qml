import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Widgets

Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: 20 + 32  // icon size + 12px left + 20px right pad

    readonly property string iconName: {
        if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled)
            return "bluetooth-disabled";
        return "network-bluetooth-symbolic";
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: 28
        source: "image://icon/" + root.iconName
    }
}
