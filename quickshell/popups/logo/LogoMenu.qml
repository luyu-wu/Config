import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import qs.share.menu

PopupWindow {
    id: root

    implicitWidth: 280
    implicitHeight: menuColumn.implicitHeight + 8
    grabFocus: true

    anchor {
        item: parent
        edges: Edges.Bottom
        rect.y: 38
        rect.x: 0
    }
    color: "transparent"

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
    function exec(cmd) {
        shellProc.command = ["bash", "-c", cmd];
        shellProc.running = true;
        root.visible = false;
    }

    Process {
        id: shellProc
        running: false
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

        MenuItem {
            label: "About This Framework"
            onTriggered: {
                root.visible = false;
                aboutMac.show();
            }
        }

        MenuSep {}

        MenuItem {
            label: "System Preferences…"
            onTriggered: root.exec("systemsettings")
        }
        MenuItem {
            label: "App Store…"
            onTriggered: root.exec("plasma-discover")
        }

        MenuSep {}

        MenuItem {
            label: "Recents"
            hasSubmenu: true
            onTriggered: root.exec("notify-send 'Recents' 'Submenu coming soon'")
        }

        MenuSep {}

        // ── Force Quit ───────────────────────────────────────────────────────
        MenuItem {
            label: "Force Quit…"
            shortcut: "⌃Q"
            onTriggered: root.exec("hyprctl dispatch 'hl.dsp.window.close()'")
        }

        MenuSep {}

        MenuItem {
            label: "Sleep"
            onTriggered: root.exec("systemctl suspend")
        }
        MenuItem {
            label: "Restart…"
            onTriggered: root.exec("systemctl reboot")
        }
        MenuItem {
            label: "Shut Down…"
            onTriggered: root.exec("systemctl poweroff")
        }

        MenuSep {}

        MenuItem {
            label: "Lock Screen"
            shortcut: "⌃K"
            onTriggered: root.exec("hyprlock")
        }
        MenuItem {
            label: "Log Out Chrysanthemum..."
            shortcut: "⌃L"
            onTriggered: root.exec("hyprctl dispatch 'hl.dsp.exit()'")
        }

        // bottom padding
        Item {
            Layout.preferredHeight: 8
        }
    }

    AboutMac {
        id: aboutMac
    }
}
