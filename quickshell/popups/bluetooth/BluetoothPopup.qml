import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import qs.share.menu

PopupWindow {
    id: root

    implicitWidth: 340
    implicitHeight: menuColumn.implicitHeight + 8
    grabFocus: true

    anchor {
        item: bluetoothWidget
        edges: Edges.Bottom
        rect.y: 38
        rect.x: 16 - bluetoothWidget.width / 2
    }
    color: "transparent"

    property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter
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
                label: "Bluetooth"
                labelElement.font.weight: 600
                Layout.fillWidth: true
            }
            Rectangle {

                implicitWidth: 48
                implicitHeight: 28
                color: defaultAdapter.enabled ? "#1687ff" : "#afb0b5"
                radius: 16
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: defaultAdapter.enabled ? 22 : 2
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
                    onClicked: defaultAdapter.enabled = !defaultAdapter.enabled
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
            implicitHeight: 6
            color: "transparent"
        }
        MenuDiv {}
        // ── no adapter placeholder ────────────────────────────────────
        Loader {
            Layout.fillWidth: true
            visible: !defaultAdapter
            sourceComponent: Item {
                implicitHeight: 36
                Text {
                    anchors.centerIn: parent
                    text: "No Bluetooth adapter found"
                    color: "#70000000"
                    font.pixelSize: 13
                }
            }
        }

        // ── paired devices ─────────────────────────────────────────────
        MenuLabel {
            label: "Paired"
            labelElement.font.weight: 600
            labelElement.color: "#90000000"
            visible: defaultAdapter && defaultAdapter.enabled
        }

        Repeater {
            model: defaultAdapter ? defaultAdapter.devices : null

            delegate: IconItem {
                required property var modelData
                readonly property BluetoothDevice device: modelData

                visible: device.paired

                label: device.name || device.deviceName || device.address
                iconName: device.icon || (device.connected ? "network-bluetooth-symbolic" : "bluetooth-symbolic")
                selected: device.connected

                onTriggered: {
                    if (device.connected) {
                        device.disconnect();
                    } else {
                        device.connect();
                    }
                }
            }
        }

        // ── available devices (unpaired, with a real name) ─────────────
        MenuLabel {
            label: "Available"
            labelElement.font.weight: 600
            labelElement.color: "#90000000"
            visible: {
                if (!defaultAdapter || !defaultAdapter.enabled)
                    return false;
                for (let i = 0; i < defaultAdapter.devices.count; i++) {
                    let d = defaultAdapter.devices.get(i);
                    if (!d.paired && d.deviceName && d.deviceName.length > 0)
                        return true;
                }
                return false;
            }
        }

        Repeater {
            model: defaultAdapter ? defaultAdapter.devices : null

            delegate: IconItem {
                required property var modelData
                readonly property BluetoothDevice device: modelData

                // Only show unpaired devices that report a proper name
                visible: !device.paired && (device.deviceName && device.deviceName.length > 0)

                label: device.name || device.deviceName
                iconName: device.icon || "bluetooth-symbolic"
                selected: false

                onTriggered: {
                    device.connect();
                }
            }
        }

        MenuDiv {}
        MenuItem {
            label: "Bluetooth Settings..."
            onTriggered: {
                preferences.running = true;
                root.visible = false;
            }
        }
        Process {
            id: preferences
            command: ["bash", "-c", "kcmshell6 kcm_bluetooth"]
            running: false
        }

        Item {
            Layout.preferredHeight: 8
        }
    }
}
