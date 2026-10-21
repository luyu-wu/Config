import QtQuick
import QtQuick.Layouts
import "../.."

// Button used by the system power dialog: a translucent secondary style and a
// filled accent style for the destructive confirm action.
Rectangle {
    Variables { id: v }
    id: btn

    property string text: ""
    // Filled accent variant for the destructive confirm action.
    property bool accent: false
    property bool hovered: false
    property bool pressed: false
    signal invoked

    implicitHeight: 30
    Layout.preferredHeight: 30
    radius: 7
    color: {
        if (btn.accent)
            return btn.pressed ? Qt.darker(v.accentColor, 1.2)
                               : (btn.hovered ? Qt.lighter(v.accentColor, 1.1) : v.accentColor);
        return btn.pressed ? Qt.rgba(0, 0, 0, 0.12)
                           : (btn.hovered ? Qt.rgba(0, 0, 0, 0.09) : Qt.rgba(0, 0, 0, 0.06));
    }

    Behavior on color {
        enabled: !btn.pressed
        ColorAnimation {
            duration: 80
        }
    }

    Text {
        anchors.centerIn: parent
        text: btn.text
        color: btn.accent ? v.accentForeground : v.textColor
        font.family: "SF Pro"
        font.pixelSize: 13
        font.weight: Font.Medium
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: btn.hovered = true
        onExited: {
            btn.hovered = false;
            btn.pressed = false;
        }
        onPressedChanged: btn.pressed = pressed
        onClicked: btn.invoked()
    }
}
