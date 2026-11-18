import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.share.app
import "hyprview"

PanelWindow {
    id: root
    Variables { id: v }

    readonly property url wallpaperSource: WallpaperState.source

    // 0..1 scalar: 0 = collapsed onto the
    // desktop, 1 = fully expanded
    property real progress: 0

    readonly property bool isActive: progress > 0 || gestureActive

    property bool specialActive: false
    property string specialWorkspaceName: ""
    property bool refreshingToplevels: false

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    implicitWidth: screen ? screen.width : 0
    implicitHeight: screen ? screen.height : 0

    color: "transparent"
    visible: isActive

    // LayerShell Configs
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs:expose"

    IpcHandler {
        target: "expose"
        function toggle() {
            root.toggleExpose();
        }

        function open() {
            if (root.isActive)
                return;
            root.toggleExpose();
        }

        function close() {
            if (!root.isActive)
                return;
            root.toggleExpose();
        }

        // Scrub the overlay from the command line, 0..100. Used to evaluate
        // follow-finger rendering without a gesture source:
        //   quickshell ipc -p ~/.config/quickshell call expose progress 50
        function progress(percent: int): void {
            root.setProgress(percent / 100, 0);
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(ev) {
            if (!root.isActive && ev.name !== "activespecial"
                    && ev.name !== "openwindow" && ev.name !== "closewindow")
                return;
            switch (ev.name) {
            case "openwindow":
            case "closewindow":
            case "changefloatingmode":
            case "movewindow":
                root.requestToplevelsRefresh();
                return;
            case "activespecial":
                var dataStr = String(ev.data);
                var namePart = dataStr.split(",")[0];
                root.specialActive = (namePart.length > 0);
                root.specialWorkspaceName = root.specialActive ? namePart : "";
                return;
            default:
                return;
            }
        }
    }

    onRefreshingToplevelsChanged: {
        if (!refreshingToplevels)
            windowLayoutModel.requestRefresh();
    }

    // Gesture bridge. hypr/binds.lua writes into this shm
    // file: <travel> is the absolute fraction of a full reveal
    // velocity (reveals per second) used for the flick projection.
    FileView {
        id: gestureFile
        path: "/dev/shm/qs-expose"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onTextChanged: {
            // The blocking initial load reports whatever the last gesture left
            // behind; never act on it, only on samples written after startup.
            if (!root.gesturePrimed) {
                root.gesturePrimed = true;
                return;
            }
            root.applyGestureSample(gestureFile.text());
        }
    }


    property bool gestureActive: false
    property bool gesturePrimed: false
    property real gestureBase: 0

    function applyGestureSample(text) {
        var parts = String(text).trim().split(/\s+/);
        if (parts.length < 2)
            return;
        var value = parseFloat(parts[1]);
        if (isNaN(value))
            return;

        if (parts[0] !== "1") {
            // Release: the value is the velocity the finger left with.
            root.finishGesture(value);
            return;
        }

        if (!root.gestureActive) {
            // Wake the surface before the first sample lands, so the layer
            // exists while the finger is still moving.
            root.gestureActive = true;
            root.gestureBase = root.progress;
            root.beginReveal();
            if (root.progress <= 0)
                root.progress = 0.0001;
        }
        root.setProgress(root.gestureBase + value, 0);
    }

    function finishGesture(velocity) {
        if (!root.gestureActive)
            return;
        root.gestureActive = false;

        var projected = root.progress + velocity * 0.18;
        var target = projected >= 0.5 ? 1 : 0;

        if (target === 0 && root.progress <= 0)
            root.endReveal();

        var speed = Math.abs(velocity);
        var distance = Math.abs(target - root.progress);
        root.setProgress(target, Math.max(120, Math.min(320, distance / speed * 1000)));
    }

    function requestToplevelsRefresh() {
        root.refreshingToplevels = true;
        Hyprland.refreshToplevels();
    }

    function setProgress(value, duration) {
        var v = Math.max(0, Math.min(1, value));
        if (v > 0 && root.progress <= 0)
            root.beginReveal();
        if (duration > 0) {
            progressAnim.stop();
            progressAnim.duration = duration;
            progressAnim.to = v;
            progressAnim.start();
        } else {
            progressAnim.stop();
            root.progress = v;
        }
    }

    function toggleExpose() {
        root.setProgress(root.progress > 0 ? 0 : 1, 400);
    }

    function beginReveal() {
        exposeArea.currentIndex = -1;
        root.requestToplevelsRefresh();
    }

    function endReveal() {
        exposeArea.currentIndex = -1;
    }

    onProgressChanged: {
        if (!root.isActive)
            root.endReveal();
    }

    NumberAnimation {
        id: progressAnim
        target: root
        property: "progress"
        duration: 250
        easing.type: Easing.OutCubic
    }

    Item {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
            z: 0
            onClicked: root.toggleExpose()
        }

        // Backdrop
        Rectangle {
            anchors.fill: parent
            z: -4
            bottomRightRadius: 16
            bottomLeftRadius: 16
            color: v.darkMode ? "#333" : "#808080"
        }

        Rectangle {
            id: bgRect
            anchors.fill: parent
            color: "transparent"

            property int targetMargins: 128
            property int targetRadius: 48

            anchors.margins: targetMargins * root.progress

            RectangularShadow {
                id: bgShadow
                anchors.fill: parent
                z: -2
                color: Qt.rgba(0, 0, 0, 0.3)

                radius: bgRect.targetRadius
                blur: 30
                spread: 10
            }

            ClippingRectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 8 + (bgRect.targetRadius - 8) * root.progress
                z: -1

                Image {
                    id: wallpaperImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: root.wallpaperSource

                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 8 + (bgRect.targetRadius - 8) * root.progress
                color: "black"
                visible: opacity > 0.001
                opacity: root.specialActive ? 0.3 * (1 - root.progress) : 0
            }
        }

        Item {
            id: layoutContainer
            anchors.fill: parent
            anchors.margins: 32

            Column {
                id: layoutRoot
                anchors.fill: parent
                anchors.margins: 48
                anchors.topMargin: 96
                spacing: 20

                Item {
                    id: exposeArea
                    width: layoutRoot.width
                    height: layoutRoot.height - layoutRoot.spacing

                    property int currentIndex: 0

                    ScriptModel {
                        id: windowLayoutModel

                        property int areaW: exposeArea.width
                        property int areaH: exposeArea.height

                        property int lastAreaW: 0
                        property int lastAreaH: 0

                        onAreaWChanged: {
                            if (areaW > 0)
                                lastAreaW = areaW;
                        }

                        onAreaHChanged: {
                            if (areaH > 0)
                                lastAreaH = areaH;
                        }

                        property var rawToplevels: []
                        property int topRev: 0

                        function invalidateCache() {
                            if (rawToplevels === Hyprland.toplevels.values)
                                return;
                            rawToplevels = Hyprland.toplevels.values;
                        }

                        function requestRefresh() {
                            invalidateCache();
                            topRev += 1;
                        }

                        values: {
                            // Recompute the layout only when something that can change
                            // its result actually changes.
                            topRev;
                            invalidateCache();

                            // Bailout on wrong screen size
                            var layoutW = areaW > 0 ? areaW : lastAreaW;
                            var layoutH = areaH > 0 ? areaH : lastAreaH;
                            if (layoutW <= 0 || layoutH <= 0)
                                return [];

                            var SPECIAL_WORKSPACE_SORT_OFFSET = 10000;

                            var windowList = [];
                            var idx = 0;

                            if (!rawToplevels)
                                return [];

                            for (var it of rawToplevels) {
                                var w = it;
                                var clientInfo = w && w.lastIpcObject ? w.lastIpcObject : {};
                                var workspace = clientInfo && clientInfo.workspace ? clientInfo.workspace : null;

                                var workspaceId = workspace ? workspace.id : undefined;
                                if (workspaceId === undefined || workspaceId === null)
                                    workspaceId = workspace && workspace.name ? SPECIAL_WORKSPACE_SORT_OFFSET : undefined;

                                // Filter invalid workspace or offscreen windows
                                if (workspaceId === undefined || workspaceId === null)
                                    continue;
                                var size = clientInfo && clientInfo.size ? clientInfo.size : [0, 0];
                                var at = clientInfo && clientInfo.at ? clientInfo.at : [-1000, -1000];
                                if (at[1] + size[1] <= 0)
                                    continue;

                                windowList.push({
                                    win: w,
                                    clientInfo: clientInfo,
                                    workspaceId: workspaceId,
                                    width: size[0],
                                    height: size[1],
                                    originalIndex: idx++,
                                    lastIpcObject: w.lastIpcObject
                                });
                            }

                            windowList.sort(function (a, b) {
                                if (a.workspaceId < b.workspaceId)
                                    return -1;
                                if (a.workspaceId > b.workspaceId)
                                    return 1;
                                if (a.originalIndex < b.originalIndex)
                                    return -1;
                                if (a.originalIndex > b.originalIndex)
                                    return 1;
                                return 0;
                            });

                            return LayoutsManager.doLayout(windowList, layoutW, layoutH);
                        }
                    }

                    Repeater {
                        id: winRepeater
                        model: windowLayoutModel

                        delegate: WindowThumbnail {
                            hWin: modelData.win
                            wHandle: hWin.wayland
                            thumbW: modelData.width
                            thumbH: modelData.height
                            clientInfo: hWin.lastIpcObject

                            targetX: modelData.x
                            targetY: modelData.y
                            targetZ: (visible && (exposeArea.currentIndex === index)) ? 1000 : 0
                        }
                    }
                }
            }
        }
    }
}
