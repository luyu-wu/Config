pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
    id: root

    readonly property string filePath: "/home/chrysanthemum/.config/quickshell/wallpaper"
    property int revision: 0
    readonly property url source: "file://" + root.filePath + "?v=" + root.revision

    IpcHandler {
        target: "wallpaper"

        function reload() {
            root.revision++;
        }
    }
}
