pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string device: "amdgpu_bl1"

    readonly property string basePath: "/sys/class/backlight/" + root.device
    readonly property real step: 0.05
    readonly property real fineStep: 0.01

    property int current: 0
    property int maxBrightness: 0

    readonly property bool ready: root.maxBrightness > 0

    readonly property real percentage: root.ready ? root.current / root.maxBrightness : 0

    function readInt(file) {
        const parsed = parseInt(file.text());
        return isNaN(parsed) ? -1 : parsed;
    }

    Component.onCompleted: {
        root.current = root.readInt(brightnessFile);
        root.maxBrightness = root.readInt(maxBrightnessFile);
    }

    function set(value) {
        const clamped = Math.max(0, Math.min(1, value));
        if (!root.ready) {
            Osd.show("brightness");
            return;
        }
        const raw = Math.round(clamped * root.maxBrightness);
        if (raw === root.current) {
            if (value > 1 || value < 0)
                Osd.bump(value > 1 ? 1 : -1);
            Osd.show("brightness");
            return;
        }
        root.current = raw;
        root.requestWrite(raw);
        Osd.show("brightness");
    }

    function increase(step) {
        root.set(root.percentage + (step !== undefined ? step : root.step));
    }

    function decrease(step) {
        root.set(root.percentage - (step !== undefined ? step : root.step));
    }
    property int pendingWrite: -1

    function requestWrite(raw) {
        root.pendingWrite = raw;
        if (!writeProcess.running)
            root.runWrite();
    }

    function runWrite() {
        if (root.pendingWrite < 0)
            return;
        const value = root.pendingWrite;
        root.pendingWrite = -1;
        writeProcess.command = ["brightnessctl", "--device=" + root.device, "set", value.toString()];
        writeProcess.running = true;
    }

    Process {
        id: writeProcess
        onExited: exitCode => {
            if (exitCode !== 0)
                console.warn("Backlight: brightnessctl exited with code " + exitCode + "; brightness unchanged");
            root.runWrite();
        }
    }
    FileView {
        id: brightnessFile
        path: root.basePath + "/brightness"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onTextChanged: {
            const value = root.readInt(brightnessFile);
            if (value >= 0)
                root.current = value;
        }
    }

    FileView {
        id: maxBrightnessFile
        path: root.basePath + "/max_brightness"
        blockLoading: true
        onTextChanged: {
            const value = root.readInt(maxBrightnessFile);
            if (value >= 0)
                root.maxBrightness = value;
        }
    }
}
