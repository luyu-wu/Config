import QtQuick

QtObject {
    // ── Shared text colors ──────────────────────────────────────────
    //
    // Primary text color used across all labels and text elements
    //readonly property color textColor: "#202020"
    readonly property color textColor: "#E0E0E0"

    // Secondary / muted text
    //readonly property color textSecondary: "#666666"
    readonly property color textSecondary: "#B0B0B0"

    // Section header text (semi-transparent)
    //readonly property color textHeader: "#90000000"
    readonly property color textHeader: "#90FFFFFF"

    // Placeholder / disabled text
    //readonly property color textPlaceholder: "#70000000"
    readonly property color textPlaceholder: "#909090"

    // ── Shared popup colors ─────────────────────────────────────────
    // Popup dropdown / card background
    //readonly property color popupBackground: "#b1e4e7ef"
    readonly property color popupBackground: "#80303030"

    // Popup dropdown / card border
    //readonly property color popupBorder: "#A0A0A0"
    readonly property color popupBorder: "#C0909090"

    // ── Menu colors ─────────────────────────────────────────────────
    // Menu divider / separator line
    //readonly property color menuDividerColor: "#33000000"
    readonly property color menuDividerColor: "#33ffffff"

    // ── Widget highlight ───────────────────────────────────────────
    // Active/pressed/hovered widget background overlay
    //readonly property color widgetHighlight: "#20000000"
    readonly property color widgetHighlight: "#20ffffff"

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
    readonly property color outerBorderColor: "#90303030"


    // ── Bar colors ──────────────────────────────────────────────────
    // Top bar background
    readonly property color barBackground: "#8034373f"

    // Bottom bar border
    //readonly property color barBorder: "#a0a0a0"
    readonly property color barBorder: "#60606060"

}
