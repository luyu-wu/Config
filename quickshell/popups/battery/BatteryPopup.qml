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

    width: 280
    height: menuColumn.implicitHeight + 8
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

        MenuLabel {
            label: "Battery"
            secondary: String(Math.round(battery.percentage * 100)) + "%"
            secondaryElement.color: "#444"
            labelElement.font.weight: 600
        }
        MenuLabel {
            label: "Power Source:  " + (battery.changeRate > -2 ? "Power Adapter" : "Battery")
            labelElement.color: "#666"
        }
        MenuLabel {
            label: battery.timeToEmpty > 24 * 60 * 60 ? (battery.changeRate > 2 ? "Charging" : "Fully Charged") : String(Math.round(battery.timeToEmpty / 60)) + " Minutes Remaining"
            labelElement.color: "#666"
        }
        MenuLabel {
            label: "Charge Rate: " + String(Math.round(battery.changeRate * 10) / 10) + " W"
            labelElement.color: "#666"
        }

        MenuSep {}

        // ── Force Quit ───────────────────────────────────────────────────────
        MenuLabel {
            label: "Energy Mode"
            labelElement.font.weight: 600
            labelElement.color: "#444"
        }

        MenuItem {
            label: "   High Power"
            shortcut: (PowerProfiles.profile == 2 ? "X" : "")
            onTriggered: PowerProfiles.profile = 2
        }
        MenuItem {
            label: "    Balanced"
            shortcut: (PowerProfiles.profile == 1 ? "X" : "")
            onTriggered: PowerProfiles.profile = 1
        }
        MenuItem {
            label: "    Low Power"
            shortcut: (PowerProfiles.profile == 0 ? "X" : "")
            onTriggered: PowerProfiles.profile = 0
        }

        MenuSep {}

        MenuItem {
            label: "Battery Preferences..."
        }

        // bottom padding
        Item {
            Layout.preferredHeight: 8
        }
    }
}
