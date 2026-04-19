import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import Quickshell.Widgets
import qs.popups.network

Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: 44
    Rectangle {
        id: networkWidget
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 3
        radius: 6
        color: networkPopup.visible ? "#20000000" : "transparent"
    }

    readonly property var wifiDevice: {
        let devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].connected && devs[i].type === DeviceType.Wifi)
                return devs[i];
        }
        return null;
    }

    readonly property var activeWifiNetwork: {
        if (!wifiDevice)
            return null;
        let nets = wifiDevice.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i].connected)
                return nets[i];
        }
        return null;
    }

    readonly property bool ethernetConnected: {
        let devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].connected && devs[i].type !== DeviceType.Wifi)
                return true;
        }
        return false;
    }

    readonly property string iconName: {
        if (activeWifiNetwork) {
            let s = activeWifiNetwork.signalStrength;
            if (s > 0.75)
                return "network-wireless-signal-excellent-symbolic";
            if (s > 0.50)
                return "network-wireless-signal-good-symbolic";
            if (s > 0.25)
                return "network-wireless-signal-weak-symbolic";
            return "network-wireless-signal-none-symbolic";
        }
        if (ethernetConnected)
            return "network-wired";
        return "network-offline";
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            networkPopup.visible = !networkPopup.visible;
        }
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: 26
        source: "image://icon/" + root.iconName
    }
    NetworkPopup {
        id: networkPopup
        visible: false
    }
}
