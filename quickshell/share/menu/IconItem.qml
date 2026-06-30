// MenuItem.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: item
    property alias labelElement: labelText
    property alias mouseArea: mouseArea
    property alias iconName: iconButton.icon.name
    property bool selected: false
    property string label: ""
    signal triggered

    Layout.fillWidth: true
    Layout.leftMargin: 4
    Layout.rightMargin: 4
    implicitHeight: 40
    radius: 4
    color: hovered ? "#20000000" : "transparent"

    property bool hovered: false

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }
        spacing: 10
        Rectangle {
            implicitWidth: 32
            implicitHeight: 32
            color: selected ? "#097aff" : "#15000000"

            radius: 16
            Button {
                id: iconButton
                implicitWidth: 32
                implicitHeight: 32

                icon.name: "headphone"
                icon.color: selected ? "#fff" : "#222"
                flat: true
            }
        }
        Text {
            id: labelText
            text: item.label
            color: "#202020"
            font.family: "SF Pro"
            font.pixelSize: 18
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
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
