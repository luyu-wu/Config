import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import ".."

Item {
    id: thumbContainer

    Variables { id: v }

    property var hWin: null
    property var wHandle: null

    property real thumbW: -1
    property real thumbH: -1

    property var clientInfo: {}

    property real targetX: -1000
    property real targetY: -1000
    property real targetZ: 0

    readonly property real p: root.progress

    readonly property bool thumbReady: thumbLoader.item !== null
        && (thumbLoader.item as ScreencopyView).hasContent

    property bool reloading: false

    Timer {
        id: contentCheck
        interval: 5
        onTriggered: {
            if (!root.isActive || thumbContainer.thumbReady || !thumbContainer.wHandle)
                return;
            thumbContainer.reloading = true;
            Qt.callLater(function () { thumbContainer.reloading = false; });
        }
    }
    Connections {
        target: root
        function onIsActiveChanged() {
            if (root.isActive)
                contentCheck.restart();
        }
    }

    readonly property var wsCenter: (wHandle && isOnFocusedWorkspace()) ? workspaceToLocalCenter() : null
    readonly property bool hasWorkspaceRect: wsCenter !== null
    readonly property real wsW: Math.max(clientInfo && clientInfo.size ? clientInfo.size[0] : thumbW, 50)
    readonly property real wsH: Math.max(clientInfo && clientInfo.size ? clientInfo.size[1] : thumbH, 50)
    readonly property real wsX: hasWorkspaceRect ? wsCenter.x - wsW / 2 : targetX
    readonly property real wsY: hasWorkspaceRect ? wsCenter.y - wsH / 2 : targetY
    readonly property bool floating: !!(clientInfo && clientInfo.floating)

    function mix(from, to, t) {
        return from + (to - from) * t;
    }

    x: mix(wsX, targetX, p)
    y: mix(wsY, targetY, p)
    width: mix(hasWorkspaceRect ? wsW : thumbW, thumbW, p)
    height: mix(hasWorkspaceRect ? wsH : thumbH, thumbH, p)
    opacity: mix(hasWorkspaceRect ? 1 : 0, 1, p)
    z: {
        if (hasWorkspaceRect && floating)
            return 1001;
        if (targetZ >= 1000)
            return targetZ;
        return hasWorkspaceRect ? 2 : 0;
    }

    RectangularShadow {
        anchors.fill: card
        radius: 12
        color: Qt.rgba(0, 0, 0, 0.6)
        blur: 16
        spread: 0
        visible: thumbContainer.thumbReady
    }

    visible: !!wHandle

    function isOnFocusedWorkspace() {
        if (!hWin || !hWin.workspace)
            return false;
        if (root.specialActive && root.specialWorkspaceName)
            return hWin.workspace.name === root.specialWorkspaceName;
        var focused = Hyprland.focusedWorkspace;
        if (!focused)
            return false;
        return hWin.workspace.id === focused.id;
    }

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

    function activateWindow() {
        if (!hWin)
            return;
        root.toggleExpose();

        Hyprland.dispatch(
            'hl.dsp.focus({ window = "address:0x' + hWin.address + '"})'
        );
        Hyprland.dispatch(
             'hl.dsp.window.alter_zorder({ mode = "top" })');
    }

    Item {
        id: card
        anchors.fill: parent
        ClippingRectangle{
            anchors.fill: parent
            color: "transparent"
            radius: 12
            border.width: 1
            border.color: "#606060"
            visible: root.isActive && thumbContainer.wHandle

            MouseArea {
                anchors.fill: parent
                hoverEnabled: false
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                onClicked: event => {
                    exposeArea.currentIndex = index;
                    thumbContainer.activateWindow();
                }
            }

            Loader {
                id: thumbLoader
                anchors.fill: parent
                active: !!thumbContainer.wHandle && !thumbContainer.reloading
                asynchronous: true
                sourceComponent: ScreencopyView {
                    id: thumb
                    anchors.fill: parent
                    anchors.margins: 1
                    captureSource: thumbContainer.wHandle
                    live: root.isActive
                }
            }
        }
    }
}
