import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Widgets

PanelWindow {
    id: root

    implicitWidth: 340
    implicitHeight: contentColumn.implicitHeight + 64
    exclusionMode: "Ignore"
    WlrLayershell.namespace: "qs:popup"
    //grabFocus: true
    anchors {
        top: true
        left: true
        //item: parent
        //edges: Edges.Bottom
        //rect.x: mprisLabel.mapToItem(null, 0, 0).x + mprisLabel.width / 2 - width / 2
        //rect.y: 32
    }
    margins.top: 32
    margins.left: popupX
    updatesEnabled: false
    color: "transparent"
    property real popupX: mprisLabel.mapToItem(null, 0, 0).x + mprisLabel.width / 2 - width / 2
    property string albumPlaceholder: "image://theme/media-album-cover"
    property var player: null
    readonly property string artUrl: player?.trackArtUrl ?? ""
    readonly property string title: player?.trackTitle ?? "没有歌在播放"
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string album: player?.trackAlbum ?? ""
    readonly property bool canPlay: player?.canPlay ?? false
    readonly property bool canPause: player?.canPause ?? false
    readonly property bool canNext: player?.canGoNext ?? false
    readonly property bool canPrev: player?.canGoPrevious ?? false
    readonly property bool canSeek: player?.canSeek ?? false
    readonly property real position: player?.position ?? 0
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing
    readonly property real length: player?.length ?? 0

    Connections {
        target: mprisLabel
        function onWidthChanged() {
            repositionTimer.restart();
        }
    }
    Timer {
        id: repositionTimer
        interval: 1
        repeat: false
        onTriggered: {
            root.popupX = mprisLabel.mapToItem(null, 0, 0).x + mprisLabel.width / 2 - root.width / 2;
        }
    }
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: "transparent"

        Item {
            id: mask
            anchors.fill: card
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
            anchors.fill: card
            radius: card.radius
            blur: 16
            color: Qt.rgba(0, 0, 0, 0.35)
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

        Rectangle {
            id: mprisBorder
            anchors.fill: parent
            anchors.margins: 16
            radius: parent.radius
            color: "#a2e4e7ef"
            border.color: "#a0a0a0"
            border.width: 1
        }

        ColumnLayout {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 36
            }
            spacing: 0

            Rectangle {
                visible: true
                Layout.fillWidth: true
                Layout.preferredHeight: width    // square; image adapts
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
                    color: "transparent"
                    radius: 10
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
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        root.player?.raise();
                        root.visible = false;
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 20
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: palette.windowText
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.artist.length > 0 || root.album.length > 0
                    text: [root.artist, root.album].filter(Boolean).join("  ·  ")
                    color: "#666"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            Timer {
                running: playing && root.visible && !seekSlider.pressed
                interval: 1000
                repeat: true
                onTriggered: player.positionChanged()
            }
            Slider {
                id: seekSlider
                Layout.fillWidth: true
                Layout.topMargin: 12

                Layout.leftMargin: 0
                Layout.rightMargin: 0
                from: 0
                to: player.length
                value: player.position
                height: 20
                background: Rectangle {
                    x: seekSlider.leftPadding
                    y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                    width: seekSlider.availableWidth
                    height: 14
                    radius: 7
                    color: "#30303030"
                    border.width: 1
                    border.color: "#77a0a2"
                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 7
                        color: "transparent"

                        Rectangle {
                            width: seekSlider.visualPosition * (parent.width)
                            height: parent.height
                            color: "#ffffff"
                        }
                    }
                }
                handle: Rectangle {
                    color: "transparent"
                }

                onMoved: {
                    player.position = player.length * seekSlider.visualPosition;
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2
                Layout.bottomMargin: 6

                Layout.leftMargin: 4
                Layout.rightMargin: 4

                Text {
                    text: formatMs(root.position)
                    color: "#444"
                    font.pixelSize: 10
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: root.length > 0 ? formatMs(root.length) : "-:--"
                    color: "#444"
                    font.pixelSize: 10
                }
            }

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: controlRow.implicitHeight

                RowLayout {
                    id: controlRow
                    width: implicitWidth
                    anchors.centerIn: parent
                    spacing: 4

                    // Previous
                    ControlButton {
                        icon: "⏮"
                        size: 64
                        onActivated: root.player?.previous()
                    }

                    // Play / Pause
                    ControlButton {
                        icon: root.playing ? "⏸" : "▶"
                        size: 64
                        onActivated: root.playing ? root.player?.pause() : root.player?.play()
                    }

                    // Next
                    ControlButton {
                        icon: "⏭"
                        size: 64
                        onActivated: root.player?.next()
                    }
                }
            }
        } // ColumnLayout
    } // card Rectangle

    function formatMs(totalSec) {
        const m = Math.floor(totalSec / 60);
        const s = Math.floor(totalSec % 60);
        return m + ":" + String(s).padStart(2, "0");
    }
}
