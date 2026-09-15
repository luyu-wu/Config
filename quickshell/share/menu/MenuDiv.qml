import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    Variables { id: v }

    Layout.fillWidth: true
    Layout.topMargin: 4
    Layout.leftMargin: 18
    Layout.rightMargin: 18
    Layout.bottomMargin: 4
    implicitHeight: 1
    color: v.menuDividerColor
}
