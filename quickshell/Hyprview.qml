import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import "hyprview"
import "hyprview/layouts"

PanelWindow {
    id: root

    // --- SETTINGS ---
    property string layoutAlgorithm: "smartgrid"
    property string lastLayoutAlgorithm: ""
    property bool moveCursorToActiveWindow: false
    property bool liveCapture: false

    // --- INTERNAL STATE ---
    property bool isActive: false
    property bool closing: false
    property var closingWorkspace: null
    property bool visualActive: isActive && !closing
    property bool specialActive: false
    property string specialWorkspaceName: ""
    property bool animateWindows: false
    property var lastPositions: {}
    property string wallpaperPath: ""

    Process {
        id: wallpaperProc
        command: ["sh", "-c", "hyprctl hyprpaper listactive | awk -F': ' '{print $2}'"]

        stdout: SplitParser {
            onRead: data => {
                var path = data.trim();
                if (path) {
                    root.wallpaperPath = "file://" + path;
                }
            }
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    visible: isActive || closing

    // LayerShell Configs
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: (isActive && !closing) ? 1 : 0
    WlrLayershell.namespace: "quickshell:expose"

    // --- IPC & EVENTS ---
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
    }

    Connections {
        target: Hyprland
        function onRawEvent(ev) {
            if ((!root.isActive || root.closing) && ev.name !== "activespecial")
                return;
            switch (ev.name) {
            case "openwindow":
            case "closewindow":
            case "changefloatingmode":
            case "movewindow":
                Hyprland.refreshToplevels();
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

    function toggleExpose() {
        if (root.isActive && !root.closing) {
            // Closing: animate out
            root.closing = true;
            for (var i = 0; i < winRepeater.count; i++) {
                var item = winRepeater.itemAt(i);
                if (item && item.startCloseAnimation) {
                    item.startCloseAnimation();
                }
            }
            closeTimer.start();
        } else if (!root.isActive) {
            // Opening
            root.isActive = true;
            wallpaperProc.running = true;
            root.lastLayoutAlgorithm = root.layoutAlgorithm;
            exposeArea.currentIndex = -1;
            root.animateWindows = true;
            Hyprland.refreshToplevels();
        }
    }

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: {
            root.isActive = false;
            root.closing = false;
            root.closingWorkspace = null;
            root.animateWindows = false;
            root.lastPositions = {};
        }
    }

    // --- USER INTERFACE ---
    FocusScope {
        id: mainScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (!root.isActive || root.closing)
                return;
            if (event.key === Qt.Key_Escape) {
                root.toggleExpose();
                event.accepted = true;
                return;
            }

            const total = winRepeater.count;
            if (total <= 0)
                return;

            // Helper for horizontal navigation
            function moveSelectionHorizontal(delta) {
                var start = exposeArea.currentIndex;
                for (var step = 1; step <= total; ++step) {
                    var candidate = (start + delta * step + total) % total;
                    var it = winRepeater.itemAt(candidate);
                    if (it && it.visible) {
                        exposeArea.currentIndex = candidate;
                        return;
                    }
                }
            }

            // Helper for vertical navigation
            function moveSelectionVertical(dir) {
                var startIndex = exposeArea.currentIndex;
                var currentItem = winRepeater.itemAt(startIndex);

                if (!currentItem || !currentItem.visible) {
                    moveSelectionHorizontal(dir > 0 ? 1 : -1);
                    return;
                }

                var curCx = currentItem.x + currentItem.width / 2;
                var curCy = currentItem.y + currentItem.height / 2;

                var bestIndex = -1;
                var bestDy = 99999999;
                var bestDx = 99999999;

                for (var i = 0; i < total; ++i) {
                    var it = winRepeater.itemAt(i);
                    if (!it || !it.visible || i === startIndex)
                        continue;
                    var cx = it.x + it.width / 2;
                    var cy = it.y + it.height / 2;
                    var dy = cy - curCy;

                    // Direction filtering
                    if (dir > 0 && dy <= 0)
                        continue;
                    if (dir < 0 && dy >= 0)
                        continue;
                    var absDy = Math.abs(dy);
                    var absDx = Math.abs(cx - curCx);

                    // Search for nearest thumb (first in vertical, then horizontal distance)
                    if (absDy < bestDy || (absDy === bestDy && absDx < bestDx)) {
                        bestDy = absDy;
                        bestDx = absDx;
                        bestIndex = i;
                    }
                }

                if (bestIndex >= 0) {
                    exposeArea.currentIndex = bestIndex;
                }
            }

            if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                moveSelectionHorizontal(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) {
                moveSelectionHorizontal(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                moveSelectionVertical(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                moveSelectionVertical(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                var item = winRepeater.itemAt(exposeArea.currentIndex);
                if (item && item.activateWindow) {
                    item.activateWindow();
                    event.accepted = true;
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
            z: 0
            onClicked: {
                if (!root.closing) {
                    root.toggleExpose();
                }
            }
        }

        // Dim background
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 40
            z: -4
            bottomRightRadius: 16
            bottomLeftRadius: 16
            color: Qt.rgba(0.2, 0.2, 0.2)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 40
            height: 16
            z: 1
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.15)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.0)
                }
            }
        }

        Rectangle {
            id: bgRect
            anchors.fill: parent
            color: "transparent"

            property int targetMargins: 128
            property int targetRadius: 64

            anchors.margins: visualActive ? targetMargins : 0
            //opacity: visualActive ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on anchors.margins {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            RectangularShadow {
                id: bgShadow
                anchors.fill: parent
                anchors.topMargin: 40
                z: -2
                color: Qt.rgba(0, 0, 0, 0.3)

                radius: visualActive ? bgRect.targetRadius : 8
                blur: 30
                spread: 10
                opacity: visualActive ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on radius {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }

            ClippingRectangle {
                anchors.fill: parent
                color: "transparent"
                radius: visualActive ? bgRect.targetRadius : 8
                z: -1
                anchors.topMargin: 40
                Behavior on radius {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Image {
                    anchors.topMargin: -40

                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: root.wallpaperPath
                }
            }
        }

        Item {
            id: layoutContainer
            anchors.fill: parent
            anchors.margins: 32
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

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
                        property string algo: root.lastLayoutAlgorithm
                        property var rawToplevels: Hyprland.toplevels.values

                        values: {
                            // Bailout on wrong screen size
                            if (areaW <= 0 || areaH <= 0)
                                return [];

                            var windowList = [];
                            var idx = 0;

                            if (!rawToplevels)
                                return [];

                            for (var it of rawToplevels) {
                                var w = it;
                                var clientInfo = w && w.lastIpcObject ? w.lastIpcObject : {};
                                var workspace = clientInfo && clientInfo.workspace ? clientInfo.workspace : null;
                                var workspaceId = workspace && workspace.id !== undefined ? workspace.id : undefined;

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

                            // Sort by workspaceId, then originalIndex
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

                            return LayoutsManager.doLayout(algo, windowList, areaW, areaH);
                        }
                    }

                    Repeater {
                        id: winRepeater
                        model: windowLayoutModel

                        delegate: WindowThumbnail {
                            hWin: modelData.win
                            wHandle: hWin.wayland
                            winKey: String(hWin.address)
                            thumbW: modelData.width
                            thumbH: modelData.height
                            clientInfo: hWin.lastIpcObject

                            // Layout-generated coordinates
                            targetX: modelData.x
                            targetY: modelData.y
                            targetZ: (visible && (exposeArea.currentIndex === index)) ? 1000 : modelData.zIndex || 0
                            targetRotation: modelData.rotation || 0

                            hovered: visible && (exposeArea.currentIndex === index)
                            moveCursorToActiveWindow: root.moveCursorToActiveWindow
                        }
                    }
                }
            }
        }
    }
}
