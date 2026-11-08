import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "share/spotlight"

Scope {
    id: root

    property bool open: false
    property bool showCard: false
    property int currentIndex: 0
    property int blurTransitionTime: 500
    readonly property int maxResults: 5

    Timer {
        id: revealTimer
        interval: blurTransitionTime + 10
        onTriggered: root.showCard = true
    }

    //  Show the real card immediately, skipping the blur transition. Typing
    //  should not be queued behind the expensive blur rasterization.
    function revealNow() {
        revealTimer.stop();
        root.showCard = true;
    }
    GlobalShortcut {
        name: "Spotlight"
        description: "Toggle Spotlight search"
        onPressed: {
            root.open = !root.open;
            if (root.open) {
                root.showCard = false;
                revealTimer.restart();
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow
            required property var modelData

            screen: modelData
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs:spotlight"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            color: "transparent"

            // Only visible when spotlight is open AND this is the focused monitor
            visible: root.open && isFocusedScreen()

            function isFocusedScreen() {
                var fm = Hyprland.focusedMonitor;
                if (!fm) return false;
                var sm = Hyprland.monitorFor(modelData);
                return sm && sm.name === fm.name;
            }

            //  First root.maxResults matches, plus the full match count for sizing.
            readonly property var shown: results.slice(0, root.maxResults)

            Variables { id: v }

            //  Focus grab for click-outside-to-dismiss
            HyprlandFocusGrab {
                windows: [panelWindow]
                active: panelWindow.visible
                onCleared: root.open = false
            }

            //  Reset state when opened
            onVisibleChanged: {
                if (visible) {
                    searchInput.text = "";
                    searchInput.forceActiveFocus();
                    applyFilter();
                }
            }

            MultiEffect {
                id: searchPanelBlur
                anchors.fill: card
                visible: !root.showCard
                source: card
                blurEnabled: true
                blurMax: 64
                opacity: root.open ? 1.0 : 0.0
                blur: root.open ? 0.0 : 1.0
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
                visible: root.showCard

                width: Math.min(640, parent.width - 80) + 24
                height: Math.min(cardLayout.implicitHeight + 16, parent.height - 160) + 24
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: parent.height * 0.35
                }
                radius: 24
                color: "transparent"

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

                //  Visible card background
                ClippingRectangle {
                    id: cardBg
                    anchors.fill: parent
                    anchors.margins: 12
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
                    anchors.margins: 11
                    radius: card.radius
                    color: 'transparent'
                    border.color: v.outerBorderColor
                    border.width: 1
                }

                ColumnLayout {
                    id: cardLayout
                    anchors {
                        top: cardBg.top
                        left: cardBg.left
                        right: cardBg.right
                        margins: 10
                    }
                    spacing: 6

                    //  Search bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        radius: 10
                        color: 'transparent'

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 6
                                rightMargin: 12
                                bottomMargin: 6
                            }
                            spacing: 10

                            IconImage {
                                source: "image://icon/file-search-symbolic"
                                opacity: 0.5
                                implicitSize: 30
                                Layout.alignment: Qt.AlignVCenter
                            }

                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: v.textColor
                                font.pixelSize: 28
                                verticalAlignment: TextInput.AlignVCenter
                                activeFocusOnPress: true

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Search applications…"
                                    color: v.textPlaceholder
                                    font: searchInput.font
                                    //  Shown whenever there is no query; the input is
                                    //  always focused, so focus must not hide it.
                                    visible: searchInput.text === ""
                                }

                                onTextChanged: {
                                    root.revealNow();
                                    applyFilter();
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        root.open = false;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        launchCurrent();
                                    } else if (event.key === Qt.Key_Down) {
                                        if (root.currentIndex < shown.length - 1)
                                            root.currentIndex++;
                                    } else if (event.key === Qt.Key_Up) {
                                        if (root.currentIndex > 0)
                                            root.currentIndex--;
                                    } else {
                                        return;
                                    }
                                    event.accepted = true;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: shown.length > 0 ? shown.length * 46 - 2 : 0
                        spacing: 2
                        visible: shown.length > 0

                        Repeater {
                            model: shown

                            delegate: SpotlightResult {
                                required property int index
                                required property var modelData

                                entry: modelData
                                selected: index === root.currentIndex
                                onActivated: {
                                    modelData.execute();
                                    root.open = false;
                                }
                            }
                        }
                    }
                }
            }

            property var results: []

            function applyFilter() {
                const query = searchInput.text.trim().toLowerCase();
                const entries = DesktopEntries.applications.values;

                //  Nothing typed, nothing listed.
                results = query === "" ? [] : entries.filter(entry =>
                    entry.name.toLowerCase().includes(query)
                    || (entry.genericName || "").toLowerCase().includes(query)
                    || (entry.comment || "").toLowerCase().includes(query)
                    || (entry.keywords || []).some(kw => kw.toLowerCase().includes(query))
                ).sort((a, b) => {
                    //  Prefix matches first, then alphabetical.
                    const aName = a.name.toLowerCase();
                    const bName = b.name.toLowerCase();
                    const aStarts = aName.startsWith(query);
                    const bStarts = bName.startsWith(query);
                    if (aStarts !== bStarts) return aStarts ? -1 : 1;
                    return aName.localeCompare(bName);
                });

                root.currentIndex = 0;
            }

            function launchCurrent() {
                const entry = results[root.currentIndex];
                if (entry) {
                    entry.execute();
                    root.open = false;
                }
            }
        }
    }
}
