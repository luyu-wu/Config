import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.popups.logo

Item {
    id: root

    Layout.leftMargin: 12
    Layout.fillHeight: true
    implicitWidth: logoLabel.implicitWidth + 26  // 12px left pad + 14px right pad

    property bool hovered: false

    Rectangle {
        anchors.fill: parent
        color: logoMenu.visible ? "#1071db" : "transparent"
    }

    Text {
        id: logoLabel
        anchors.centerIn: parent
        text: ""
        font.family: "FiraCode Nerd Font"
        font.pixelSize: 30
        color: logoMenu.visible ? "#fff" : "#202020"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: logoMenu.visible = !logoMenu.visible
    }
    LogoMenu {
        id: logoMenu
        visible: false
    }
}
