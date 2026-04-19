import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Networking

import qs.share.menu

PopupWindow {
    id: root

    width: 340
    height: menuColumn.implicitHeight + 8
    grabFocus: true

    anchor {
        item: networkWidget
        edges: Edges.Bottom
        rect.y: 38
        rect.x: 16 - networkWidget.width / 2
    }
    color: "transparent"
    //Networking {
    //    id: networking
    //}

    Item {
        id: mask
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Rectangle {
            anchors.fill: parent
            anchors.margins: 8
            anchors.topMargin: 0
            radius: 8
            color: "#fff"
        }
    }
    RectangularShadow {
        id: outerShadow
        anchors.fill: parent
        radius: dropdown.radius
        blur: 10
        color: Qt.rgba(0, 0, 0, 0.35)
        spread: -8
        visible: false
    }
    MultiEffect {
        anchors.fill: outerShadow
        source: outerShadow
        maskSource: mask
        maskEnabled: true
        maskInverted: true
    }

    Rectangle {
        id: dropdown
        anchors.fill: parent
        anchors.margins: 8
        anchors.topMargin: 0

        radius: 8
        color: "#b1e4e7ef"
        border.color: "#A0A0A0"
        border.width: 1
    }

    // ── menu contents ────────────────────────────────────────────────────────
    ColumnLayout {
        id: menuColumn
        anchors {
            top: dropdown.top
            left: dropdown.left
            right: dropdown.right
            topMargin: 4
            bottomMargin: 4
            leftMargin: 0
            rightMargin: 0
        }
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            height: 10
            color: "transparent"
        }
        MenuLabel {
            label: "Wi-Fi"
            labelElement.font.weight: 600
        }
        Rectangle {
            Layout.fillWidth: true
            height: 6
            color: "transparent"
        }
        MenuDiv {}
        MenuLabel {
            label: "Networks"
            labelElement.font.weight: 600
            labelElement.color: "#90000000"
        }
        IconItem {
            label: "CampusOne"
            iconName: "folder-wifi"
            selected: true
        }

        MenuDiv {}
        MenuItem {
            label: "Wi-Fi Settings..."
            onTriggered: {
                preferences.running = true;
                root.visible = false;
            }
        }
        Process {
            id: preferences
            command: ["bash", "-c", "kcmshell6 kcm_mobile_wifi"]
            running: false
        }

        Item {
            Layout.preferredHeight: 8
        }
    }
}
