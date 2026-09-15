import QtQuick
import ".."

// Region selection: a dim layer with the selection cut out of it, an outline
// around the selection, and a live size readout.
//
// The selection follows the pointer exactly, with no smoothing, so the
// rectangle sits under the cursor rather than trailing it.
Item {
    id: root

    Variables { id: v }

    // ── Theme ───────────────────────────────────────────────
    // `dimOpacity` is folded into `dimColor`, and `borderRadius` went away with
    // the shader, which was its only consumer.
    property real outlineThickness: 1

    // ── Input ───────────────────────────────────────
    // Not named `enabled`, which would shadow Item.enabled.
    property bool inputEnabled: true
    property point startPos
    // Pointer position, seeded from `hyprctl cursorpos` when the overlay shows.
    property real mouseX: 0
    property real mouseY: 0
    property bool canceled: false
    property bool selecting: false

    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

    readonly property real dragThreshold: 5

    signal regionSelected(real x, real y, real width, real height)
    signal pointerPressed

    function clearSelection() {
        root.selecting = false;
        root.canceled = false;
        root.selectionX = 0;
        root.selectionY = 0;
        root.selectionWidth = 0;
        root.selectionHeight = 0;
    }

    function updateMouse(x, y) {
        root.mouseX = x;
        root.mouseY = y;
    }

    // ── Dimming ─────────────────────────────────────
    property color dimColor: v.shadowColor

    readonly property real bandTop: Math.max(0, root.selectionY)
    readonly property real bandHeight: Math.min(root.selectionHeight, Math.max(0, root.height - root.selectionY))

    Rectangle {
        x: 0
        y: 0
        width: root.width
        height: Math.max(0, root.selectionY)
        color: root.dimColor
        z: 0
    }
    Rectangle {
        x: 0
        y: Math.max(0, root.selectionY + root.selectionHeight)
        width: root.width
        height: Math.max(0, root.height - (root.selectionY + root.selectionHeight))
        color: root.dimColor
        z: 0
    }
    Rectangle {
        x: 0
        y: root.bandTop
        width: Math.max(0, root.selectionX)
        height: root.bandHeight
        color: root.dimColor
        z: 1
    }
    Rectangle {
        x: Math.max(0, root.selectionX + root.selectionWidth)
        y: root.bandTop
        width: Math.max(0, root.width - (root.selectionX + root.selectionWidth))
        height: root.bandHeight
        color: root.dimColor
        z: 1
    }

    Rectangle {
        x: root.selectionX
        y: root.selectionY
        width: root.selectionWidth
        height: root.selectionHeight
        visible: root.selecting && root.selectionWidth > 0 && root.selectionHeight > 0
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.85)
        border.width: root.outlineThickness
        z: 2
    }

    // ── Pointer input ───────────────────────────────────────
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        z: 3
        enabled: root.inputEnabled
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.CrossCursor

        // Keeps the aiming crosshair under the pointer as soon as the cursor
        // crosses onto the overlay, before any button is pressed.
        onEntered: root.updateMouse(mouseArea.mouseX, mouseArea.mouseY)

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.canceled = true;
                root.clearSelection();
                return;
            }
            root.canceled = false;
            root.selecting = true;
            root.startPos = Qt.point(mouse.x, mouse.y);
            root.updateMouse(mouse.x, mouse.y);
            root.selectionX = mouse.x;
            root.selectionY = mouse.y;
            root.selectionWidth = 0;
            root.selectionHeight = 0;
            root.pointerPressed();
        }

        onPositionChanged: mouse => {
            root.updateMouse(mouse.x, mouse.y);
            if (root.selecting && !root.canceled && (mouse.buttons & Qt.LeftButton)) {
                root.selectionX = Math.min(root.startPos.x, mouse.x);
                root.selectionY = Math.min(root.startPos.y, mouse.y);
                root.selectionWidth = Math.abs(mouse.x - root.startPos.x);
                root.selectionHeight = Math.abs(mouse.y - root.startPos.y);
            }
        }

        onReleased: mouse => {
            if (mouse.button === Qt.RightButton || root.canceled) {
                root.canceled = false;
                root.clearSelection();
                return;
            }
            if (!root.selecting)
                return;
            root.selecting = false;
            // No drag worth speaking of: fall back to the whole screen.
            if (root.selectionWidth < root.dragThreshold && root.selectionHeight < root.dragThreshold) {
                root.clearSelection();
                root.regionSelected(0, 0, root.width, root.height);
            } else {
                root.regionSelected(Math.round(root.selectionX), Math.round(root.selectionY), Math.round(root.selectionWidth), Math.round(root.selectionHeight));
            }
        }
    }

    // ── Size readout ────────────────────────────────────────────────
    Rectangle {
        id: dimLabel

        visible: root.selecting && root.selectionWidth > 20
        z: 4
        x: root.selectionX + root.selectionWidth / 2 - width / 2
        y: root.selectionY < 40 ? root.selectionY + 10 : root.selectionY - 35
        width: labelText.implicitWidth + 16
        height: labelText.implicitHeight + 8
        radius: 6
        color: v.popupBackground
        border.color: v.popupBorder
        border.width: 1

        Text {
            id: labelText

            anchors.centerIn: parent
            text: `${Math.round(root.selectionWidth)} × ${Math.round(root.selectionHeight)}`
            color: v.textColor
            font.pixelSize: 12
        }
    }
}
