pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    readonly property string imagePath: "/home/chrysanthemum/Pictures/Wallpapers/sky_reflection.png"
    readonly property url source: "file://" + imagePath

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

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
}
