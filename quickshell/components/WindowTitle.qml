import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.share.app

Item {
    id: root

    Layout.leftMargin: 0
    Layout.rightMargin: 4
    Layout.fillHeight: true
    implicitWidth: titleLabel.implicitWidth + 24  // 12px each side

    readonly property string displayName: HyprlandExt.applicationName != "" ? HyprlandExt.applicationName : "Finder"

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Text {
        id: titleLabel
        anchors.centerIn: parent
        text: root.displayName
        font.pixelSize: 22
        font.family: "SF Pro"
        font.capitalization: Font.Capitalize
        font.weight: 600
        renderType: Text.NativeRendering
    }

    MouseArea {
        anchors.fill: parent
    }
}
