import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.share.menu

Rectangle {
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
    Rectangle {
        anchors.fill: parent
        color: "#33000000"
        visible: menuHandle.isSeparator
    }

    Rectangle {
        id: item
        visible: !menuHandle.isSeparator
        anchors.fill: parent

        radius: 4
        color: hovered ? "#1071db" : "transparent"

        property bool hovered: false

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
                color: item.hovered ? "#ffffff" : "#202020"
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
                    color: "#198aff"
                    visible: menuHandle.checkState != 0
                }
            }
            Text {
                text: ""
                color: item.hovered ? "#ffffff" : "#444"
                visible: menuHandle.hasChildren
            }
        }
        // Loader {
        //     id: childMenuLoader
        //     active: false
        // }
        // QsMenuOpener {
        //     id: menuOpener
        //     menu: menuHandle
        // }
        //TrayPopup {
        //id: childMenu
        //anchorPoint: mouseArea
        //}
        //childMenu.menuHandle: menuHandle
        //QsMenuOpener {
        //    id: childOpener
        //    menu: menuHandle
        //}
        //TrayPopup {
        //    id: child
        //    anchorPoint: item
        //    menuHandle: childOpener.chilren
        // }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: item.hovered = true
            onExited: item.hovered = false
            onClicked: {
                menuHandle.triggered();
                dropdown.visible = menuHandle.hasChildren || (menuHandle.buttonType !== 0);
                //childMenu.visible = menuHandle.hasChildren;
            }
            cursorShape: Qt.PointingHandCursor
        }
    }
}
