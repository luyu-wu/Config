import QtQuick

QtObject {
    // ── Theme mode ──────────────────────────────────────────────────
    // Toggle this to switch between light and dark palettes.
    readonly property bool darkMode: false

    // ── Shared text colors ──────────────────────────────────────────
    //
    // Primary text color used across all labels and text elements
    readonly property color textColor: darkMode ? "#E0E0E0" : "#202020"

    // Secondary / muted text
    readonly property color textSecondary: darkMode ? "#B0B0B0" : "#666666"

    // Section header text (semi-transparent)
    readonly property color textHeader: darkMode ? "#90FFFFFF" : "#90000000"

    // Placeholder / disabled text
    readonly property color textPlaceholder: darkMode ? "#909090" : "#70000000"

    // ── Shared popup colors ─────────────────────────────────────────
    // Popup dropdown / card background
    readonly property color popupBackground: darkMode ? "#80303030" : "#b1e4e7ef"

    // Popup dropdown / card border
    readonly property color popupBorder: darkMode ? "#C0909090" : "#A0A0A0"

    // ── Menu colors ─────────────────────────────────────────────────
    // Menu divider / separator line
    readonly property color menuDividerColor: darkMode ? "#33ffffff" : "#33000000"

    // ── Widget highlight ───────────────────────────────────────────
    // Active/pressed/hovered widget background overlay
    readonly property color widgetHighlight: darkMode ? "#20ffffff" : "#20000000"

    // ── Accent ─────────────────────────────────────────────────────
    // Active/selected accent fill (toggles, selected items, highlights)
    readonly property color accentColor: "#1071db"

    // Muted/track fill for inactive toggles
    readonly property color accentMuted: "#afb0b5"

    // Foreground (knob/icon) drawn on top of accent fills
    readonly property color accentForeground: "#ffffff"

    // ── Shadow & outer border ───────────────────────────────────────
    // Drop shadow color
    readonly property color shadowColor: "#70000000"

    // Outer contour border (1px outside card fill)
    readonly property color outerBorderColor: darkMode ? "#90303030" : "transparent"


    // ── Bar colors ──────────────────────────────────────────────────
    // Top bar background
    readonly property color barBackground: darkMode ? "#8034373f" : "#b1e4e7ef"
    // Bottom bar borderc
    readonly property color barBorder: darkMode ? "#60606060" : "#a0a0a0"

}
