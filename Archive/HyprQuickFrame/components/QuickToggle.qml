import QtQuick
import QtQuick.Effects

Rectangle {
    id: root

    property bool active: false
    property string icon: ""
    property color iconColor: "black"
    property color backgroundColor: "white"
    property real targetX: 0
    property real targetY: 0
    property real sourceX: 0
    property bool hovered: false
    property bool pulse: false
    property color shadowColor: "#80000000"
    readonly property real buttonSize: 44
    readonly property real inactiveScale: 0.4
    readonly property real activeIconSize: 30
    readonly property real inactiveIconSize: 20
    readonly property real pulseMinOpacity: 0.3
    readonly property int springAnimDuration: 350
    readonly property int fadeAnimDuration: 250
    readonly property int pulseStepDuration: 600
    property url imageSource: ""
    property color borderColor: "transparent"
    property int borderWidth: 0

    signal clicked()

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

    Text {
        id: iconText

        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: root.active ? root.activeIconSize : root.inactiveIconSize
        font.weight: root.active ? Font.Bold : Font.Medium
        visible: root.imageSource === ""

        Behavior on font.pixelSize {
            NumberAnimation {
                duration: root.springAnimDuration
                easing.type: Easing.OutQuad
            }

        }

        SequentialAnimation on opacity {
            id: pulseAnimText

            running: root.active && root.pulse && root.imageSource === ""
            loops: Animation.Infinite
            onRunningChanged: {
                if (!running)
                    iconText.opacity = 1;

            }

            NumberAnimation {
                to: root.pulseMinOpacity
                duration: root.pulseStepDuration
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                to: 1
                duration: root.pulseStepDuration
                easing.type: Easing.InOutQuad
            }

        }

    }

    Item {
        id: iconImageContainer

        anchors.centerIn: parent
        width: root.active ? root.activeIconSize : root.inactiveIconSize
        height: width
        visible: root.imageSource !== ""

        Image {
            id: iconImage

            anchors.fill: parent
            source: root.imageSource
            sourceSize.width: width
            sourceSize.height: height
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        MultiEffect {
            anchors.fill: iconImage
            source: iconImage
            colorization: 1
            colorizationColor: root.iconColor
        }

        Behavior on width {
            NumberAnimation {
                duration: root.springAnimDuration
                easing.type: Easing.OutQuad
            }

        }

        SequentialAnimation on opacity {
            id: pulseAnimImage

            running: root.active && root.pulse && root.imageSource !== ""
            loops: Animation.Infinite
            onRunningChanged: {
                if (!running)
                    iconImageContainer.opacity = 1;

            }

            NumberAnimation {
                to: root.pulseMinOpacity
                duration: root.pulseStepDuration
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                to: 1
                duration: root.pulseStepDuration
                easing.type: Easing.InOutQuad
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        enabled: root.active
        onClicked: root.clicked()
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }

    Behavior on x {
        // Configuration for spring-based transitions
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
            duration: root.fadeAnimDuration
            easing.type: Easing.OutQuad
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: root.springAnimDuration
            easing.type: Easing.OutBack
        }

    }

}
