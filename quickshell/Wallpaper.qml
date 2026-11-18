pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.share.app

Item {
    id: root

    readonly property url source: WallpaperState.source

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wallpaper

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
                autoTransform: true
                cache: false
                sourceSize.width: wallpaper.modelData.width
                sourceSize.height: wallpaper.modelData.height
            }
        }
    }
}
