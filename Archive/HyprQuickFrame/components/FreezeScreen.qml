import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property var targetScreen: Quickshell.screens[0]
    property bool grabKeyboard: false
    property bool isReady: false

    property alias contentItem: root.contentItem

    screen: targetScreen
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs:screenshot"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    color: "transparent"
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    ScreencopyView {
        captureSource: root.targetScreen
        anchors.fill: parent
        z: -1
    }
    Timer {
        interval: 100
        running: true
        onTriggered: {
            root.isReady = true;
        }
    }
}
