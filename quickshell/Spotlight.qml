import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

Scope {
    id: root

    // ── Whether spotlight is open (shared across all screen variants) ─
    property bool open: false

    // ── Global shortcut ───────────────────────────────────────────────
    // Bind in hyprland.conf:
    //   bind = SUPER, Space, global, quickshell:Spotlight
    GlobalShortcut {
        name: "Spotlight"
        description: "Toggle Spotlight search"
        onPressed: {
            root.open = !root.open;
        }
    }

    Variants {
        id: variants
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

            function forceSearchFocus() {
                searchInput.forceActiveFocus();
            }

            Variables { id: v }

            // ── Focus grab for click-outside-to-dismiss ────────────────
            HyprlandFocusGrab {
                id: focusGrab
                windows: [panelWindow]
                active: panelWindow.visible
                onCleared: {
                    root.open = false;
                }
            }

            // ── Reset state when opened ────────────────────────────────
            onVisibleChanged: {
                if (visible) {
                    searchInput.text = "";
                    searchInput.forceActiveFocus();
                    resultsList.currentIndex = 0;
                }
            }

            // ── Dimming background ────────────────────────────────────
            Rectangle {
                anchors.fill: parent
                color: 'transparent'

                TapHandler {
                    onTapped: root.open = false
                }
            }

            // ── Search card (transparent container for shadow) ────────
            Rectangle {
                id: card
                property real contentWidth: Math.min(640, parent.width - 80)
                property real contentHeight: Math.min(cardLayout.implicitHeight + 16, parent.height - 160)

                width: contentWidth + 24
                height: contentHeight + 24
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: parent.height * 0.35
                }
                radius: 16
                color: "transparent"

                // ── Shadow mask ────────────────────────────────────────
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

                // ── Shadow ─────────────────────────────────────────────
                RectangularShadow {
                    id: outerShadow
                    anchors.fill: card
                    radius: card.radius
                    blur: 12
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

                // ── Visible card background ────────────────────────────
                Rectangle {
                    id: cardBg
                    anchors.fill: parent
                    anchors.margins: 12
                    radius: card.radius
                    color: v.popupBackground
                    border.color: v.popupBorder
                    border.width: 1
                }
                Rectangle {
                    id: cardOuterBorder
                    anchors.fill: parent
                    anchors.margins: 11
                    radius: card.radius
                    color: 'transparent'
                    border.color: v.outerBorderColor
                    border.width: 1
                }


                // ── Card content ───────────────────────────────────────
                ColumnLayout {
                    id: cardLayout
                    anchors {
                        fill: cardBg
                        margins: 10
                    }
                    spacing: 6

                    // ── Search bar ────────────────────────────────────
                    Rectangle {
                        id: searchBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.06)

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 12
                                rightMargin: 12
                            }
                            spacing: 10

                            // Magnifying glass icon
                            //Text {
                            //    text: "\uD83D\uDD0D"  // 🔍
                            //    font.pixelSize: 16
                            //    Layout.alignment: Qt.AlignVCenter
                            //}

                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: v.textColor
                                font.pixelSize: 16
                                verticalAlignment: TextInput.AlignVCenter
                                activeFocusOnPress: true

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Search applications…"
                                    color: v.textPlaceholder
                                    font: searchInput.font
                                    visible: !searchInput.text && !searchInput.activeFocus
                                }

                                onTextChanged: {
                                    applyFilter();
                                    resultsList.currentIndex = 0;
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        root.open = false;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        launchCurrent();
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down) {
                                        if (resultsList.count > 0) {
                                            resultsList.incrementCurrentIndex();
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        if (resultsList.currentIndex > 0) {
                                            resultsList.decrementCurrentIndex();
                                        }
                                        event.accepted = true;
                                    }
                                }
                            }
                        }
                    }

                    // ── Results list ──────────────────────────────────
                    ListView {
                        id: resultsList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: Math.min(count * 44, 396)
                        clip: true
                        spacing: 2
                        model: filteredModel
                        keyNavigationEnabled: false
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: ItemDelegate {
                            id: delegateItem
                            width: resultsList.width
                            height: 44
                            highlighted: index === resultsList.currentIndex

                            required property int index
                            required property var modelData

                            background: Rectangle {
                                radius: 6
                                color: delegateItem.highlighted
                                    ? v.widgetHighlight
                                    : "transparent"
                            }

                            contentItem: RowLayout {
                                spacing: 10

                                Image {
                                    source: {
                                        var path = Quickshell.iconPath(modelData.icon, true);
                                        return path ? path : Quickshell.iconPath("application-x-executable");
                                    }
                                    sourceSize.width: 28
                                    sourceSize.height: 28
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectFit
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: v.textColor
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.genericName || ""
                                        color: v.textSecondary
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        visible: text !== ""
                                    }
                                }
                            }

                            onClicked: {
                                modelData.execute();
                                root.open = false;
                            }
                        }
                    }
                }
            }

            // ── Filtered model ────────────────────────────────────────
            ScriptModel {
                id: filteredModel

                function filter(text) {
                    if (!text || text.trim() === "") {
                        return [...DesktopEntries.applications.values].sort(
                            (a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase())
                        );
                    }

                    const lower = text.toLowerCase();
                    return DesktopEntries.applications.values.filter(entry => {
                        return entry.name.toLowerCase().includes(lower)
                            || (entry.genericName && entry.genericName.toLowerCase().includes(lower))
                            || (entry.comment && entry.comment.toLowerCase().includes(lower))
                            || entry.keywords.some(kw => kw.toLowerCase().includes(lower));
                    }).sort((a, b) => {
                        const aStarts = a.name.toLowerCase().startsWith(lower);
                        const bStarts = b.name.toLowerCase().startsWith(lower);
                        if (aStarts && !bStarts) return -1;
                        if (!aStarts && bStarts) return 1;
                        return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
                    });
                }

                Component.onCompleted: {
                    applyFilter();
                }
            }

            function applyFilter() {
                filteredModel.values = filteredModel.filter(searchInput.text);
            }

            function launchCurrent() {
                var idx = resultsList.currentIndex;
                if (idx >= 0 && idx < filteredModel.values.length) {
                    filteredModel.values[idx].execute();
                    root.open = false;
                }
            }
        }
    }
}
