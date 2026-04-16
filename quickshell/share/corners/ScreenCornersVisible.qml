import Quickshell
import QtQuick

Item {
	implicitWidth: parent.width
	implicitHeight: parent.height
	anchors {
		fill: parent
	}
	CutoutCorner {
        corners: 4
		cornerHeight: 16
		cornerType: "inverted"
        anchors {
          right: parent.right
        }
		color: "black"
	}
}
