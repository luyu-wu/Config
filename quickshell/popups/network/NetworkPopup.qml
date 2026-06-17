import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Networking
import qs.share.menu

PopupWindow {
    id: root
    implicitWidth: 340
    implicitHeight: menuColumn.implicitHeight + 8
    grabFocus: true
    anchor {
        item: networkWidget
        edges: Edges.Bottom
        rect.y: 38
        rect.x: 16 - networkWidget.width / 2
    }
    color: "transparent"

    // ── networking ───────────────────────────────────────────────────────────
    // Networking is a singleton — access directly, do not instantiate.
    // Find the first WifiDevice from Networking.devices.
    property WifiDevice wifiDev: {
        for (const d of Networking.devices.values) {
            if (d.type === DeviceType.Wifi)
                return d;
        }
        return null;
    }
    // Enable scanner while popup is visible so the list stays live.
    onVisibleChanged: {
        if (wifiDev)
            wifiDev.scannerEnabled = visible;
    }

    // ── visual chrome (unchanged) ────────────────────────────────────────────
    Item {
        id: mask
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Rectangle {
            anchors.fill: parent
            anchors.margins: 8
            anchors.topMargin: 0
            radius: 8
            color: "#fff"
        }
    }

    RectangularShadow {
        id: outerShadow
        anchors.fill: parent
        radius: dropdown.radius
        blur: 10
        color: Qt.rgba(0, 0, 0, 0.35)
        spread: -8
        visible: false
    }

    MultiEffect {
        anchors.fill: outerShadow
        source: outerShadow
        maskSource: mask
        maskEnabled: true
        maskInverted: true
    }

    Rectangle {
        id: dropdown
        anchors.fill: parent
        anchors.margins: 8
        anchors.topMargin: 0
        radius: 8
        color: "#b1e4e7ef"
        border.color: "#A0A0A0"
        border.width: 1
    }

    // ── menu contents ────────────────────────────────────────────────────────
    ColumnLayout {
        id: menuColumn
        anchors {
            top: dropdown.top
            left: dropdown.left
            right: dropdown.right
            topMargin: 4
            bottomMargin: 4
            leftMargin: 0
            rightMargin: 0
        }
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 10
            color: "transparent"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 0
            Layout.rightMargin: 14

            MenuLabel {
                label: "Wi-Fi"
                labelElement.font.weight: 600
                Layout.fillWidth: true
            }
            Rectangle {

                implicitWidth: 48
                implicitHeight: 28
                color: Networking.wifiEnabled ? "#1687ff" : "#afb0b5"
                radius: 16
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Networking.wifiEnabled ? 22 : 2
                    implicitWidth: 24
                    implicitHeight: 24
                    color: "#fff"
                    radius: 12
                    Behavior on x {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 160
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 3
            color: "transparent"
        }

        MenuDiv {}

        MenuLabel {
            label: "Networks"
            labelElement.font.weight: 600
            labelElement.color: "#90000000"
        }

        // ── no adapter / scanning placeholder ────────────────────────────────
        Loader {
            Layout.fillWidth: true
            visible: !wifiDev || (wifiDev.networks.count === 0)
            sourceComponent: Item {
                implicitHeight: 36
                Text {
                    anchors.centerIn: parent
                    text: !wifiDev ? "No Wi-Fi adapter found" : wifiDev.scannerEnabled ? "Scanning…" : "No networks"
                    color: "#70000000"
                    font.pixelSize: 13
                }
            }
        }

        // ── network list ─────────────────────────────────────────────────────
        // WifiDevice.networks is an ObjectModel; each item is a
        // connect(), disconnect(), forget()
        Repeater {
            model: wifiDev ? wifiDev.networks : null

            delegate: IconItem {
                required property WifiNetwork modelData

                label: modelData.name || "(hidden)"

                iconName: {
                    const secured = modelData.security !== WifiSecurityType.None;
                    const s = modelData.signalStrength;
                    if (modelData.connected)
                        return "folder-wifi";
                    if (s > 0.75)
                        return "network-wireless-signal-excellent-symbolic";
                    if (s > 0.50)
                        return "network-wireless-signal-good-symbolic";
                    if (s > 0.25)
                        return "network-wireless-signal-weak-symbolic";
                    return "network-wireless-signal-none-symbolic";
                }
                // Highlight the currently connected network
                selected: modelData.connected

                onTriggered: {
                    if (modelData.connected) {
                        // Already connected — disconnect on second click
                        modelData.disconnect();
                    } else {
                        // connect() fires; an NM auth agent handles passwords
                        // for unknown secured networks automatically
                        modelData.connect();
                    }
                    root.visible = false;
                }
            }
        }

        MenuDiv {}

        MenuItem {
            label: "Wi-Fi Settings…"
            onTriggered: {
                preferences.running = true;
                root.visible = false;
            }
        }

        Item {
            Layout.preferredHeight: 8
        }
    }

    // ── processes ────────────────────────────────────────────────────────────
    Process {
        id: preferences
        command: ["bash", "-c", "kcmshell6 kcm_networkmanagement"]
        running: false
    }
}
