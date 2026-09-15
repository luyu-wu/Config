import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "components"

Scope {
    id: root

    property var hyprlandMonitor: Hyprland.focusedMonitor
    property string activeScreenName: hyprlandMonitor ? hyprlandMonitor.name : (Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "")
    property string tempPath: ""
    property string mode: ["region"].indexOf(Quickshell.env("HQF_MODE")) !== -1 ? Quickshell.env("HQF_MODE") : "region"
    property var modes: ["edit", "region", "temp"]
    property bool tempActive: Quickshell.env("HQF_ACTION") === "temp"
    property bool editActive: Quickshell.env("HQF_ACTION") === "edit"
    property string lastSavedPath: ""
    property string lastTimestamp: ""
    property bool overlayVisible: false
    readonly property real targetMenuWidth: (modes.length - (editActive ? 1 : 0) - (tempActive ? 1 : 0)) * 100 + 8
    property var theme: themeObj

    function shellEscape(s) {
        return "'" + s.replace(/'/g, "'\\''") + "'";
    }

    function calculateCrop(x, y, width, height, screenName) {
        let minX = Infinity;
        let minY = Infinity;
        let targetMonitor = null;
        const monitors = Hyprland.monitors.values;
        for (const m of monitors) {
            minX = Math.min(minX, m.lastIpcObject.x);
            minY = Math.min(minY, m.lastIpcObject.y);
            if (m.name === screenName)
                targetMonitor = m;
        }
        if (!targetMonitor)
            targetMonitor = hyprlandMonitor;

        const scale = targetMonitor.scale;
        const monitorX = targetMonitor.lastIpcObject.x;
        const monitorY = targetMonitor.lastIpcObject.y;
        const globalX = Math.round((x + monitorX) * scale);
        const globalY = Math.round((y + monitorY) * scale);
        return {
            "cropX": globalX - Math.round(minX * scale),
            "cropY": globalY - Math.round(minY * scale),
            "scaledWidth": Math.round(width * scale),
            "scaledHeight": Math.round(height * scale)
        };
    }

    function cleanup() {
        Quickshell.execDetached(["rm", "-f", tempPath]);
    }

    function runPostSaveHook() {
        const hook = theme.postSaveHook;
        if (!hook || !root.lastSavedPath)
            return;

        const filePath = root.lastSavedPath;
        const fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
        const dirPath = filePath.substring(0, filePath.lastIndexOf('/'));
        let cmd = hook;
        cmd = cmd.replace(/%f/g, shellEscape(filePath));
        cmd = cmd.replace(/%n/g, shellEscape(fileName));
        cmd = cmd.replace(/%d/g, shellEscape(dirPath));
        cmd = cmd.replace(/%t/g, shellEscape(root.lastTimestamp));
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    function saveScreenshot(x, y, width, height, screenName) {
        const crop = calculateCrop(x, y, width, height, screenName);
        const picturesBase = Quickshell.env("XDG_PICTURES_DIR") || (Quickshell.env("HOME") + "/Pictures");
        const picturesDir = picturesBase + "/Screenshots";
        const now = new Date();
        const timestamp = Qt.formatDateTime(now, "yyyy-MM-dd_hh-mm-ss");
        const outputPath = `${picturesDir}/screenshot-${timestamp}.png`;
        root.lastTimestamp = timestamp;
        root.lastSavedPath = root.tempActive ? "" : outputPath;
        const tempSnip = Quickshell.cachePath(`snip-${timestamp}.png`);
        const ePicturesDir = shellEscape(picturesDir);
        const eOutputPath = shellEscape(outputPath);
        const eTempPath = shellEscape(tempPath);
        const eTempSnip = shellEscape(tempSnip);
        const maybeShare = escapedPath => {
            return "";
        };
        const shareTag = "";
        const mkdirCmd = `mkdir -p ${ePicturesDir}`;
        const cropCmd = `magick ${eTempPath} -crop ` + `${crop.scaledWidth}x${crop.scaledHeight}` + `+${crop.cropX}+${crop.cropY} +repage`;
        const sattyCommand = `${mkdirCmd} && ${cropCmd} png:- ` + `| satty --filename - ` + `--output-filename ${eOutputPath} --early-exit --init-tool brush ` + `&& wl-copy --type image/png < ${eOutputPath}` + `${maybeShare(eOutputPath)}; rm -f ${eTempPath}`;
        const gradiaCommand = `${mkdirCmd} && ${cropCmd} ${eOutputPath} && hyprctl dispatch exec -- "gradia ${eOutputPath} || flatpak run be.alexandervanhee.gradia ${eOutputPath}"; sleep 0.5; rm -f ${eTempPath}`;
        const defaultSaveCommand = `${mkdirCmd} && ${cropCmd} ${eOutputPath} ` + `&& wl-copy --type image/png < ${eOutputPath}` + `${maybeShare(eOutputPath)} ` + `&& notify-send -a "HyprQuickFrame" -i ${eOutputPath} ` + `-h string:image-path:${eOutputPath} "Screenshot Saved" ` + `"Saved to ${picturesDir}"; rm -f ${eTempPath}`;
        const defaultTempCommand = `${cropCmd} ${eTempSnip} ` + `&& wl-copy --type image/png < ${eTempSnip}` + `${maybeShare(eTempSnip)} ` + `&& notify-send -a "HyprQuickFrame" "Screenshot Copied" ` + `"Copied to clipboard${shareTag}"; ` + `rm -f ${eTempPath} ${eTempSnip}`;
        let cmd;
        console.log("Evaluated annotationTool value:", theme.annotationTool);
        if (root.editActive)
            cmd = theme.annotationTool === "gradia" ? gradiaCommand : sattyCommand;
        else if (root.tempActive)
            cmd = defaultTempCommand;
        else
            cmd = defaultSaveCommand;
        screenshotProcess.command = ["sh", "-c", cmd];
        screenshotProcess.running = true;
        root.overlayVisible = false;
    }

    Component.onCompleted: {
        const timestamp = Date.now();
        const rand = Math.floor(Math.random() * 100000);
        const path = Quickshell.cachePath(`screenshot-${timestamp}-${rand}.png`);
        tempPath = path;
        captureProcess.command = ["grim", "-l", "0", path];
        captureProcess.running = true;
    }

    Process {
        id: captureProcess

        running: false
        onExited: code => {
            if (code === 0) {
                showTimer.start();
            } else {
                cleanup();
                Qt.quit();
            }
        }
    }

    Theme {
        id: themeObj
    }

    Timer {
        id: showTimer

        interval: 50
        running: false
        repeat: false
        onTriggered: root.overlayVisible = true
    }

    Process {
        id: screenshotProcess

        running: false
        onExited: code => {
            if (code !== 0)
                console.error("Screenshot pipeline failed with exit code:", code);
            else
                root.runPostSaveHook();
            Qt.quit();
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

    Variants {
        model: Quickshell.screens

        FreezeScreen {
            id: overlay

            required property var modelData
            property bool isFocused: modelData.name === root.activeScreenName
            isReady: false
            property var themeRef: root.theme
            property var hyprMonitor: {
                const monitors = Hyprland.monitors.values;
                for (const m of monitors) {
                    if (m.name === modelData.name)
                        return m;
                }
                return null;
            }

            targetScreen: modelData
            visible: root.overlayVisible
            onVisibleChanged: {
                if (visible && isFocused)
                    cursorPosProcess.running = true;
            }

            Process {
                id: cursorPosProcess

                command: ["hyprctl", "cursorpos", "-j"]
                running: false

                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            const pos = JSON.parse(this.text.trim());
                            const monitorPos = Qt.point(pos.x - modelData.x, pos.y - modelData.y);
                            regionSelector.mouseX = monitorPos.x;
                            regionSelector.mouseY = monitorPos.y;
                        } catch (e) {
                            console.warn("Failed to parse cursorpos:", e);
                        }
                    }
                }
            }

            Shortcut {
                sequences: ["Escape", "q"]
                onActivated: {
                    root.cleanup();
                    Qt.quit();
                }
            }

            Shortcut {
                sequence: "r"
                onActivated: root.mode = "region"
            }

            Shortcut {
                sequence: "s"
                onActivated: {
                    let targetMon = overlay.modelData;
                    if (root.activeScreenName && root.activeScreenName !== targetMon.name) {
                        const screens = Quickshell.screens;
                        for (let i = 0; i < screens.length; i++) {
                            if (screens[i].name === root.activeScreenName) {
                                targetMon = screens[i];
                                break;
                            }
                        }
                    }
                    root.saveScreenshot(0, 0, targetMon.width, targetMon.height, targetMon.name);
                }
            }

            Shortcut {
                sequence: "e"
                onActivated: {
                    root.editActive = !root.editActive;
                    if (root.editActive)
                        root.tempActive = false;
                }
            }

            Shortcut {
                sequence: "t"
                onActivated: {
                    root.tempActive = !root.tempActive;
                    if (root.tempActive)
                        root.editActive = false;
                }
            }

            RegionSelector {
                id: regionSelector
                visible: root.mode === "region" && overlay.isReady
                anchors.fill: parent
                dimOpacity: overlay.themeRef.dimOpacity
                borderRadius: overlay.themeRef.borderRadius
                outlineThickness: overlay.themeRef.outlineThickness
                globalAnimations: overlay.themeRef.animations
                onRegionSelected: (x, y, width, height) => {
                    root.saveScreenshot(x, y, width, height, overlay.modelData.name);
                }
            }

            ControlBar {
                id: segmentedControl

                visible: overlay.isFocused && overlay.isReady
                modes: root.modes
                mode: root.mode
                tempActive: root.tempActive
                editActive: root.editActive
                theme: overlay.themeRef
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: overlay.themeRef ? overlay.themeRef.bottomMargin : 60
                onModeSelected: m => {
                    return root.mode = m;
                }
                onTempToggled: {
                    root.tempActive = true;
                    root.editActive = false;
                }
                onEditToggled: {
                    root.editActive = true;
                    root.tempActive = false;
                }
            }

            QuickToggle {
                id: editToggleButton

                visible: overlay.isFocused
                active: root.editActive
                icon: "" // "󰏫"
                imageSource: Qt.resolvedUrl("assets/icons/edit.svg")
                iconColor: overlay.themeRef.toggleEdit
                backgroundColor: overlay.themeRef.toggleBackground
                shadowColor: overlay.themeRef.toggleShadow
                borderColor: overlay.themeRef.barBorder
                borderWidth: 1
                targetX: (overlay.width - root.targetMenuWidth) / 2 - 15 - width
                targetY: segmentedControl.y + segmentedControl.height / 2
                sourceX: overlay.width / 2 - 204 + 32
                onClicked: root.editActive = false
            }

            QuickToggle {
                id: tempToggleButton

                visible: overlay.isFocused
                active: root.tempActive
                icon: "" // "󰏫"
                imageSource: Qt.resolvedUrl("assets/icons/temp.svg")
                iconColor: overlay.themeRef.toggleTemp
                backgroundColor: overlay.themeRef.toggleBackground
                shadowColor: overlay.themeRef.toggleShadow
                borderColor: overlay.themeRef.barBorder
                borderWidth: 1
                targetX: (overlay.width + root.targetMenuWidth) / 2 + 15
                targetY: segmentedControl.y + segmentedControl.height / 2
                sourceX: overlay.width / 2 - 204 + 332
                onClicked: root.tempActive = false
            }
        }
    }
}
