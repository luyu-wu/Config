pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    readonly property url source: "file:///home/chrysanthemum/.config/quickshell/wallpaper"

    PanelWindow {
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "#000000"
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "qs:wallpaper"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        Image {
            anchors.fill: parent
            source: root.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }
}
