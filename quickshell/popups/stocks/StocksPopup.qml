import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../.."

PanelWindow {
    Variables { id: v }
    id: root

    implicitWidth: 360
    implicitHeight: contentColumn.implicitHeight + 64
    exclusionMode: "Ignore"
    WlrLayershell.namespace: "qs:popup"
    anchors {
        top: true
        left: true
    }
    margins.top: 32
    margins.left: popupX
    updatesEnabled: false
    color: "transparent"

    property real popupX: stocksLabel.mapToItem(null, 0, 0).x + stocksLabel.width / 2 - width / 2
    property var quotes: []
    property bool loading: false
    property date lastUpdated: new Date(0)
    property color gainColor: "#4CD964"
    property color lossColor: "#FF453A"

    signal refreshRequested

    Connections {
        target: stocksLabel
        function onWidthChanged() {
            repositionTimer.restart();
        }
    }
    Timer {
        id: repositionTimer
        interval: 1
        repeat: false
        onTriggered: {
            root.popupX = stocksLabel.mapToItem(null, 0, 0).x + stocksLabel.width / 2 - root.width / 2;
        }
    }

    // ── card (shadow + border, same recipe as the other popups) ─────
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: "transparent"

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
            blur: 16
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

        Rectangle {
            anchors.fill: parent
            anchors.margins: 16
            radius: parent.radius
            color: v.popupBackground
            border.color: v.popupBorder
            border.width: 1
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: 15
            radius: card.radius
            color: "transparent"
            border.color: v.outerBorderColor
            border.width: 1
        }

        // ── contents ───────────────────────────────────────────────
        ColumnLayout {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 28
            }
            spacing: 0

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                spacing: 4

                Text {
                    text: "Stocks"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: palette.windowText
                }
                Item {
                    Layout.fillWidth: true
                }
                Item {
                    implicitWidth: 24
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        font.pixelSize: 15
                        color: refreshMouse.containsMouse ? palette.windowText : v.textSecondary
                    }
                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refreshRequested()
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 8
                Layout.bottomMargin: 2
                color: v.widgetHighlight
            }

            // Quote rows
            Repeater {
                model: root.quotes
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    property var quote: modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 8
                    color: rowMouse.containsMouse ? v.widgetHighlight : "transparent"

                    readonly property bool up: (row.quote.change ?? 0) >= 0
                    readonly property color rowColor: row.up ? root.gainColor : root.lossColor

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        ColumnLayout {
                            Layout.preferredWidth: 118
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: row.quote.symbol ?? "—"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: palette.windowText
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: row.quote.name ?? ""
                                font.pixelSize: 11
                                color: v.textSecondary
                                elide: Text.ElideRight
                            }
                        }

                        Shape {
                            id: sparkShape
                            Layout.preferredWidth: 66
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignVCenter
                            visible: (row.quote.sparkline?.length ?? 0) >= 2
                            preferredRendererType: Shape.CurveRenderer

                            ShapePath {
                                strokeColor: row.rowColor
                                strokeWidth: 1.5
                                fillColor: "transparent"
                                startX: 0
                                startY: 0

                                PathPolyline {
                                    path: root.sparkPoints(row.quote.sparkline, sparkShape.Layout.preferredWidth, sparkShape.Layout.preferredHeight)
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: row.quote.price != null ? row.quote.price.toFixed(2) : "—"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: row.rowColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: (row.quote.change != null && row.quote.changePercent != null)
                                    ? (row.up ? "+" : "−") + Math.abs(row.quote.change).toFixed(2)
                                      + "  (" + (row.up ? "+" : "−") + Math.abs(row.quote.changePercent).toFixed(2) + "%)"
                                    : ""
                                font.pixelSize: 11
                                color: row.rowColor
                            }
                        }
                    }
                }
            }

            // Footer / status
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Text {
                    anchors.centerIn: parent
                    text: root.statusText
                    font.pixelSize: 10
                    color: v.textPlaceholder
                }
            }
        }
    }

    readonly property string statusText: {
        if (root.loading && root.quotes.length === 0)
            return "Loading…";
        if (root.quotes.length === 0)
            return "Failed to load quotes";
        return "Updated " + Qt.formatTime(root.lastUpdated, "hh:mm AP");
    }

    function sparkPoints(closes, w, h) {
        if (!closes || closes.length < 2)
            return [];
        let min = Infinity, max = -Infinity;
        for (let i = 0; i < closes.length; i++) {
            if (closes[i] < min) min = closes[i];
            if (closes[i] > max) max = closes[i];
        }
        const range = max - min || 1;
        const n = closes.length - 1;
        const pts = [];
        for (let i = 0; i < closes.length; i++) {
            pts.push(Qt.point(i * w / n, h - (closes[i] - min) / range * h));
        }
        return pts;
    }
}
