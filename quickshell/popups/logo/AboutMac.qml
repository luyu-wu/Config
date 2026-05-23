import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

FloatingWindow {
    id: root

    title: "About This Framework"
    implicitWidth: 510
    implicitHeight: 315
    minimumSize: Qt.size(510, 315)
    maximumSize: Qt.size(510, 315)
    visible: false
    color: "#f6f6f6"

    readonly property string imagePath: "file:///home/chrysanthemum/.config/waybar/scripts/sierra.jpg"

    function show() {
        root.visible = true;
    }

    // ── Content ─────────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        anchors.bottomMargin: 16
        spacing: 20

        // ── Left: circular image ────────────────────────────────────────────
        Item {
            Layout.preferredWidth: 140
            Layout.preferredHeight: 140
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 10

            ClippingRectangle {
                id: imgContainer
                anchors.fill: parent
                radius: 70
                clip: true

                Image {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: root.imagePath
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                }
            }

            // Circular border
            Rectangle {
                anchors.fill: parent
                radius: 70
                color: "transparent"
                border.color: Qt.rgba(180 / 255, 180 / 255, 185 / 255, 0.47)
                border.width: 2
            }
        }

        // ── Right: info column ──────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            // ── OS title ────────────────────────────────────────────────────
            Text {
                text: "hyprOS High Sierra"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                font.letterSpacing: -0.5
                color: "#1a1a1a"
            }

            Text {
                text: "Version 10.13"
                font.pixelSize: 12
                color: "#666666"
            }

            Item {
                Layout.preferredHeight: 10
            }

            // ── Model ───────────────────────────────────────────────────────
            Text {
                text: "Framework (13-inch, 2024, Four USB 4 Ports)"
                font.pixelSize: 12
                color: "#1a1a1a"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Item {
                Layout.preferredHeight: 4
            }

            // ── Spec rows ───────────────────────────────────────────────────
            SpecRow {
                label: "Processor"
                value: "5.1 GHz AMD Ryzen R7"
            }
            SpecRow {
                label: "Memory"
                value: "32 GB 5600 MHz DDR5"
            }
            SpecRow {
                label: "Startup Disk"
                value: "NVMe Storage"
            }
            SpecRow {
                label: "Graphics"
                value: "AMD Ryzen 780M 512 MB"
            }
            SpecRow {
                label: "Serial Number"
                valueComponent: Rectangle {
                    implicitWidth: 130
                    implicitHeight: 18
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "#e0e0e0"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#c8c8c8"
                        }
                    }
                    border.color: "#aaaaaa"
                    border.width: 1
                    radius: 2
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    // ── Bottom row: buttons + copyright ─────────────────────────────────────
    ColumnLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            AboutButton {
                text: "System Report..."
            }
            AboutButton {
                text: "Software Update..."
            }
        }

        Text {
            text: "\u00A9 2007-2026 Framework Inc. All Rights Reserved.  License and Warranty"
            font.pixelSize: 10
            color: "#888888"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ── Reusable spec row ───────────────────────────────────────────────────
    component SpecRow: RowLayout {
        required property string label
        property alias value: valueText.text
        property Component valueComponent: null

        spacing: 4
        Layout.topMargin: 1
        Layout.bottomMargin: 1

        Text {
            text: parent.label
            font.pixelSize: 12
            color: "#555555"
            Layout.preferredWidth: 110
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: valueText
            visible: !parent.valueComponent
            font.pixelSize: 12
            color: "#1a1a1a"
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
        }

        Loader {
            visible: !!parent.valueComponent
            Layout.fillWidth: true
            sourceComponent: parent.valueComponent
        }
    }

    // ── Reusable button ─────────────────────────────────────────────────────
    component AboutButton: Rectangle {
        property alias text: btnLabel.text

        implicitWidth: 130
        implicitHeight: 24
        radius: 4
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: btnMouse.pressed ? "#d0d0d0" : (btnMouse.containsMouse ? "#ffffff" : "#f5f5f5")
            }
            GradientStop {
                position: 1.0
                color: btnMouse.pressed ? "#e8e8e8" : (btnMouse.containsMouse ? "#ebebeb" : "#e0e0e0")
            }
        }
        border.color: "#b0b0b0"
        border.width: 1

        Behavior on gradient {
            enabled: !btnMouse.pressed
            ColorAnimation {
                duration: 80
            }
        }

        Text {
            id: btnLabel
            anchors.centerIn: parent
            font.pixelSize: 12
            color: "#1a1a1a"
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
