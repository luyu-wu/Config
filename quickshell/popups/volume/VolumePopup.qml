import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire

import qs.share.menu

PopupWindow {
    id: root

    implicitWidth: 360
    implicitHeight: menuColumn.implicitHeight + 8
    grabFocus: true

    anchor {
        item: volumeWidget
        edges: Edges.Bottom
        rect.y: 38
        rect.x: 16 - volumeWidget.width / 2
    }
    color: "transparent"

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
        MenuLabel {
            label: "Sound"
            labelElement.font.weight: 600
        }
        Slider {
            id: seekSlider
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            from: 0
            to: 1
            value: Pipewire.defaultAudioSink.audio.volume
            height: 40
            background: Rectangle {
                x: seekSlider.leftPadding
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                width: seekSlider.availableWidth
                height: 28
                radius: 14
                color: "#30303030"
                border.width: 1
                border.color: "#77a0a2"
                ClippingRectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: 14
                    color: "transparent"

                    Rectangle {
                        width: seekSlider.visualPosition * (parent.width - 24) + 12
                        height: parent.height
                        color: "#ffffff"
                    }
                    IconImage {
                        x: 6
                        y: 3
                        implicitSize: 20
                        source: "image://icon/multimedia-volume-control-symbolic"
                        opacity: 0.3
                        visible: true
                    }
                }
            }
            handle: Rectangle {
                x: seekSlider.leftPadding + (seekSlider.availableWidth - 28) * seekSlider.visualPosition
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                implicitWidth: 28
                implicitHeight: 28
                radius: 14
                color: "#f0f0f0"
                border.color: "#30606060"
            }
            onMoved: {
                Pipewire.defaultAudioSink.audio.volume = seekSlider.visualPosition;
            }
        }

        MenuDiv {}
        MenuLabel {
            label: "Output"
            labelElement.font.weight: 600
            labelElement.color: "#90000000"
        }
        IconItem {
            label: Pipewire.defaultAudioSink.description
            iconName: "headphone"
            selected: true
        }

        MenuDiv {}
        MenuItem {
            label: "Sound Settings..."
            onTriggered: {
                preferences.running = true;
                root.visible = false;
            }
        }
        Process {
            id: preferences
            command: ["bash", "-c", "kcmshell6 kcm_pulseaudio"]
            running: false
        }

        // bottom padding
        Item {
            Layout.preferredHeight: 8
        }
    }
}
