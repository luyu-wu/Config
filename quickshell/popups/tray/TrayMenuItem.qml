import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.share.menu
import "../.."

Rectangle {
    Variables { id: v }
    id: root
    property QsMenuHandle menuHandle
    property PopupWindow dropdown

    Layout.fillWidth: true
    Layout.leftMargin: 4
    Layout.rightMargin: 4
    implicitHeight: menuHandle.isSeparator ? 1 : 32
    Layout.topMargin: menuHandle.isSeparator ? 4 : 0
    Layout.bottomMargin: menuHandle.isSeparator ? 4 : 0

    color: "transparent"

    // ── submenu ──────────────────────────────────────────────────────────────
    // Loaded lazily through a string URL. TrayPopup instantiates TrayMenuItem,
    // so referencing TrayPopup directly here would be a cyclic component
    // dependency that QML refuses to resolve.
    property bool submenuOpen: false
    property bool pendingSubmenuOpen: false

    Loader {
        id: submenuLoader
        active: false
        source: "TrayPopup.qml"

        onLoaded: {
            item.menuHandle = root.menuHandle;
            item.anchorPoint = row;
            item.submenu = true;
            item.parentMenu = root.dropdown;
            if (root.pendingSubmenuOpen) {
                root.pendingSubmenuOpen = false;
                item.visible = true;
            }
        }
    }

    // A grabbing submenu can be dismissed by the compositor (clicking outside
    // it), so the toggle state has to follow the popup's real visibility.
    Connections {
        target: submenuLoader.item
        function onVisibleChanged() {
            if (submenuLoader.item && !submenuLoader.item.visible)
                root.submenuOpen = false;
        }
    }

    function openSubmenu() {
        if (!menuHandle.hasChildren)
            return;
        if (dropdown && dropdown.closeSubmenus)
            dropdown.closeSubmenus(root);
        submenuOpen = true;
        submenuLoader.active = true;
        if (submenuLoader.item) {
            submenuLoader.item.visible = true;
        } else {
            pendingSubmenuOpen = true;
        }
    }

    function closeSubmenu() {
        pendingSubmenuOpen = false;
        submenuOpen = false;
        if (submenuLoader.item)
            submenuLoader.item.visible = false;
        // Release the child menu so the app is told the submenu was closed.
        submenuLoader.active = false;
    }

    function toggleSubmenu() {
        if (submenuOpen)
            closeSubmenu();
        else
            openSubmenu();
    }

    // Hiding the menu this row belongs to (or a submenu further up the chain)
    // must also take this row's submenu down with it.
    Connections {
        target: root.dropdown
        function onVisibleChanged() {
            if (!root.dropdown.visible)
                root.closeSubmenu();
        }
    }

    onMenuHandleChanged: root.closeSubmenu()

    Rectangle {
        anchors.fill: parent
        color: "#33000000"
        visible: menuHandle.isSeparator
    }

    Rectangle {
        id: row
        visible: !menuHandle.isSeparator
        anchors.fill: parent

        radius: 4
        color: active ? v.accentColor : "transparent"

        property bool hovered: false
        // The row stays highlighted while its submenu is open.
        readonly property bool active: hovered || root.submenuOpen

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 14
                rightMargin: 14
            }
            spacing: 10
            Image {
                visible: menuHandle.icon !== ""
                source: menuHandle.icon
                sourceSize.width: 18
                sourceSize.height: 18
            }
            Text {
                id: labelText
                text: menuHandle.text
                color: row.active ? v.accentForeground : v.textColor
                font.family: "SF Pro"
                font.pixelSize: 18
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            Rectangle {
                visible: menuHandle.buttonType !== 0
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: "#10000000"
                border.width: 1
                border.color: "#77a0a2"

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    radius: 8
                    color: v.accentColor
                    visible: menuHandle.checkState != 0
                }
            }
            Text {
                text: ""
                color: row.active ? v.accentForeground : v.textSecondary
                visible: menuHandle.hasChildren
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: row.hovered = true
            onExited: row.hovered = false
            onClicked: {
                if (menuHandle.hasChildren) {
                    // Parents toggle their submenu instead of running an action.
                    root.toggleSubmenu();
                } else {
                    menuHandle.triggered();
                    // Leaf items dismiss the whole chain; toggles stay open so
                    // the user can keep interacting with the menu.
                    if (menuHandle.buttonType === 0)
                        dropdown.topMenu.visible = false;
                }
            }
            cursorShape: Qt.PointingHandCursor
        }
    }
}
