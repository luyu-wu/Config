import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "ai"

Scope {
    id: root

    property bool open: false
    property bool sidebarVisible: false

    onSidebarVisibleChanged: {
        if (root.sidebarVisible)
            Goose.ensureConnected();
    }

    GlobalShortcut {
        name: "Intelligence"
        description: "Toggle AI Panel"
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
            WlrLayershell.namespace: "qs:ai"

            anchors {
                top: true
                left: true
                bottom: true
            }

            color: "transparent"
            focusable: true
            implicitWidth: 440
            // Only visible when the panel is open on the focused monitor
            visible: root.open && isFocusedScreen()

            function isFocusedScreen() {
                var fm = Hyprland.focusedMonitor;
                if (!fm) return false;
                var sm = Hyprland.monitorFor(modelData);
                return sm && sm.name === fm.name;
            }

            Variables { id: v }

            Connections {
                target: Goose
                function onTranscriptChanged() {
                    transcriptModel.clear();
                    for (const message of Goose.messages)
                        transcriptModel.append({
                            role: message.role,
                            text: message.text,
                            toolName: message.toolName,
                            status: message.status
                        });
                    if (Goose.liveText)
                        transcriptModel.append({
                            role: "assistant",
                            text: Goose.liveText,
                            toolName: "",
                            status: ""
                        });
                }

                function onSessionsUpdated() {
                    sessionModel.clear();
                    for (const session of Goose.sessions)
                        sessionModel.append({
                            sessionId: session.sessionId,
                            title: session.title || "",
                            updatedAt: session.updatedAt || ""
                        });
                }
            }

            Rectangle {
                id: card
                anchors.fill: parent
                radius: 16
                color: "transparent"
                implicitHeight: parent.height
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
                    blur: 12
                    color: v.shadowColor
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

                //  Visible card background
                Rectangle {
                    id: cardBg
                    anchors.fill: parent
                    anchors.margins: 16
                    radius: card.radius
                    color: v.popupBackground
                    border.color: "#fff"
                    border.width: 1

                    ClippingRectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: cardBg.radius
                        clip: true

                        NumberAnimation {
                            target: waves
                            property: "time"
                            from: 0
                            to: 3600       // 1h wrap; 3600 * 0.04 hueSpeed = 144
                            duration: 3600000
                            loops: Animation.Infinite
                            running: panelWindow.visible
                        }

                        WaveBackground {
                            id: waves
                            anchors.fill: parent
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            implicitHeight: 24
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "#00ffffff"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#60ffffff"
                                }
                            }
                            z: 8
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            implicitHeight: 128
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "#e0ffffff"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#00ffffff"
                                }
                            }
                            z: 1
                            RectangularShadow{
                                anchors.fill: windowTitle
                                blur: 6
                                radius: 18
                                color: "#60000000"
                            }
                            Rectangle {
                            	id: windowTitle
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 150
                                anchors.rightMargin: 150
                                anchors.topMargin: 16
                                implicitHeight: 36
                                border.color: "#20404040"
                                border.width: 1

                                radius: 18
                                Text {
                                    anchors.fill: parent
                                    text: "帮手"
                                    color: "#666"
                                    font.weight: 600
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                }

                            }
                        }

                        Text {
                            anchors {
                                top: parent.top
                                topMargin: 116
                                left: parent.left
                                leftMargin: 16
                                right: parent.right
                                rightMargin: 16
                            }
                            visible: text !== ""
                            text: {
                                if (Goose.status === Goose.Error)
                                    return "goose error: " + Goose.lastError;
                                if (Goose.status === Goose.Connecting)
                                    return "starting goose… (first run can take ~30s)";
                                if (Goose.busy)
                                    return "thinking…";
                                return "";
                            }
                            color: Goose.status === Goose.Error ? "#b3261e" : v.textSecondary
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            z: -1
                        }
                        ListView {
                            id: transcript

                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            topMargin: 136
                            bottomMargin: chatbox.height + 24
                            clip: true
                            spacing: 8
                            model: transcriptModel
                            property bool pinned: true
                            onMovementEnded: pinned = atYEnd
                            onCountChanged: if (pinned) Qt.callLater(transcript.positionViewAtEnd)

                            delegate: Item {
                                id: row
                                required property string role
                                required property string text
                                required property string toolName
                                required property string status
                                width: transcript.width
                                height: bubble.height

                                readonly property int sideMargin: 12

                                Column {
                                    id: bubble
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: row.sideMargin
                                    anchors.rightMargin: row.sideMargin
                                    spacing: 0

                                    readonly property bool isUser: row.role === "user"
                                    readonly property bool isTool: row.role === "tool"
                                    readonly property real innerWidth: bubble.width
                                    readonly property real maxWidth: bubble.isUser ? bubble.innerWidth * 0.85 : bubble.innerWidth

                                    Text {
                                        visible: bubble.isTool
                                        width: bubble.innerWidth
                                        text: {
                                            const name = row.toolName || row.text;
                                            const mark = row.status === "failed" ? "✕" : "✓";
                                            return mark + "  " + name;
                                        }
                                        color: row.status === "failed" ? "#b3261e" : v.textPlaceholder
                                        font.pixelSize: 12
                                        font.italic: true
                                        elide: Text.ElideRight
                                    }

                                    Rectangle {
                                        id: bubbleRect
                                        visible: !bubble.isTool
                                        x: bubble.isUser ? bubble.innerWidth - width : 0
                                        width: bubble.isUser ? Math.min(bubbleText.implicitWidth + 20, bubble.maxWidth) : bubble.maxWidth
                                        height: bubbleText.implicitHeight + 16
                                        radius: 12
                                        color: bubble.isUser ? v.accentColor : "#60ffffff"
                                        border.width: 1
                                        border.color: bubble.isUser ? v.accentColor : "#d0ffffff"
                                        Text {
                                            id: bubbleText
                                            anchors.centerIn: parent
                                            width: bubbleRect.width - 20
                                            text: row.text
                                            textFormat: bubble.isUser ? Text.PlainText : Text.MarkdownText
                                            wrapMode: Text.Wrap
                                            font.pixelSize: 14
                                            color: bubble.isUser ? v.accentForeground : v.textColor
                                        }
                                    }
                                }
                            }

                            ListModel { id: transcriptModel }
                        }

                        ListModel { id: sessionModel }

                        ClippingRectangle{
                        	id: chatbox
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 12
                            color: "#70ffffff"
                            border.width: 1
                            border.color: "#d0ffffff"

                            radius: 16
                            implicitHeight: 64
                            clip: true
                            z: 5
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                hoverEnabled: true
                                cursorShape: Qt.IBeamCursor
                            }

                            TextInput {
                                id: searchInput
                                anchors.fill: parent
                                autoScroll: true
                                padding: 14
                                color: "#333" //v.textColor
                                font.bold: false
                                font.pixelSize: 16
                                activeFocusOnPress: true
                                wrapMode: TextInput.Wrap
                                onAccepted: {
                                    if (Goose.send(searchInput.text))
                                        searchInput.text = "";
                                }
                                Keys.onEscapePressed: Goose.cancel()
                            }
                            RectangularShadow {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                implicitHeight: 1
                                color: "#fff"
                            }
                            RectangularShadow {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                implicitHeight: 1
                                color: "#80ffffff"
                            }
                        }
                        Rectangle{
                            id: sidebar
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: sidebarVisible ? 0 : -300
                            implicitHeight: parent.height
                            implicitWidth: 300
                            radius: 24
                            color: "#eee"
                            // Above the transcript *and* the input box: the
                            // sidebar slides over the whole panel.
                            z: 7
                            Behavior on anchors.leftMargin {
                                NumberAnimation {
                                    duration: 140
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 56
                                spacing: 6

                                Row {
                                    width: parent.width
                                    height: 30
                                    spacing: 6

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        text: "History"
                                        color: v.textHeader
                                        font.pixelSize: 13
                                        font.weight: 600
                                    }
                                }

                                ListView {
                                    width: parent.width
                                    height: parent.height - 42
                                    clip: true
                                    spacing: 2
                                    model: sessionModel

                                    Text {
                                        anchors.centerIn: parent
                                        visible: sessionModel.count === 0
                                        text: Goose.sessionsLoading ? "Loading…" : "No past sessions"
                                        color: v.textPlaceholder
                                        font.pixelSize: 12
                                    }

                                    delegate: Rectangle {
                                        id: entry
                                        required property string sessionId
                                        required property string title
                                        required property string updatedAt
                                        width: ListView.view.width
                                        height: 48
                                        radius: 8
                                        // Hover matches share/menu/IconItem, the
                                        // component the network list in
                                        // NetworkPopup uses: a neutral wash.
                                        // The open chat stays filled with the
                                        // accent, so it is always distinguishable
                                        // from a merely hovered row.
                                        readonly property bool selected: sessionId === Goose.sessionId
                                        color: selected ? v.accentColor : (hover.containsMouse ? v.widgetHighlight : "transparent")

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 2

                                            Text {
                                                width: parent.width
                                                text: entry.title || entry.sessionId
                                                // On the accent fill the normal text
                                                // colours are too dark to read, so
                                                // the on-accent foreground is used.
                                                color: entry.selected ? v.accentForeground : v.textColor
                                                font.pixelSize: 13
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                width: parent.width
                                                // Stored as ISO 8601; only the
                                                // date and time are useful at
                                                // a glance.
                                                text: (entry.updatedAt || "").replace("T", " ").substring(0, 16)
                                                color: entry.selected ? v.accentForeground : v.textPlaceholder
                                                opacity: entry.selected ? 0.8 : 1
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                            }
                                        }

                                        MouseArea {
                                            id: hover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Goose.openSession(entry.sessionId);
                                                root.sidebarVisible = false;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        RectangularShadow{
                            anchors.fill: sidebar
                            color: "#60000000"
                            blur: 12
                            radius: 24
                            z: 6
                            visible: root.sidebarVisible
                        }
                        RectangularShadow {
                            anchors.fill: showSidebar
                            blur: 6
                            radius: 18
                        }
                        RectangularShadow {
                            anchors.fill: newSessionButton
                            blur: 6
                            radius: 18
                        }

                        Rectangle{
                            id: newSessionButton
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 16
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: 18
                            color: newSessionHover.hovered ? "#e0e6ee" : "#f0f3f5"
                            border.color: "#20404040"
                            border.width: 1
                            z: 8

                            MouseArea {
                                id: newSessionHover
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    Goose.newSession();
                                    root.sidebarVisible = false;
                                }
                            }

                            Item {
                                anchors.centerIn: parent
                                implicitWidth: 16
                                implicitHeight: 16
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 3
                                    radius: 2
                                    color: "#888"
                                }
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 3
                                    height: 16
                                    radius: 2
                                    color: "#888"
                                }
                            }
                        }

                        Rectangle{
                            id: showSidebar
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 16
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: 18
                            color: root.sidebarVisible ? v.accentColor : "#f0f3f5"
                            border.color: "#20404040"
                            border.width: 1
                            z: 8
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    root.sidebarVisible = !root.sidebarVisible

                                }
                            }
                            Item {
                                anchors.centerIn: parent
                                implicitWidth: 18
                                implicitHeight: 14
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    width: 16
                                    height: 3
                                    radius: 2
                                    color: root.sidebarVisible ? "#ffffff" : "#888"
                                }
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 16
                                    height: 3
                                    radius: 2
                                    color: root.sidebarVisible ? "#ffffff" : "#888"
                                }
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    width: 16
                                    height: 3
                                    radius: 2
                                    color: root.sidebarVisible ? "#ffffff" : "#888"
                                }
                            }
                        }

                    }

                }
                Rectangle {
                    id: cardOuterBorder
                    anchors.fill: parent
                    anchors.margins: 15
                    radius: card.radius
                    color: 'transparent'
                    border.color: v.outerBorderColor
                    border.width: 1
                }
            }
        }
    }
}
