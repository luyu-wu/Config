import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower

import qs.share.menu

PopupWindow {
    id: root

    implicitWidth: 280
    implicitHeight: menuColumn.implicitHeight + 8
    grabFocus: true
    readonly property var battery: UPower.displayDevice

    anchor {
        item: batteryWidget
        edges: Edges.Bottom
        rect.y: 38
        rect.x: 18 - batteryWidget.width / 2
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
            implicitHeight: 10
            color: "transparent"
        }
        MenuLabel {
            label: "Battery"
            secondary: String(Math.round(battery.percentage * 100)) + "%"
            secondaryElement.color: "#444"
            labelElement.font.weight: 600
        }
        MenuLabel {
            label: "Power Source:  " + (battery.state != 2 ? "Power Adapter" : "Battery")
            labelElement.color: "#666"
        }
        MenuLabel {
            label: battery.state != 2 ? (battery.changeRate > 2 ? "Charging (" + Math.floor(battery.changeRate * 10) / 10 + " W)" : "Fully Charged") : String(Math.round(battery.timeToEmpty / 60)) + " min Remaining (" + String(Math.round(battery.changeRate * 10) / 10) + " W)"
            labelElement.color: "#666"
        }

        MenuDiv {}

        MenuLabel {
            label: "Energy Mode"
            labelElement.font.weight: 600
            labelElement.color: "#90000000"
        }

        IconItem {
            label: "High Power"
            selected: (PowerProfiles.profile == 2)
            onTriggered: PowerProfiles.profile = 2
            iconName: "battery-profile-performance"
        }
        IconItem {
            label: "Balanced"
            selected: (PowerProfiles.profile == 1)
            onTriggered: PowerProfiles.profile = 1
            iconName: "battery-040"
        }
        IconItem {
            label: "Low Power"
            selected: (PowerProfiles.profile == 0)
            onTriggered: PowerProfiles.profile = 0
            iconName: "battery-profile-powersave"
        }

        MenuDiv {}

        MenuItem {
            label: "Battery Preferences..."
            onTriggered: {
                preferences.running = true;
                root.visible = false;
            }
        }
        Process {
            id: preferences
            command: ["bash", "-c", "kcmshell6 kcm_mobile_power"]
            running: false
        }

        // bottom padding
        Item {
            Layout.preferredHeight: 8
        }
    }
}
