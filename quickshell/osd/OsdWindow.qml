import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import ".."
import "."

// Renders the OSD on every screen. Visibility and content come from the Osd
// singleton, which is also driven by the Hyprland keybinds over IPC.
Scope {
    id: root

    // Margin around the pill. It gives the clipped shadow room to draw before
    // it is cut off, and leaves headroom for the at-limit spring, which nudges
    // and grows the pill a few pixels past its resting box. Since this is only
    // the pill's inset inside the layer surface, animating the pill never moves
    // or resizes the surface itself.
    readonly property int shadowMargin: 20

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow
            required property var modelData
            Variables { id: v }

            screen: modelData
            anchors.top: true
            // The surface is inset by shadowMargin on every side and the pill is
            // centred inside it, so subtract the inset to keep Osd.topMargin
            // measuring to the visible pill rather than to the surface's edge.
            margins.top: Math.max(0, Osd.topMargin - root.shadowMargin)

            // The layer surface is intentionally larger than the pill: the
            // transparent margins are what the shadow renders into.
            implicitWidth: pill.implicitWidth + root.shadowMargin * 2
            implicitHeight: pill.implicitHeight + root.shadowMargin * 2
            exclusiveZone: -1
            color: "transparent"

            // Sit above fullscreen windows and never take input.
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs:osd"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region {}

            visible: Osd.visible && Osd.kind !== ""

            // ── Shadow mask ──────────────────────────────────────────
            // Fills the whole layer surface; the inner rectangle is inset by
            // shadowMargin so it matches the pill exactly. Inverting this mask
            // hides the part of the shadow that falls under the pill.
            Item {
                id: mask
                anchors.fill: parent
                visible: false
                layer.enabled: true
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: root.shadowMargin
                    radius: pill.radius
                    color: "#fff"
                }
            }

            // ── Shadow ───────────────────────────────────────────────
            // Also fills the whole surface, so the blur has the transparent
            // margins to spread into instead of being cut off at the pill.
            RectangularShadow {
                id: outerShadow
                anchors.fill: parent
                radius: pill.radius
                blur: 12
                color: v.shadowColor
                spread: -root.shadowMargin
                visible: false
            }
            MultiEffect {
                anchors.fill: outerShadow
                source: outerShadow
                maskSource: mask
                maskEnabled: true
                maskInverted: true
            }

            // ── The visible pill ─────────────────────────────────────
            OsdPill {
                id: pill
                anchors.centerIn: parent
                value: Osd.value
                iconName: Osd.iconName
                bumpToken: Osd.bumpToken
                bumpDirection: Osd.bumpDirection
            }
        }
    }
}
