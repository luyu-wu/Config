import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".."
import "."

// A single notification toast. It owns its entry/exit animations and the timer
// that expires the notification, and defers removal from the server's model
// until its exit animation has played; Notifications.qml owns the daemon and
// lifetime policy, NotificationPopups.qml owns where toasts appear.
Item {
    id: root
    Variables { id: v }

    required property var notification

    // True from the moment a dismissal starts until this delegate is destroyed.
    // The exit animation runs in that window; only when it finishes is the
    // notification removed from the server's model, which tears the delegate
    // down. `expireOnClose` remembers whether the removal should be reported to
    // the sending application as an expiry rather than a plain dismissal.
    property bool closing: false
    property bool expireOnClose: false

    // Margin between the popup card and the edges of the toast surface. At 0 the
    // card fills the surface.
    readonly property int popupMargin: 6
    readonly property int cardRadius: 16

    readonly property bool critical: root.notification.urgency === NotificationUrgency.Critical

    implicitWidth: 380 + root.popupMargin * 2
    implicitHeight: card.implicitHeight + root.popupMargin * 2
    width: implicitWidth
    height: implicitHeight

    // A toast on its way out no longer takes clicks or hovers.
    enabled: !root.closing

    // The stack shifts down to make room for a new toast, and up again to close
    // the gap a dismissal leaves; animate that rather than snapping.
    Behavior on y {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    // ── Entry / exit ────────────────────────────────────────────────
    // Slide in from the right when a toast is added to the stack. The surface is
    // exactly as wide as a toast, so starting one width to the right parks the
    // toast just off the right edge. `width`, not `implicitWidth`: the delegate
    // stretches the toast to the surface, so the two can disagree.
    x: root.width
    Component.onCompleted: appear.restart()
    NumberAnimation {
        id: appear
        target: root
        property: "x"
        to: 0
        duration: 220
        easing.type: Easing.OutCubic
    }

    // Dismissals slide back out the way they came in. The notification is only
    // dropped from the model once that has played out, which is what frees the
    // space the toasts below close up.
    function close(expired) {
        if (root.closing)
            return;
        root.closing = true;
        root.expireOnClose = expired === true;
        // A dismissal can land while the toast is still gliding in.
        appear.stop();
        exit.restart();
    }

    NumberAnimation {
        id: exit
        target: root
        property: "x"
        to: root.width
        duration: 200
        easing.type: Easing.InCubic
        // Dropping the notification destroys this delegate, so it is kept out of
        // the animation's own signal emission.
        onFinished: Qt.callLater(root.finishClose)
    }

    function finishClose() {
        // It may already be gone if it was closed elsewhere (the sending
        // application, or `notifications clear`).
        if (!root.notification)
            return;
        if (root.expireOnClose)
            root.notification.expire();
        else
            root.notification.dismiss();
    }

    // ── Icon ────────────────────────────────────────────────────────
    readonly property string iconSource: {
        const image = root.notification.image;
        if (image) {
            // image:// URLs (inline image data) and real paths load directly.
            if (image.startsWith("/") || image.startsWith("file:") || image.startsWith("image:"))
                return image;
            const resolvedImage = Quickshell.iconPath(image, true);
            if (resolvedImage) return resolvedImage;
        }

        const appIcon = root.notification.appIcon;
        if (appIcon) {
            if (appIcon.startsWith("/") || appIcon.startsWith("file:") || appIcon.startsWith("image:"))
                return appIcon;
            const resolvedIcon = Quickshell.iconPath(appIcon, true);
            if (resolvedIcon) return resolvedIcon;
        }

        return Quickshell.iconPath("dialog-information", true);
    }

    // ── Actions ─────────────────────────────────────────────────────
    // The "default" action is invoked by clicking the toast body, so it isn't
    // shown as a button alongside the rest.
    readonly property var defaultAction: {
        const actions = root.notification.actions;
        for (let i = 0; i < actions.length; i++)
            if (actions[i].identifier === "default") return actions[i];
        return null;
    }
    readonly property var buttonActions: root.notification.actions.filter(a => a.identifier !== "default")

    function activate() {
        if (root.defaultAction)
            root.defaultAction.invoke();
        else
            root.close(false);
    }

    // ── Auto dismiss ────────────────────────────────────────────────
    // Hovering pins the toast open until the pointer leaves.
    Timer {
        id: expiry
        interval: Notifications.timeoutFor(root.notification)
        running: !Notifications.isPersistent(root.notification) && !hover.hovered && !root.closing
        onTriggered: root.close(true)
    }

    HoverHandler {
        id: hover
    }

    // ── Card ────────────────────────────────────────────────────────
    Rectangle {
        id: card
        x: root.popupMargin
        y: root.popupMargin
        width: root.width - root.popupMargin * 2
        implicitHeight: layout.implicitHeight + 24
        height: implicitHeight
        radius: root.cardRadius
        color: v.popupBackground
        border.color: root.critical ? "#e0534f" : v.popupBorder
        border.width: root.critical ? 2 : 1

        // Outer contour border, 1px outside the card fill.
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: card.radius + 1
            color: "transparent"
            border.color: v.outerBorderColor
            border.width: 1
        }

        // Clicking the body runs the default action (or dismisses when there is
        // none). Interactive children are drawn on top and win the click.
        MouseArea {
            id: bodyArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate()

            ColumnLayout {
                id: layout
                anchors {
                    fill: parent
                    margins: 12
                }
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 12

                    Image {
                        source: root.iconSource
                        sourceSize.width: 48
                        sourceSize.height: 48
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        Layout.alignment: Qt.AlignTop
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            visible: root.notification.appName !== ""
                            text: root.notification.appName
                            color: v.textSecondary
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: root.notification.summary !== ""
                            text: root.notification.summary
                            color: v.textColor
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: root.notification.body !== ""
                            text: root.notification.body
                            color: v.textColor
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }
                    }

                    // Close button
                    Item {
                        Layout.alignment: Qt.AlignTop
                        implicitWidth: 22
                        implicitHeight: 22

                        Rectangle {
                            anchors.fill: parent
                            radius: 11
                            color: closeArea.containsMouse ? v.widgetHighlight : "transparent"
                        }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 14
                            source: "image://icon/window-close-symbolic"
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.ForbiddenCursor
                            onClicked: root.close(false)
                        }
                    }
                }

                // Action buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: root.buttonActions.length > 0

                    Repeater {
                        model: root.buttonActions

                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: 8
                            color: actionArea.pressed ? v.widgetHighlight : Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                            border.color: v.popupBorder

                            Text {
                                anchors.centerIn: parent
                                text: modelData.text || modelData.identifier
                                color: v.textColor
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                width: parent.width - 12
                                horizontalAlignment: Text.AlignHCenter
                            }

                            MouseArea {
                                id: actionArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.invoke()
                            }
                        }
                    }
                }
            }
        }
    }
}
