import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../.."

PopupWindow {
    Variables { id: v }
    id: root

    property QsMenuHandle menuHandle
    property Item anchorPoint
    // Popup that opened this one, when this popup is a submenu.
    property var parentMenu: null
    // True when this popup is a submenu of another TrayPopup.
    property bool submenu: false
    // Topmost popup of the chain, so the whole menu can be dismissed at once.
    readonly property var topMenu: parentMenu ? parentMenu.topMenu : root

    QsMenuOpener {
        id: opener
        menu: menuHandle
    }
    implicitWidth: 240
    implicitHeight: menuColumn.implicitHeight + 16
    // Submenus must also be grabbing popups (Qt::Popup). A non-grabbing
    // (Qt::ToolTip) window is not registered in the parent popup's input chain
    // on Wayland, so it would never receive hover or clicks.
    grabFocus: true

    anchor {
        item: root.anchorPoint
        // Submenus overlap the parent's 8px shadow margin and the row's 4px
        // inset so their visible panel sits flush against the parent panel's
        // right edge instead of leaving a gap.
        rect.x: root.submenu ? root.anchorPoint.width - 4 : -12
        rect.y: root.submenu ? -4 : 38
        adjustment: root.submenu
            ? (PopupAdjustment.FlipX | PopupAdjustment.SlideY)
            : PopupAdjustment.Slide
    }
    color: "transparent"

    // Close every submenu opened by the rows of this popup, except the row
    // that is currently requesting one.
    function closeSubmenus(exceptItem) {
        for (let i = 0; i < menuRepeater.count; i++) {
            const entry = menuRepeater.itemAt(i);
            if (entry && entry !== exceptItem && entry.closeSubmenu)
                entry.closeSubmenu();
        }
    }

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
        color: v.shadowColor
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
        color: v.popupBackground
        border.color: v.popupBorder
        border.width: 1
    }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            anchors.topMargin: -1
            radius: dropdown.radius
            color: "transparent"
            border.color: v.outerBorderColor
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
        Repeater {
            id: menuRepeater
            model: opener.children

            delegate: TrayMenuItem {
                required property QsMenuHandle modelData
                dropdown: root
                menuHandle: modelData
            }
        }
    }
}
