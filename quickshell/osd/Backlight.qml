pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
    id: root

    // Backlight device under /sys/class/backlight.
    property string device: "amdgpu_bl1"

    readonly property string basePath: "/sys/class/backlight/" + root.device

    // Default step (swayosd's "raise"/"lower") and the finer step used by the
    // SHIFT + brightness binds.
    readonly property real step: 0.05
    readonly property real fineStep: 0.01

    property int current: 0
    property int maxBrightness: 0

    readonly property bool ready: root.maxBrightness > 0

    readonly property real percentage: root.ready ? root.current / root.maxBrightness : 0

    // Reads an integer from a sysfs file, returning -1 if it isn't readable
    // yet. Guards against parseInt("") producing NaN, which would silently
    // coerce to 0 and wipe out a valid value.
    function readInt(file) {
        const parsed = parseInt(file.text());
        return isNaN(parsed) ? -1 : parsed;
    }

    // Seed both mirrors from the synchronously-loaded files, so the real
    // brightness is known the moment the shell starts rather than waiting on
    // the first textChanged signal.
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
            // Already at this level: if the caller pushed past 0% / 100% there is
            // nothing to apply, so spring the pill to acknowledge the keypress.
            if (value > 1 || value < 0)
                Osd.bump(value > 1 ? 1 : -1);
            Osd.show("brightness");
            return;
        }
        root.current = raw;
        Osd.show("brightness");
        brightnessFile.setText(raw + "\n");
    }

    function increase(step) {
        root.set(root.percentage + (step !== undefined ? step : root.step));
    }

    function decrease(step) {
        root.set(root.percentage - (step !== undefined ? step : root.step));
    }

    // ── sysfs ───────────────────────────────────────────────────────
    FileView {
        id: brightnessFile
        path: root.basePath + "/brightness"
        atomicWrites: false
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
