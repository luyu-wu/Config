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

    width: 340
    height: contentColumn.implicitHeight + 64
    exclusionMode: "Ignore"
    WlrLayershell.namespace: "qs:popup"
    //grabFocus: true
    anchors {
        top: true
        right: true
        //item: parent
        //edges: Edges.Bottom
        //rect.x: mprisLabel.mapToItem(null, 0, 0).x + mprisLabel.width / 2 - width / 2
        //rect.y: 32
    }
    margins.top: 32
    margins.right: -6
    updatesEnabled: false
    color: "transparent"

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
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 20
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: "Clock"
                    color: palette.windowText
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2
                Layout.bottomMargin: 6

                Layout.leftMargin: 4
                Layout.rightMargin: 4

                Text {
                    text: "Hello World"
                    color: "#444"
                    font.pixelSize: 10
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: "-:--"
                    color: "#444"
                    font.pixelSize: 10
                }
            }
        }
    }
}
