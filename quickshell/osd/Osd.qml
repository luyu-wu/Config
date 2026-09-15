pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "."

// On-screen display feedback for volume and brightness.
//
// Driven from Hyprland by `quickshell ipc call osd <function>`.
//
// IPC handler functions with declared arguments require every argument to be
// supplied, so the step sizes are module properties rather than parameters
// where that keeps the keybinds argument-free.
Singleton {
    id: root

    // ── Configuration ───────────────────────────────────────────────
    // Maximum volume, mirroring swayosd's max_volume = 100
    readonly property real maxVolume: 1.0

    // Default volume step (swayosd's "raise"/"lower" used 5%).
    readonly property real volumeStep: 0.05
    // Fine volume step (the SHIFT + volume binds used 1%).
    readonly property real volumeFineStep: 0.01

    // How long the OSD stays on screen after the last change.
    readonly property int displayDuration: 800

    // Vertical offset from the top of the screen to the visible pill. OsdWindow
    // insets its layer surface by the pill's shadow margin, so this is measured
    // from the pill, not from the surface's edge.
    property real topMargin: 60

    // ── State ───────────────────────────────────────────────────────
    // "volume" | "brightness" | ""
    property string kind: ""
    property real value: 0
    property bool muted: false
    property bool visible: false

    // Bumped whenever a keypress pushes past a limit with nothing left to change
    // (volume already at 100%, brightness already at 0%, ...). The pill springs
    // on every change, so the keypress isn't silently swallowed.
    // +1 for a push past the top, -1 for a push past the bottom.
    property int bumpToken: 0
    property int bumpDirection: 1

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasSink: sink !== null && sink.audio !== null

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    readonly property string iconName: {
        if (root.kind === "brightness")
            return root.value > 0.5 ? "brightness-high" : "brightness-low";
        if (root.kind === "volume") {
            if (root.muted || root.value <= 0.0)
                return "audio-volume-muted";
            return root.value < 0.34 ? "audio-volume-low" : (root.value < 0.67 ? "audio-volume-medium" : "audio-volume-high");
        }
        return "";
    }

    // ── Show / hide ─────────────────────────────────────────────────
    function show(what) {
        if (what === "volume") {
            root.value = root.hasSink ? root.sink.audio.volume : 0;
            root.muted = root.hasSink ? root.sink.audio.muted : false;
        } else if (what === "brightness") {
            root.value = Backlight.percentage;
            root.muted = false;
        } else {
            return;
        }
        root.kind = what;
        root.visible = true;
        hideTimer.restart();
    }

    function hide() {
        root.visible = false;
        hideTimer.stop();
    }

    // A push past a limit: nudge the pill in the direction of the push. The
    // token drives the animation, the direction its sign; see OsdPill.qml.
    function bump(direction) {
        root.bumpDirection = direction >= 0 ? 1 : -1;
        root.bumpToken += 1;
    }

    Timer {
        id: hideTimer
        interval: root.displayDuration
        onTriggered: root.hide()
    }

    // ── Volume control ──────────────────────────────────────────────
    function setVolume(value) {
        if (!root.hasSink)
            return;
        const audio = root.sink.audio;
        const clamped = Math.max(0, Math.min(root.maxVolume, value));
        // Pushing past 100% (or below 0%) with nothing left to change makes the
        // assignment a no-op, so spring the pill instead of failing silently.
        const pastLimit = (value > root.maxVolume || value < 0) && Math.abs(clamped - audio.volume) < 1e-4;
        audio.volume = clamped;
        // Adjusting the volume always unmutes, matching swayosd-client.
        audio.muted = false;
        if (pastLimit)
            root.bump(value > root.maxVolume ? 1 : -1);
        root.show("volume");
    }

    function volumeUp(step) {
        if (!root.hasSink)
            return;
        root.setVolume(root.sink.audio.volume + (step !== undefined ? step : root.volumeStep));
    }

    function volumeDown(step) {
        if (!root.hasSink)
            return;
        root.setVolume(root.sink.audio.volume - (step !== undefined ? step : root.volumeStep));
    }

    function toggleMute() {
        if (!root.hasSink)
            return;
        root.sink.audio.muted = !root.sink.audio.muted;
        root.show("volume");
    }

    // ── IPC ─────────────────────────────────────────────────────────
    // All functions take no arguments so the keybinds stay simple:
    //   quickshell ipc -p ~/.config/quickshell call osd volumeUp
    IpcHandler {
        target: "osd"

        function volumeUp(): void {
            root.volumeUp();
        }

        function volumeUpFine(): void {
            root.volumeUp(root.volumeFineStep);
        }

        function volumeDown(): void {
            root.volumeDown();
        }

        function volumeDownFine(): void {
            root.volumeDown(root.volumeFineStep);
        }

        function volumeMute(): void {
            root.toggleMute();
        }

        function volumeRefresh(): void {
            root.show("volume");
        }

        function brightnessUp(): void {
            Backlight.increase();
        }

        function brightnessUpFine(): void {
            Backlight.increase(Backlight.fineStep);
        }

        function brightnessDown(): void {
            Backlight.decrease();
        }

        function brightnessDownFine(): void {
            Backlight.decrease(Backlight.fineStep);
        }

        function brightnessRefresh(): void {
            root.show("brightness");
        }
    }
}
