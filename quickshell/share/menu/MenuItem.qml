// MenuItem.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: item
    property alias labelElement: labelText
    property alias mouseArea: mouseArea

    property string label: ""
    property string shortcut: ""
    property bool hasSubmenu: false
    signal triggered

    Layout.fillWidth: true
    Layout.leftMargin: 4
    Layout.rightMargin: 4
    implicitHeight: 32
    radius: 4
    color: hovered ? "#1071db" : "transparent"

    property bool hovered: false

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }
        spacing: 0

        Text {
            id: labelText
            text: item.label
            color: item.hovered ? "#ffffff" : "#202020"
            font.family: "SF Pro"
            font.pixelSize: 18
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            visible: item.hasSubmenu
            text: "›"
            color: item.hovered ? "#ffffff" : "#606060"
            font.pixelSize: 16
        }

        Text {
            visible: item.shortcut !== ""
            text: item.shortcut
            color: item.hovered ? "#ddeeff" : "#808080"
            font.family: "SF Pro"
            font.pixelSize: 16
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: item.hovered = true
        onExited: item.hovered = false
        onClicked: item.triggered()
        cursorShape: Qt.PointingHandCursor
    }
}
