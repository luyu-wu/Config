import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.share.corners

Scope {
    id: root
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panelWindow
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs:screencorners"
            required property var modelData
            property int radius: 8
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            exclusiveZone: -1
            mask: Region {}
            color: "transparent"

            ScreenCornersVisible {}
        }
    }
}
