import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell

Item {
    id: rootWidget

    Layout.fillHeight: true
    implicitWidth: trayRow.implicitWidth + 12  // 6px left + 6px right pad

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 20

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property var modelData

                width: 20
                height: 40

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    asynchronous: true

                    MouseArea {
                        id: trayIconItem
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton // Set valid interactions
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onPressed: mouse => {
                            if (mouse.button == Qt.LeftButton) { // Run default
                                modelData.activate();
                            } else if (mouse.button == Qt.RightButton) { // Open context menu
                                menu.open();
                            }
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
            }
        }
    }
}
