pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "."

// Desktop notification daemon, replacing swaync.
//
// Owns the org.freedesktop.Notifications D-Bus service and feeds the toasts in
// NotificationPopups.qml. Notifications are never stored: each one is tracked
// only for as long as its toast is on screen, then it is expired and dropped.
//
// Driven from Hyprland by `quickshell ipc call notifications <function>`.
Singleton {
    id: root

    // ── Configuration ───────────────────────────────────────────────
    // Auto-dismiss fallbacks in milliseconds, mirroring the values swaync used
    // (its timeout / timeout-low / timeout-critical, in seconds).
    readonly property int timeoutNormal: 8000
    readonly property int timeoutLow: 6000
    readonly property int timeoutCritical: 20000

    // Never let a client keep a toast on screen for longer than a minute.
    readonly property int maxTimeout: 60000

    // ── Do Not Disturb ──────────────────────────────────────────────
    // While set, incoming notifications are discarded instead of displayed.
    property bool dnd: false

    // Notifications currently on screen. The server appends new entries, so the
    // list runs oldest-first; NotificationPopups.qml stacks them newest-first.
    readonly property var trackedNotifications: server.trackedNotifications

    NotificationServer {
        id: server

        // Nothing survives a reload, and nothing is kept once its toast closes.
        keepOnReload: false
        persistenceSupported: false

        // Capabilities advertised to client applications.
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true

        onNotification: (notification) => {
            // On Do Not Disturb, leave the notification untracked so the server
            // discards it immediately rather than keeping it in the model.
            notification.tracked = !root.dnd;
        }
    }

    // ── Toast lifetime ──────────────────────────────────────────────
    // Quickshell passes the client's D-Bus expire_timeout through unchanged, so
    // a positive value is a request in milliseconds. Zero means "never expire";
    // a negative value means "use the server default".
    function timeoutFor(notification) {
        const requested = notification.expireTimeout;
        if (requested > 0)
            return Math.min(Math.round(requested), root.maxTimeout);

        if (notification.urgency === NotificationUrgency.Low)
            return root.timeoutLow;
        if (notification.urgency === NotificationUrgency.Critical)
            return root.timeoutCritical;
        return root.timeoutNormal;
    }

    function isPersistent(notification) {
        return notification.expireTimeout === 0;
    }

    // Dismiss every notification currently on screen.
    function clear() {
        for (const notification of server.trackedNotifications.values)
            notification.dismiss();
    }

    // ── IPC ─────────────────────────────────────────────────────────
    //   quickshell ipc call notifications toggleDnd
    IpcHandler {
        target: "notifications"

        function toggleDnd(): void {
            root.dnd = !root.dnd;
        }

        function enableDnd(): void {
            root.dnd = true;
        }

        function disableDnd(): void {
            root.dnd = false;
        }

        function clear(): void {
            root.clear();
        }
    }
}
