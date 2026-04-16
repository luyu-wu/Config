import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell
import qs.popups.tray

Item {
    id: rootWidget

    Layout.fillHeight: true
    implicitWidth: trayRow.implicitWidth + 12  // 6px left + 6px right pad

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: root
                required property var modelData
                property bool opened: false
                width: 32
                height: 40
                Rectangle {
                    anchors.fill: parent
                    color: root.opened ? "#20000000" : "transparent"
                    radius: 6

                    Image {
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        source: modelData.icon
                        sourceSize.width: width
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        asynchronous: true
                    }
                    MouseArea {
                        id: trayIconItem
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton // Set valid interactions
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onPressed: mouse => {
                            if (mouse.button == Qt.RightButton) { // Run default
                                modelData.activate();
                            } else if (mouse.button == Qt.LeftButton) { // Open context menu
                                menu.open();
                                root.opened = !root.opened;
                            }
                        }
                        QsMenuOpener {
                            menu: modelData.menu
                        }
                        QsMenuAnchor {
                            id: menu
                            menu: modelData.menu
                            anchor {
                                item: trayIconItem
                                edges: Edges.Bottom
                            }
                        }
                    }
                }
                trayPopup {
                    id: trayPopup
                    anchorPoint: trayIconItem
                }
            }
        }
    }
}
