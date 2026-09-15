pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Region screenshot overlay, ported from hypr/Scripts/HyprQuickFrame so it can
// live inside the main quickshell instance instead of spawning `qs -p ... -n`
// (a whole new process, GPU context and QML engine) on every invocation.
//
// Bound in hyprland as global shortcuts (see hypr/binds.lua):
//   quickshell:region          region capture, save + copy
//   quickshell:regionTemp      region capture, copy only
//   quickshell:regionEdit      region capture, open satty to annotate
//
// Unlike the standalone version, the whole-screen capture is done here by
// grabbing a freeze frame once, rather than shelling out to grim on every use.
Singleton {
    id: root

    // ── State ───────────────────────────────────────────────
    // True from the moment a capture starts until the overlay is dismissed.
    property bool active: false
    // The overlay surface only exists once the freeze frame has been grabbed,
    // which also keeps a brief flash of the live desktop from being captured.
    property bool overlayVisible: false

    // "region" for now; "edit"/"temp" are the quick-save variants.
    property string mode: "region"
    property bool editActive: false
    property bool tempActive: false

    readonly property var modes: ["edit", "region", "temp"]

    // The screen the overlay is anchored to: the focused monitor, falling back
    // to the first screen before Hyprland has reported one.
    readonly property var targetMonitor: Hyprland.focusedMonitor
    readonly property string activeScreenName: {
        if (targetMonitor)
            return targetMonitor.name;
        return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
    }

    // ── Toggles ─────────────────────────────────────────────────────
    function setEditActive(value) {
        root.editActive = !!value;
        if (root.editActive)
            root.tempActive = false;
    }

    function setTempActive(value) {
        root.tempActive = !!value;
        if (root.tempActive)
            root.editActive = false;
    }

    function toggleEdit() {
        root.setEditActive(!root.editActive);
    }

    function toggleTemp() {
        root.setTempActive(!root.tempActive);
    }

    function toggleEditMode() {
        root.mode = root.mode === "edit" ? "region" : "edit";
    }

    // ── Entry points ────────────────────────────────────────
    function start(mode, action): void {
        if (root.active)
            return;
        root.mode = mode === "edit" ? "edit" : "region";
        root.editActive = action === "edit";
        root.tempActive = action === "temp";
        root.active = true;
        root.overlayVisible = false;
        freezeTimer.restart();
    }

    function cancel(): void {
        if (!root.active)
            return;
        root.teardown();
    }

    // `rm` on a single file path, not Quickshell.execDetached: that would need a
    // shell to expand it.
    function discardFrame() {
        if (!root.tempPath)
            return;
        cleanupProcess.exec(["rm", "-f", root.tempPath]);
    }

    function teardown(): void {
        captureProcess.running = false;
        // Left running on purpose: a save that was already pipelined still
        // needs its freeze frame. It cleans up after itself either way.
        freezeTimer.stop();
        if (!screenshotProcess.running) {
            root.discardFrame();
            root.tempPath = "";
        }
        root.active = false;
        root.overlayVisible = false;
    }

    // ── Global shortcuts ────────────────────────────────────
    // Registered with Hyprland's global shortcut protocol, so the keybinds
    // dispatch straight into the running shell with no process spawn and no IPC
    // round trip:
    //   hl.bind(SUPER_SHIFT .. " + S", hl.dsp.global("quickshell:region"))
    // `locked = true` has no effect on a global bind unless it is also flagged
    // non_consuming; the overlay is already reachable from the lock screen.
    GlobalShortcut {
        name: "region"
        description: "Take a region screenshot (save and copy)"
        onPressed: root.start("region", "")
    }

    GlobalShortcut {
        name: "regionTemp"
        description: "Take a region screenshot, copied to the clipboard only"
        onPressed: root.start("region", "temp")
    }

    GlobalShortcut {
        name: "regionEdit"
        description: "Take a region screenshot and annotate it first"
        onPressed: root.start("region", "edit")
    }

    // ── Region → full screen ──────────────────────────────────────────
    // Maps a selection on one monitor into a crop of the stitched
    // all-monitors layout, in physical pixels.
    function calculateCrop(x, y, width, height, screenName) {
        let minX = Infinity;
        let minY = Infinity;
        let target = null;
        const monitors = Hyprland.monitors.values;
        for (const m of monitors) {
            minX = Math.min(minX, m.lastIpcObject.x);
            minY = Math.min(minY, m.lastIpcObject.y);
            if (m.name === screenName)
                target = m;
        }
        if (!target)
            target = root.targetMonitor;
        if (!target)
            return {
                "cropX": 0,
                "cropY": 0,
                "scaledWidth": Math.round(width),
                "scaledHeight": Math.round(height)
            };

        const scale = target.scale;
        const globalX = Math.round((x + target.lastIpcObject.x) * scale);
        const globalY = Math.round((y + target.lastIpcObject.y) * scale);
        return {
            "cropX": globalX - Math.round(minX * scale),
            "cropY": globalY - Math.round(minY * scale),
            "scaledWidth": Math.round(width * scale),
            "scaledHeight": Math.round(height * scale)
        };
    }

    function shellEscape(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    // ── Saving ──────────────────────────────────────────────────────
    property string tempPath: ""
    property string lastSavedPath: ""
    property string lastTimestamp: ""

    function saveScreenshot(x, y, width, height, screenName) {
        if (!root.tempPath)
            return;

        const crop = root.calculateCrop(x, y, width, height, screenName);
        const picturesBase = Quickshell.env("XDG_PICTURES_DIR") || (Quickshell.env("HOME") + "/Pictures");
        const picturesDir = picturesBase + "/Screenshots";
        const timestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
        const outputPath = `${picturesDir}/screenshot-${timestamp}.png`;

        root.lastTimestamp = timestamp;
        root.lastSavedPath = root.tempActive ? "" : outputPath;
        root.overlayVisible = false;

        const ePicturesDir = root.shellEscape(picturesDir);
        const eOutputPath = root.shellEscape(outputPath);
        const eTempPath = root.shellEscape(root.tempPath);
        // Temp shots live in /tmp rather than quickshell's cache dir; the main
        // instance is long-lived, so nothing would ever clean up cache files.
        const eTempSnip = root.shellEscape(`/tmp/hqs-snip-${timestamp}.png`);

        const mkdirCmd = `mkdir -p ${ePicturesDir}`;
        const cropCmd = `magick ${eTempPath} -crop ${crop.scaledWidth}x${crop.scaledHeight}+${crop.cropX}+${crop.cropY} +repage`;

        const sattyCommand = `${mkdirCmd} && ${cropCmd} png:- | satty --filename - --output-filename ${eOutputPath} --early-exit --init-tool brush && wl-copy --type image/png < ${eOutputPath}; rm -f ${eTempPath}`;
        const gradiaCommand = `${mkdirCmd} && ${cropCmd} ${eOutputPath} && hyprctl dispatch exec -- "gradia ${eOutputPath} || flatpak run be.alexandervanhee.gradia ${eOutputPath}"; sleep 0.5; rm -f ${eTempPath}`;
        const defaultSaveCommand = `${mkdirCmd} && ${cropCmd} ${eOutputPath} && wl-copy --type image/png < ${eOutputPath} && notify-send -a "HyprQuickFrame" -i ${eOutputPath} -h string:image-path:${eOutputPath} "Screenshot Saved" "Saved to ${picturesDir}"; rm -f ${eTempPath}`;
        // The copied image has to be read before the snip is unlinked.
        const defaultTempCommand = `${cropCmd} ${eTempSnip} && wl-copy --type image/png < ${eTempSnip} && notify-send -a "HyprQuickFrame" "Screenshot Copied" "Copied to clipboard"; rm -f ${eTempPath} ${eTempSnip}`;

        let cmd;
        if (root.editActive)
            cmd = root.annotationTool === "gradia" ? gradiaCommand : sattyCommand;
        else if (root.tempActive)
            cmd = defaultTempCommand;
        else
            cmd = defaultSaveCommand;

        screenshotProcess.command = ["sh", "-c", cmd];
        screenshotProcess.running = true;
    }

    // ── Configuration ───────────────────────────────────────────────
    // Mirrors the standalone theme. `satty` matches the value that actually
    // took effect before, where the theme was a bare object with no fields.
    property string annotationTool: "satty"
    readonly property string postSaveHook: ""

    function runPostSaveHook() {
        if (!root.postSaveHook || !root.lastSavedPath)
            return;
        const filePath = root.lastSavedPath;
        const fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
        const dirPath = filePath.substring(0, filePath.lastIndexOf('/'));
        let cmd = root.postSaveHook;
        cmd = cmd.replace(/%f/g, root.shellEscape(filePath));
        cmd = cmd.replace(/%n/g, root.shellEscape(fileName));
        cmd = cmd.replace(/%d/g, root.shellEscape(dirPath));
        cmd = cmd.replace(/%t/g, root.shellEscape(root.lastTimestamp));
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    // Freeze frame taken on activation. Screenshot before the overlay shows,
    // so the overlay is never part of its own capture.
    function beginCapture() {
        const timestamp = `${Date.now()}-${Math.floor(Math.random() * 100000)}`;
        root.tempPath = `/tmp/hqs-frame-${timestamp}.png`;
        captureProcess.command = ["grim", "-l", "0", root.tempPath];
        captureProcess.running = true;
    }

    function onCaptureFinished(code) {
        if (code !== 0 || !root.active) {
            root.teardown();
            return;
        }
        root.overlayVisible = true;
    }

    Process {
        id: captureProcess

        running: false
        onExited: code => root.onCaptureFinished(code)
    }

    Process {
        id: cleanupProcess

        running: false
    }

    // The overlay deliberately lives one interval behind the keyboard grab so
    // the user's pointer and keyboard are already routed at it when it appears.
    Timer {
        id: freezeTimer

        interval: 50
        repeat: false
        onTriggered: {
            if (root.active)
                root.beginCapture();
        }
    }

    Process {
        id: screenshotProcess

        running: false
        onExited: code => {
            if (code !== 0)
                console.error("Screenshot pipeline failed with exit code:", code);
            else
                root.runPostSaveHook();
            root.teardown();
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim())
                    console.log(this.text);
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim())
                    console.warn(this.text);
            }
        }
    }
}
