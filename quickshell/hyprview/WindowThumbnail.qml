import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects

Item {
    id: thumbContainer

    property var hWin: null
    property var wHandle: null

    property string winKey: ''

    property real thumbW: -1
    property real thumbH: -1

    property var clientInfo: {}
    property bool hovered: false

    property real targetX: -1000
    property real targetY: -1000
    property real targetZ: 0
    property real targetRotation: 0

    property bool moveCursorToActiveWindow: false

    width: thumbW
    height: thumbH

    x: 0
    y: 0
    z: targetZ
    rotation: 0

    RectangularShadow {
        anchors.fill: card
        radius: 4
        color: Qt.rgba(0, 0, 0, 0.35)
        blur: 16
        spread: 0
        visible: true
    }

    visible: !!wHandle

    // If true, the thumbnail will animate from workspace position to layout position
    property bool animateIn: root.animateWindows

    function updateLastPos() {
        var lp = root.lastPositions || ({});
        var prev = lp[winKey] || ({});
        prev.x = x;
        prev.y = y;
        lp[winKey] = prev;
        root.lastPositions = lp;
    }

    onTargetXChanged: {
        if (!startAnim.running && !closeAnim.running) {
            x = targetX;
        }
        updateLastPos();
    }

    onTargetYChanged: {
        if (!startAnim.running && !closeAnim.running) {
            y = targetY;
        }
        updateLastPos();
    }

    onTargetRotationChanged: {
        rotation = targetRotation;
    }

    onXChanged: updateLastPos()
    onYChanged: updateLastPos()

    // Open animation: from workspace position/size to layout position/size
    ParallelAnimation {
        id: startAnim
        PropertyAnimation {
            target: thumbContainer
            property: "x"
            to: targetX
            duration: 400
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            target: thumbContainer
            property: "y"
            to: targetY
            duration: 400
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            target: thumbContainer
            property: "width"
            to: thumbW
            duration: 400
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            target: thumbContainer
            property: "height"
            to: thumbH
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    // Close animation: focused workspace windows animate back to workspace position
    ParallelAnimation {
        id: closeAnim
        PropertyAnimation {
            id: closeAnimX
            target: thumbContainer
            property: "x"
            duration: 400
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            id: closeAnimY
            target: thumbContainer
            property: "y"
            duration: 400
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            id: closeAnimW
            target: thumbContainer
            property: "width"
            duration: 400
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            id: closeAnimH
            target: thumbContainer
            property: "height"
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    function isOnFocusedWorkspace() {
        if (!hWin || !hWin.workspace)
            return false;
        // When a special workspace is active, match its windows by name
        if (root.specialActive && root.specialWorkspaceName)
            return hWin.workspace.name === root.specialWorkspaceName;
        var focused = Hyprland.focusedWorkspace;
        if (!focused)
            return false;
        return hWin.workspace.id === focused.id;
    }

    // Used for close animation: respects explicit closingWorkspace, falls back accordingly
    function isOnClosingWorkspace() {
        if (!hWin || !hWin.workspace)
            return false;
        var cw = root.closingWorkspace;
        if (cw) {
            // Explicit target: if it's a special workspace, match by name
            if (cw.id < 0)
                return hWin.workspace.name === cw.name;
            return hWin.workspace.id === cw.id;
        }
        // No explicit target: use current state
        if (root.specialActive && root.specialWorkspaceName)
            return hWin.workspace.name === root.specialWorkspaceName;
        var focused = Hyprland.focusedWorkspace;
        if (!focused)
            return false;
        return hWin.workspace.id === focused.id;
    }

    // Map the window's screen-space center to exposeArea-local coords
    function workspaceToLocalCenter() {
        if (!clientInfo || !clientInfo.at || clientInfo.at[0] <= -1000) {
            return null;
        }
        var parentItem = thumbContainer.parent;
        if (!parentItem) {
            return null;
        }
        var screenCX = (clientInfo.at[0] || 0) + (clientInfo.size[0] || 0) / 2;
        var screenCY = (clientInfo.at[1] || 0) + (clientInfo.size[1] || 0) / 2;
        return parentItem.mapFromItem(null, screenCX, screenCY);
    }

    // Fade-in for windows not on the focused workspace (open)
    PropertyAnimation {
        id: fadeInAnim
        target: thumbContainer
        property: "opacity"
        from: 0
        to: 1
        duration: 400
        easing.type: Easing.OutCubic
    }

    // Fade-out for off-workspace windows (close)
    PropertyAnimation {
        id: fadeOutAnim
        target: thumbContainer
        property: "opacity"
        to: 0
        duration: 400
        easing.type: Easing.OutCubic
    }

    // Called by Hyprview when expose is closing. Triggers reverse animations.
    function startCloseAnimation() {
        startAnim.stop();
        fadeInAnim.stop();
        if (isOnClosingWorkspace()) {
            var wsW = Math.max(clientInfo && clientInfo.size ? clientInfo.size[0] : thumbW, 50);
            var wsH = Math.max(clientInfo && clientInfo.size ? clientInfo.size[1] : thumbH, 50);
            var localCenter = workspaceToLocalCenter();
            if (localCenter) {
                closeAnimX.to = localCenter.x - wsW / 2;
                closeAnimY.to = localCenter.y - wsH / 2;
                closeAnimW.to = wsW;
                closeAnimH.to = wsH;
                closeAnim.start();
            } else {
                fadeOutAnim.start();
            }
        } else {
            fadeOutAnim.start();
        }
    }

    Component.onCompleted: {
        rotation = targetRotation;

        if (root.animateWindows && root.isActive && !!wHandle) {
            var onFocused = isOnFocusedWorkspace();
            if (onFocused) {
                var wsW = Math.max(clientInfo && clientInfo.size ? clientInfo.size[0] : thumbW, 50);
                var wsH = Math.max(clientInfo && clientInfo.size ? clientInfo.size[1] : thumbH, 50);
                var localCenter = workspaceToLocalCenter();
                if (localCenter) {
                    // Start at actual workspace size (unclamped — exposeArea has clip:false)
                    width = wsW;
                    height = wsH;
                    // Center on the window's screen position
                    x = localCenter.x - wsW / 2;
                    y = localCenter.y - wsH / 2;
                    startAnim.restart();
                } else {
                    x = targetX;
                    y = targetY;
                }
            } else {
                // Not on focused workspace: snap to final position, fade in
                x = targetX;
                y = targetY;
                opacity = 0;
                fadeInAnim.start();
            }
        } else {
            x = targetX;
            y = targetY;
        }
        updateLastPos();
    }

    function activateWindow() {
        if (!hWin)
            return;
        var targetIsSpecial = (hWin?.workspace ?? 0) < 0 || (hWin?.workspace?.name ?? "").startsWith("special");

        if (root.specialActive && !targetIsSpecial) {
            Hyprland.dispatch("togglespecialworkspace");
        }

        if (hWin.workspace) {
            root.closingWorkspace = hWin.workspace;
            hWin.workspace.activate();
        }

        root.toggleExpose();
        Hyprland.dispatch("focuswindow address:0x" + hWin.address);
        Hyprland.dispatch("alterzorder top");
        if (thumbContainer.moveCursorToActiveWindow) {
            var cx = clientInfo.at[0] + (clientInfo.size[0] / 2);
            var cy = clientInfo.at[1] + (clientInfo.size[1] / 2);
            Hyprland.dispatch("movecursor " + cx + " " + cy);
        }
    }

    Item {
        id: card
        anchors.fill: parent

        scale: 1
        transformOrigin: Item.Center

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            onEntered: {
                exposeArea.currentIndex = index;
            }
            onClicked: event => {
                exposeArea.currentIndex = index;

                thumbContainer.activateWindow();
            }
            onExited: {
                if (exposeArea.currentIndex === index) {
                    exposeArea.currentIndex = -1;
                }
            }
        }

        Loader {
            id: thumbLoader
            anchors.fill: parent
            active: root.isActive && !!thumbContainer.wHandle
            Rectangle{
                anchors.fill: parent
                color: "#333333"
                radius: 12
            }
            sourceComponent: ScreencopyView {
                id: thumb
                anchors.fill: parent
                captureSource: thumbContainer.wHandle
                live: root.isActive
                paintCursor: false
                visible: root.isActive && thumbContainer.wHandle && hasContent

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: thumb.width
                        height: thumb.height
                        radius: 12
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: thumbContainer.hovered ? 4 : 1
                    border.color: thumbContainer.hovered ? "#1071db" : "#444"
                    radius: 12
                }
            }
        }

        Rectangle {
            id: badge
            z: 100
            width: Math.min(titleText.implicitWidth + 24, thumbContainer.thumbW * 0.75)
            height: titleText.implicitHeight + 12

            x: (card.width - width) / 2
            y: card.height - height - (card.height * 0.08)

            radius: 4
            color: thumbContainer.hovered ? "#1071db" : "#e4e7ef"

            Text {
                id: titleText
                anchors.centerIn: parent
                width: parent.width - 16
                text: hWin.title
                color: thumbContainer.hovered ? "#fff" : "#222"
                font.pixelSize: 12
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
