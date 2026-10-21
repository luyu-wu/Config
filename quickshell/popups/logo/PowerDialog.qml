import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../.."
import qs.share.menu

PanelWindow {
    Variables { id: v }
    id: root

    // "poweroff" or "reboot". Either way the machine goes down on its own
    // once the countdown runs out.
    property string mode: "poweroff"
    readonly property bool rebooting: mode === "reboot"
    readonly property int countdownSeconds: 60

    // Countdown, re-armed in openDialog() so a second open starts over.
    property int secondsLeft: countdownSeconds

    implicitWidth: 360
    implicitHeight: 360
    visible: false
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs:popup"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    readonly property real cardWidth: 384
    readonly property real cardHeight: cardLayout.implicitHeight + 60
    readonly property real cardX: (root.width - cardWidth) / 2
    readonly property real cardY: (root.height - cardHeight) / 2 - root.height * 0.04

    mask: Region {
        x: root.cardX
        y: root.cardY
        width: root.cardWidth
        height: root.cardHeight
    }

    function openDialog(action) {
        root.mode = action;
        root.secondsLeft = root.countdownSeconds;
        root.visible = true;
    }

    function close() {
        root.visible = false;
    }

    function cancel() {
        root.close();
    }

    function confirm() {
        // Shut the shell down first: powering off with this surface still
        // mapped leaves the compositor warning about a live layer client.
        root.visible = false;
        Quickshell.execDetached(["systemctl", root.mode]);
    }

    // The backdrop takes focus for Escape whenever the sheet maps.
    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => backdrop.forceActiveFocus());
    }

    Timer {
        id: countdown
        interval: 1000
        repeat: true
        running: root.visible
        onTriggered: {
            if (root.secondsLeft > 1) {
                root.secondsLeft--;
            } else {
                root.confirm();
            }
        }
    }

    FocusScope {
        id: backdrop
        anchors.fill: parent
        focus: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.cancel()
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.cancel();
                event.accepted = true;
            }
        }
    }

    Item {
        id: card

        readonly property int radius: 18
        readonly property int pad: 18

        width: root.cardWidth
        height: root.cardHeight
        x: root.cardX
        y: root.cardY

        //  Shadow mask
        Item {
            id: mask
            anchors.fill: card
            visible: false
            layer.enabled: true
            Rectangle {
                anchors.fill: parent
                anchors.margins: 12
                radius: card.radius
                color: "#fff"
            }
        }

        //  Shadow ─
        RectangularShadow {
            id: outerShadow
            anchors.fill: card
            radius: 30
            blur: 16
            color: v.shadowColor
            spread: -12
            visible: false
        }
        MultiEffect {
            anchors.fill: outerShadow
            source: outerShadow
            maskSource: mask
            maskEnabled: true
            maskInverted: true
        }

        //  Visible card background, blurred by the compositor
        Rectangle {
            id: cardBg
            anchors.fill: parent
            anchors.margins: 12
            radius: card.radius
            color: v.popupBackground
            border.color: v.popupBorder
            border.width: 1

            // Swallows clicks so they don't reach the backdrop's cancel.
            MouseArea {
                anchors.fill: parent
            }
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: 11
            radius: card.radius
            color: "transparent"
            border.color: v.outerBorderColor
            border.width: 1
        }

        //  Content
        ColumnLayout {
            id: cardLayout
            anchors {
                fill: cardBg
                margins: card.pad
            }
            spacing: 0

            // Power glyph, ringed like the system sheet's icon.
            Rectangle {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                Layout.bottomMargin: 18
                radius: width / 2
                color: v.widgetHighlight

                Canvas {
                    anchors.centerIn: parent
                    width: 36
                    height: 36

                    onPaint: {
                        const ctx = getContext("2d");
                        // Canvas is reused across paints; clear rather than
                        // relying on a reset() that Qt's Context2D lacks.
                        ctx.clearRect(0, 0, width, height);
                        ctx.strokeStyle = v.textColor;
                        ctx.lineWidth = 2.4;
                        ctx.lineCap = "round";

                        // Ring with a notch at the top, then the stem.
                        ctx.beginPath();
                        ctx.arc(width / 2, height / 2 + 1, 13, -Math.PI / 2 + 0.55,
                                Math.PI * 3 / 2 - 0.55, false);
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.moveTo(width / 2, 3);
                        ctx.lineTo(width / 2, 16);
                        ctx.stroke();
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.bottomMargin: 10
                text: root.rebooting
                      ? qsTr("Are you sure you want to restart your computer now?")
                      : qsTr("Are you sure you want to shut down your computer now?")
                color: v.textColor
                font.family: "SF Pro"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                Layout.bottomMargin: 18
                text: qsTr("If you do nothing, the computer will %1 automatically in %2 seconds.")
                          .arg(root.rebooting ? qsTr("restart") : qsTr("shut down"))
                          .arg(root.secondsLeft)
                color: v.textColor
                font.family: "SF Pro"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                DialogButton {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    onInvoked: root.cancel()
                }
                DialogButton {
                    Layout.fillWidth: true
                    accent: true
                    text: root.rebooting ? qsTr("Restart") : qsTr("Shut Down")
                    onInvoked: root.confirm()
                }
            }
        }
    }
}
