import QtQuick
import QtQuick.Layouts

//Custom item to make the code look cleaner
Item {
    required property real length
    Layout.minimumWidth:  isVertical?root.width :length
    Layout.maximumWidth:  isVertical?root.width :length
    Layout.minimumHeight:!isVertical?root.height:length
    Layout.maximumHeight:!isVertical?root.height:length
    /*Rectangle{
        color: "green"
        anchors.fill: parent
        border.color: "red"
        border.width: 1
    }*/
}
