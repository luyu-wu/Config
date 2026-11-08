// SpotlightResult.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: item

    required property var entry
    property bool selected: false
    signal activated()

    Layout.fillWidth: true
    Layout.preferredHeight: 44
    radius: 16
    color: selected ? v.widgetHighlight : "transparent"
    border.color: v.menuDividerColor
    border.width: selected ? 1 : 0

    Variables { id: v }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 6
            rightMargin: 10
        }
        spacing: 10

        Image {
            source: {
                var path = Quickshell.iconPath(item.entry.icon, true);
                return path || Quickshell.iconPath("application-x-executable");
            }
            sourceSize.width: 28
            sourceSize.height: 28
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            asynchronous: true
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: item.entry.name
                color: v.textColor
                font.pixelSize: 14
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: item.entry.genericName || ""
                color: v.textSecondary
                font.pixelSize: 11
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: item.activated()
    }
}
