import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "."

Scope {
    id: root

    readonly property var trackedNotifications: Notifications.trackedNotifications

    // Width of the strip the toasts are laid out in; the surface itself is the
    // whole screen.
    readonly property int surfaceWidth: 404

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData
            Variables { id: v }

            screen: modelData
            color: "transparent"

            // Spans the screen, with a static size: the width is what the surface
            // is configured at, and it never changes. Full width on purpose, so
            // the surface's right edge is the screen's right edge and a toast
            // sliding out is clipped there rather than being cut off by the
            // screen. Toasts are laid out in a strip of surfaceWidth against that
            // edge, and the right-hand margin keeps them clear of it.
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            margins.top: 56
            margins.right: 12

            // Only the toasts may take pointer input. Everywhere else clicks pass
            // through to whatever is underneath, and the mask also clips the
            // surface, so a toast sliding out vanishes at its right edge.
            mask: Region {
                Region { x: column.x; y: column.y; width: column.width; height: column.height }
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "qs:notifications"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Item {
                id: column
                // Right-anchored rather than at a fixed x: the surface is only
                // sized once the compositor configures it, and anchoring puts the
                // strip against the right edge as soon as it is known.
                anchors {
                    top: parent.top
                    right: parent.right
                }
                width: root.surfaceWidth
                height: 0

                // Where the stack is heading. Growing is safe at any moment, but
                // shrinking the instant a toast starts sliding up would clip its
                // bottom edge as it arrives, so the shrink waits for the shift to
                // settle. This is also the region the input mask is cut to, which
                // is why it stays trimmed to the stack.
                property int pendingHeight: 0

                Timer {
                    id: settleHeight
                    interval: 250
                    onTriggered: column.height = column.pendingHeight
                }

                function relayout() {
                    let offset = 0;
                    for (let i = repeater.count - 1; i >= 0; --i) {
                        const toast = repeater.itemAt(i);
                        if (!toast)
                            continue;
                        // A toast on its way out holds its position but no longer
                        // holds space, so the rest collapse into the gap while it
                        // slides away.
                        if (toast.closing)
                            continue;
                        toast.y = offset;
                        offset += toast.height;
                    }

                    column.pendingHeight = offset;
                    if (offset >= column.height) {
                        settleHeight.stop();
                        column.height = offset;
                    } else {
                        settleHeight.restart();
                    }
                }

                Repeater {
                    id: repeater
                    model: root.trackedNotifications
                    onCountChanged: column.relayout()

                    delegate: NotificationToast {
                        required property var modelData

                        width: column.width
                        notification: modelData
                        onHeightChanged: column.relayout()
                        onClosingChanged: column.relayout()
                    }
                }
            }
        }
    }
}
