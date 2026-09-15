//@ pragma Env QS_SCREENSHOT=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
// `.`, not `screenshot`: this file is inside the directory, so importing it by
// name resolves to a path that does not exist and logs a warning.
import "."
import ".."

// The full-screen freeze frame plus selection UI, one layer surface per output.
//
// This is a normal (threaded) layer surface rather than the ScreencopyView
// Quickshell.Wayland offers for monitor capture: a screencopy surface has to be
// rendered wholesale by the compositor, which disallows the rounded selection
// outline's shader, and it cannot render the capture above itself.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlay

            required property var modelData

            Variables { id: v }

            readonly property bool isFocused: modelData.name === Screenshot.activeScreenName

            screen: modelData
            visible: Screenshot.overlayVisible
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            exclusiveZone: -1
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs:screenshot"
            // On demand keeps the surface out of the keyboard focus stack until
            // it maps, so the Hyprland bind that started this isn't still held.
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Deliberately no `mask` here. An empty Region mask does stop the
            // surface from taking pointer focus, but it also stops pointer
            // events from being delivered into the scene at all, which silently
            // kills the selection MouseArea. hypr/rules.lua already sets
            // `no_anim` on this namespace, which is what the mask was for.
            // Frozen desktop, behind the dimming layer drawn by RegionSelector.
            Image {
                anchors.fill: parent
                source: Screenshot.tempPath ? "file://" + Screenshot.tempPath : ""
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: true
                sourceSize.width: overlay.width
                sourceSize.height: overlay.height
            }

            Item {
                id: content

                anchors.fill: parent

                Connections {
                    target: Screenshot

                    // Once the capture is frozen, ask Hyprland where the cursor
                    // was so the guide crosshair starts under the pointer.
                    function onOverlayVisibleChanged() {
                        if (!Screenshot.overlayVisible || !overlay.isFocused)
                            return;
                        cursorPosProcess.running = true;
                    }

                    function onActiveChanged() {
                        if (!Screenshot.active)
                            selector.clearSelection();
                    }
                }

                Process {
                    id: cursorPosProcess

                    command: ["hyprctl", "cursorpos", "-j"]
                    running: false

                    stdout: StdioCollector {
                        onStreamFinished: {
                            try {
                                const pos = JSON.parse(this.text.trim());
                                selector.updateMouse(pos.x - overlay.modelData.x, pos.y - overlay.modelData.y);
                            } catch (e) {
                                console.warn("Failed to parse cursorpos:", e);
                            }
                        }
                    }
                }

                RegionSelector {
                    id: selector

                    anchors.fill: parent
                    visible: Screenshot.mode === "region"

                    onPointerPressed: selector.canceled = false
                    onRegionSelected: (x, y, width, height) => {
                        Screenshot.saveScreenshot(x, y, width, height, overlay.modelData.name);
                    }
                }

                ControlBar {
                    id: controlBar

                    visible: overlay.isFocused
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 60

                    modes: Screenshot.modes
                    mode: Screenshot.mode
                    editActive: Screenshot.editActive
                    tempActive: Screenshot.tempActive

                    onModeSelected: m => {
                        Screenshot.mode = m;
                    }
                }

                QuickToggle {
                    id: editToggleButton

                    visible: overlay.isFocused
                    active: Screenshot.editActive
                    // One action per bind, like the standalone overlay: turning
                    // the toggle on is what the keybind/click asks for, turning
                    // it off is done by the button again or by Temp.
                    behaviorOnDeactivate: false
                    imageSource: Qt.resolvedUrl("icons/edit.svg")
                    iconColor: v.accentForeground
                    backgroundColor: v.accentColor
                    shadowColor: v.shadowColor
                    borderColor: v.accentForeground
                    borderWidth: 1
                    targetX: (overlay.width - controlBar.targetMenuWidth) / 2 - 15 - width
                    targetY: controlBar.y + controlBar.height / 2
                    sourceX: overlay.width / 2 - 204 + 32
                    onClicked: Screenshot.toggleEdit()
                }

                QuickToggle {
                    id: tempToggleButton

                    visible: overlay.isFocused
                    active: Screenshot.tempActive
                    behaviorOnDeactivate: false
                    imageSource: Qt.resolvedUrl("icons/temp.svg")
                    iconColor: v.accentForeground
                    backgroundColor: v.accentColor
                    shadowColor: v.shadowColor
                    borderColor: v.accentForeground
                    borderWidth: 1
                    targetX: (overlay.width + controlBar.targetMenuWidth) / 2 + 15
                    targetY: controlBar.y + controlBar.height / 2
                    sourceX: overlay.width / 2 - 204 + 332
                    onClicked: Screenshot.toggleTemp()
                }
            }

            // The whole overlay is keyboard-modal while it's up, so the keys
            // below work on any monitor and the focused one only paints.
            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: event => {
                    handleKey(event);
                }

                function handleKey(event) {
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                        Screenshot.cancel();
                        event.accepted = true;
                        return;
                    }

                    if (event.key === Qt.Key_S) {
                        Screenshot.saveScreenshot(0, 0, overlay.modelData.width, overlay.modelData.height, overlay.modelData.name);
                        event.accepted = true;
                        return;
                    }

                    if (event.key === Qt.Key_E) {
                        Screenshot.toggleEdit();
                        event.accepted = true;
                        return;
                    }

                    if (event.key === Qt.Key_T) {
                        Screenshot.toggleTemp();
                        event.accepted = true;
                    }
                }
            }
        }
    }
}
