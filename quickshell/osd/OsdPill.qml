import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import ".."

// The OSD pill itself: an icon plus a progress bar. Purely presentational —
// Osd.qml owns the visibility timing and decides what is shown.
Item {
    Variables { id: v }
    id: root

    readonly property real progress: Math.max(0, Math.min(1, value))
    property real value: 0
    property string iconName: "audio-volume-high"
    property color accent: v.textColor
    property real radius: 16

    implicitWidth: 300
    implicitHeight: 64

    // ── At-limit spring ─────────────────────────────────────────────
    property int bumpToken: 0
    // +1 when pushed past the top, -1 when pushed past the bottom.
    property int bumpDirection: 1

    property real bump: 0
    // Kept small enough to stay inside OsdWindow's shadowMargin.
    readonly property real bumpNudge: 9
    readonly property real bumpGrow: 0.06

    onBumpTokenChanged: bumpAnim.restart()

    SequentialAnimation {
        id: bumpAnim
        // Quick shove in the direction of the push...
        NumberAnimation {
            target: root
            property: "bump"
            to: 1
            duration: 160
            easing.type: Easing.OutQuad
        }
        // ...then spring back, overshooting a little before it settles.
        NumberAnimation {
            target: root
            property: "bump"
            to: 0
            duration: 500
            easing.type: Easing.OutElastic
            easing.amplitude: 1.2
            easing.period: 0.8
        }
    }

    transform: [
        Scale {
            origin.x: root.width / 2
            xScale: 1 + root.bumpGrow * root.bump
        },
        Translate {
            x: root.bumpDirection * root.bumpNudge * root.bump
        }
    ]

    Rectangle {
        id: card
        anchors.fill: parent
        radius: root.radius
        color: v.popupBackground
        border.color: v.popupBorder
        border.width: 1

        // Inner highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: card.radius - 1
            color: "transparent"
            border.color: v.widgetHighlight
            border.width: 1
        }
    }

    IconImage {
        id: icon
        x: 18
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: 36
        source: "image://icon/" + root.iconName
    }


    // ── Progress track ───────────────────────────────────────────
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.right
        anchors.leftMargin: 16
        anchors.right: card.right
        anchors.rightMargin: 14
        height: 10
        radius: 5
        color: v.widgetHighlight

        ClippingRectangle {
            anchors.fill: parent
            anchors.margins: 0
            radius: parent.radius
            color: "transparent"

            Rectangle {
                width: root.progress * parent.width
                height: parent.height
                radius: 18
                color: root.accent
            }
        }
    }
}
