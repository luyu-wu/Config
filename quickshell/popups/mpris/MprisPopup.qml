import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import "../.."

PanelWindow {
    id: root
    Variables { id: v }

    //  Window ─
    implicitWidth: 340
    implicitHeight: contentColumn.implicitHeight + 64
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qs:popup"
    updatesEnabled: false
    color: "transparent"
    anchors {
        top: true
        left: true
    }
    margins.top: 32
    margins.left: popupX

    //  Player state ─
    property var player: null
    readonly property string albumPlaceholder: "image://theme/media-album-cover"
    readonly property string artUrl: player?.trackArtUrl ?? ""
    readonly property string title: player?.trackTitle ?? "没有歌在播放"
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string album: player?.trackAlbum ?? ""
    readonly property real position: player?.position ?? 0
    readonly property real length: player?.length ?? 0
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing

    //  Placement ─
    property real popupX: mprisLabel.mapToItem(null, 0, 0).x + mprisLabel.width / 2 - width / 2

    Connections {
        target: mprisLabel
        function onWidthChanged() {
            repositionTimer.restart()
        }
    }
    Timer {
        id: repositionTimer
        interval: 1
        onTriggered: {
            root.popupX = mprisLabel.mapToItem(null, 0, 0).x + mprisLabel.width / 2 - root.width / 2
        }
    }

    //  Entrance transition ─
    //  The real card stays hidden until the blurred, fading snapshot has
    //  finished sharpening, matching Spotlight's reveal.
    readonly property int blurTransitionTime: 300
    property bool revealed: false

    onVisibleChanged: {
        root.revealed = false
        if (visible)
            revealTimer.restart()
        else
            revealTimer.stop()
    }
    Timer {
        id: revealTimer
        interval: root.blurTransitionTime + 10
        onTriggered: root.revealed = true
    }

    MultiEffect {
        anchors.fill: card
        visible: !root.revealed
        source: card
        blurEnabled: true
        blurMax: 128
        blur: root.visible ? 0.0 : 1.0
        opacity: root.visible ? 1.0 : 0.0
        Behavior on blur {
            NumberAnimation {
                duration: root.blurTransitionTime
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: root.blurTransitionTime - 50
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        visible: root.revealed
        radius: 16
        color: "transparent"

        //  Rounded mask so the outer shadow does not bleed into the corners.
        Item {
            id: mask
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Rectangle {
                anchors.fill: parent
                anchors.margins: 16
                radius: card.radius
                color: "#fff"
            }
        }
        RectangularShadow {
            id: outerShadow
            anchors.fill: parent
            radius: card.radius
            blur: 16
            color: v.shadowColor
            spread: -16
            visible: false
        }
        MultiEffect {
            anchors.fill: outerShadow
            source: outerShadow
            maskSource: mask
            maskEnabled: true
            maskInverted: true
        }

        //  Card background ─
        ClippingRectangle {
            anchors.fill: parent
            anchors.margins: 16
            radius: card.radius
            color: v.popupBackground
            border.color: v.popupBorder
            border.width: 1
            clip: true
            RectangularShadow {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                blur: 24
                implicitHeight: 1
                color: "#60ffffff"
            }
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: 15
            radius: card.radius
            color: "transparent"
            border.color: v.outerBorderColor
            border.width: 1
        }

        //  Content ─
        ColumnLayout {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 36
            }
            spacing: 0

            //  Album art ─
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                Layout.topMargin: 4
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                color: "transparent"

                RectangularShadow {
                    anchors.fill: parent
                    radius: 10
                    blur: 8
                    color: Qt.rgba(0, 0, 0, 0.1)
                    spread: 4
                }
                ClippingRectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    Image {
                        id: artImage
                        anchors.fill: parent
                        mipmap: true
                        source: root.artUrl || root.albumPlaceholder
                        fillMode: Image.PreserveAspectCrop
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: artImage.status !== Image.Ready
                    text: "♫"
                    font.pixelSize: 64
                    color: "#333"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.player?.raise()
                        root.visible = false
                    }
                }
            }

            //  Track info ─
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 20
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: v.textColor
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    Layout.fillWidth: true
                    visible: root.artist.length > 0 || root.album.length > 0
                    text: [root.artist, root.album].filter(Boolean).join("  ·  ")
                    color: v.textSecondary
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            //  Position ticker ─
            Timer {
                running: root.playing && root.visible && !seekSlider.pressed
                interval: 1000
                repeat: true
                onTriggered: {
                    if (root.player)
                        root.player.positionChanged()
                }
            }

            //  Seek bar ─
            Slider {
                id: seekSlider
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.preferredHeight: 20
                from: 0
                to: root.length
                value: root.position
                background: Rectangle {
                    x: seekSlider.leftPadding
                    y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                    width: seekSlider.availableWidth
                    height: 14
                    radius: 7
                    color: "#30303030"
                    border.width: 1
                    border.color: v.widgetHighlight
                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 7
                        color: "transparent"
                        Rectangle {
                            width: seekSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#ffffff"
                        }
                    }
                }
                handle: Rectangle {
                    color: "transparent"
                }
                onMoved: {
                    if (root.player)
                        root.player.position = root.length * seekSlider.visualPosition
                }
            }

            //  Elapsed / total ─
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2
                Layout.bottomMargin: 6
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                Text {
                    text: root.formatTime(root.position)
                    color: v.textSecondary
                    font.pixelSize: 10
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: root.length > 0 ? root.formatTime(root.length) : "-:--"
                    color: v.textSecondary
                    font.pixelSize: 10
                }
            }

            //  Transport controls ─
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4
                ControlButton {
                    icon: "⏮"
                    size: 64
                    onActivated: root.player?.previous()
                }
                ControlButton {
                    icon: root.playing ? "⏸" : "▶️"
                    size: 64
                    onActivated: root.playing ? root.player?.pause() : root.player?.play()
                }
                ControlButton {
                    icon: "⏭"
                    size: 64
                    onActivated: root.player?.next()
                }
            }
        }
    }

    function formatTime(seconds) {
        const minutes = Math.floor(seconds / 60)
        const remainder = Math.floor(seconds % 60)
        return minutes + ":" + String(remainder).padStart(2, "0")
    }
}
