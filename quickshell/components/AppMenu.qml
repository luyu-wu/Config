import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Variables { id: v }
    id: root

    Layout.fillHeight: true
    implicitWidth: menuLabel.implicitWidth + 12

    Text {
        id: menuLabel
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 14
        }
        //text: "文件     编辑     显示     前往     窗口     帮助"
        text: "File     Edit     View     Go     Window     Help"

        font.family: "SF Pro"
        font.pixelSize: 21
        color: v.textColor
        renderType: Text.NativeRendering
    }
}
