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
import "../.."

PopupWindow {
    Variables { id: v }
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

    // ── pipewire nodes ───────────────────────────────────────────────────────
    // Every audio node currently in the graph. Node type/name/description are
    // parsed from the registry global before the node lands in `nodes`, so
    // filtering on them here is safe.
    readonly property var audioNodes: Pipewire.nodes ? Pipewire.nodes.values.filter(node => node.audio !== null) : []

    // Device subsets. PwNodeType flags are bitwise, so a duplex device (both
    // sink and source) legitimately shows up in both lists. Streams are the
    // applications playing/capturing audio and are excluded here.
    readonly property var outputNodes: audioNodes.filter(node => (node.type & PwNodeType.AudioSink) === PwNodeType.AudioSink && (node.type & PwNodeType.Stream) === 0)
    readonly property var inputNodes: audioNodes.filter(node => (node.type & PwNodeType.AudioSource) === PwNodeType.AudioSource && (node.type & PwNodeType.Stream) === 0)

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // Device names can be arbitrarily long; keep every row inside the popup.
    readonly property int maxLabelLength: 30
    function deviceLabel(node) {
        const name = node.description || node.nickname || node.name || "Unknown";
        return name.length > maxLabelLength ? name.substring(0, maxLabelLength - 1) + "…" : name;
    }

    // Bind the nodes so volume/mute/properties stay live.
    PwObjectTracker {
        objects: root.audioNodes
    }

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
        color: v.shadowColor
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
        color: v.popupBackground
        border.color: v.popupBorder
        border.width: 1
    }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            anchors.topMargin: -1
            radius: dropdown.radius
            color: "transparent"
            border.color: v.outerBorderColor
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
            Layout.bottomMargin: 14
            from: 0
            to: 1
            value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
            enabled: root.sink !== null
            height: 40
            background: Rectangle {
                x: seekSlider.leftPadding
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                width: seekSlider.availableWidth
                height: 28
                radius: 14
                color: "#30303030"
                border.width: 1
                border.color: v.widgetHighlight
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
                if (root.sink && root.sink.audio)
                    root.sink.audio.volume = seekSlider.visualPosition;
            }
        }

        MenuDiv {}

        // ── no devices placeholder ───────────────────────────────────────
        Loader {
            Layout.fillWidth: true
            visible: root.audioNodes.length === 0
            sourceComponent: Item {
                implicitHeight: 36
                Text {
                    anchors.centerIn: parent
                    text: "No audio devices found"
                    color: v.textPlaceholder
                    font.pixelSize: 13
                }
            }
        }

        // ── output devices (pipewire sinks) ──────────────────────────────
        MenuLabel {
            label: "Output"
            labelElement.font.weight: 600
            labelElement.color: v.textPlaceholder
            visible: root.outputNodes.length > 0
        }
        Repeater {
            model: root.outputNodes

            delegate: IconItem {
                required property var modelData
                readonly property PwNode node: modelData

                label: root.deviceLabel(node)
                iconName: "audio-speakers-symbolic"
                selected: node === root.sink

                onTriggered: Pipewire.preferredDefaultAudioSink = node
            }
        }

        // ── input devices (pipewire sources) ─────────────────────────────
        MenuLabel {
            label: "Input"
            labelElement.font.weight: 600
            labelElement.color: v.textPlaceholder
            visible: root.inputNodes.length > 0
        }
        Repeater {
            model: root.inputNodes

            delegate: IconItem {
                required property var modelData
                readonly property PwNode node: modelData

                label: root.deviceLabel(node)
                iconName: "audio-input-microphone-symbolic"
                selected: node === root.source

                onTriggered: Pipewire.preferredDefaultAudioSource = node
            }
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
