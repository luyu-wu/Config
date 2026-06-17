// MenuItem.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: item
    property alias labelElement: labelText
    property alias secondaryElement: labelSecondary

    property string label: ""
    property string secondary: ""

    Layout.fillWidth: true
    Layout.leftMargin: 4
    Layout.rightMargin: 4
    implicitHeight: 32
    color: "transparent"

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
            color: "#202020"
            font.family: "SF Pro"
            font.pixelSize: 18
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            id: labelSecondary

            visible: item.secondary !== ""
            text: item.secondary
            color: "#808080"
            font.family: "SF Pro"
            font.pixelSize: 16
        }
    }
}
