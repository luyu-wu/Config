import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell
import qs.popups.tray

Item {
    id: rootWidget

    Layout.fillHeight: true
    implicitWidth: trayRow.implicitWidth + 12

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: root
                required property var modelData
                implicitWidth: 32
                implicitHeight: 40
                TrayPopup {
                    id: trayPopup
                    anchorPoint: trayIconItem
                    menuHandle: modelData.menu
                }

                Rectangle {
                    anchors.fill: parent
                    color: trayPopup.visible ? "#20000000" : "transparent"
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
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onPressed: mouse => {
                            if (mouse.button == Qt.RightButton) {
                                modelData.activate();
                            } else if (mouse.button == Qt.LeftButton) {
                                trayPopup.visible = !trayPopup.visible;
                            }
                        }
                    }
                }
            }
        }
    }
}
