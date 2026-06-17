import Quickshell
import QtQuick
import QtQuick.Layouts
import "components"

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData

        screen: modelData
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 56  // 40px bar + 16px shadow
        exclusiveZone: 50
        color: "transparent"

        // ── Shadow gradient below the bar ─────────────
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: 16
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.15)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.0)
                }
            }
        }

        // ── Bar background ────────────────────────────
        Rectangle {
            id: barBackground
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: 40
            color: "#d1e4e7ef"

            RowLayout {
                anchors {
                    fill: parent
                    bottomMargin: 1
                }
                spacing: 0

                // ── Left ──────────────────────────────
                Logo {}
                WindowTitle {}
                AppMenu {}

                // ── Spacer ────────────────────────────
                Item {
                    Layout.fillWidth: true
                }

                // ── Right ─────────────────────────────
                TrayWidget {}
                MprisWidget {}
                VolumeWidget {}
                BluetoothWidget {}
                BatteryWidget {}
                NetworkWidget {}

                Clock {}
            }

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 1
                color: "#a0a0a0"
            }
        }
    }
}
