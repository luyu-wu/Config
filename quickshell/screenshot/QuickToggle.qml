import QtQuick
import QtQuick.Effects
import ".."

// Round icon button that springs between an off-screen "source" position and
// its slot in the toolbar, used for the Edit and Temp toggles.
Rectangle {
    id: root

    Variables { id: v }

    property bool active: false
    // Off by default here: these buttons toggle on click/keypress, and a false
    // toggle should not queue a second action on the way out.
    property bool behaviorOnDeactivate: false
    property color iconColor: v.accentForeground
    property color backgroundColor: v.accentColor
    property color shadowColor: v.shadowColor
    property color borderColor: "transparent"
    property int borderWidth: 0
    property real targetX: 0
    property real targetY: 0
    property real sourceX: 0
    property url imageSource: ""

    signal clicked

    readonly property real buttonSize: 44
    readonly property real inactiveScale: 0.4
    readonly property real activeIconSize: 30
    readonly property real inactiveIconSize: 20
    readonly property int fadeDuration: 250

    property bool hovered: false

    onActiveChanged: {
        if (!active)
            hovered = false;
    }

    visible: active || opacity > 0
    width: buttonSize
    height: buttonSize
    radius: buttonSize / 2
    color: backgroundColor
    border.color: borderColor
    border.width: borderWidth
    x: active ? targetX : sourceX
    y: targetY - height / 2
    scale: active ? (hovered ? 1.1 : 1) : inactiveScale
    opacity: active ? 1 : 0
    antialiasing: true

    Item {
        id: iconContainer

        anchors.centerIn: parent
        width: root.active ? root.activeIconSize : root.inactiveIconSize
        height: width

        Image {
            id: iconImage

            anchors.fill: parent
            source: root.imageSource
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: false
        }

        MultiEffect {
            anchors.fill: iconImage
            source: iconImage
            colorization: 1
            colorizationColor: root.iconColor
        }

        Behavior on width {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        enabled: root.active
        onClicked: {
            if (root.behaviorOnDeactivate)
                root.active = false;
            root.clicked();
        }
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }

    Behavior on x {
        SpringAnimation {
            spring: 4
            damping: 0.4
            mass: 0.8
        }
    }

    Behavior on y {
        SpringAnimation {
            spring: 4
            damping: 0.4
            mass: 0.8
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.fadeDuration
            easing.type: Easing.OutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutBack
        }
    }
}
