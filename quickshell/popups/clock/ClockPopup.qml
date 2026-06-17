import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    implicitWidth: 340
    implicitHeight: outerLayout.implicitHeight
    exclusionMode: "Ignore"
    WlrLayershell.namespace: "qs:popup"
    anchors {
        top: true
        right: true
    }
    margins.top: 32
    margins.right: -6
    updatesEnabled: false
    color: "transparent"

    // ── Date state ──────────────────────────────────────────────
    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()  // 0‑based

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var weekdayHeaders: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    // ── Tick timer ──────────────────────────────────────────────
    Timer {
        running: root.visible
        interval: 1000
        repeat: true
        onTriggered: root.today = new Date()
    }
    ColumnLayout {
        id: outerLayout
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        spacing: -16

        Rectangle {
            id: card
            Layout.fillWidth: true
            implicitHeight: contentColumn.implicitHeight + 64
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
                color: Qt.rgba(0, 0, 0, 0.35)
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
                id: borderRect
                anchors.fill: parent
                anchors.margins: 16
                radius: parent.radius
                color: "#a2e4e7ef"
                border.color: "#a0a0a0"
                border.width: 1
            }

            ColumnLayout {
                id: contentColumn
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 32
                }
                spacing: 0

                // ── Time ─────────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: timeColumn.implicitHeight
                    Layout.topMargin: 16
                    Layout.bottomMargin: 4

                    ColumnLayout {
                        id: timeColumn
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.today.toLocaleTimeString(Qt.locale(), "hh:mm")
                            font.pixelSize: 48
                            font.weight: Font.Thin
                            color: palette.windowText
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.today.toLocaleTimeString(Qt.locale(), "AP")
                            font.pixelSize: 14
                            font.weight: Font.Light
                            color: "#666"
                        }
                    }
                }

                // ── Full date ────────────────────────────────────────
                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 0
                    Layout.bottomMargin: 14
                    text: root.today.toLocaleDateString(Qt.locale(), "dddd, MMMM d, yyyy")
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    color: "#555"
                    horizontalAlignment: Text.AlignHCenter
                }

                // ── Separator ────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#22000000"
                }

                // ── Month navigation ─────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    Layout.topMargin: 8

                    RowLayout {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        spacing: 0

                        // Previous month
                        Text {
                            text: "◀"
                            font.pixelSize: 12
                            color: "#888"
                            Layout.preferredWidth: 28
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.viewMonth === 0) {
                                        root.viewMonth = 11;
                                        root.viewYear--;
                                    } else {
                                        root.viewMonth--;
                                    }
                                }
                            }
                        }

                        // Month + Year label
                        Text {
                            Layout.fillWidth: true
                            text: root.monthNames[root.viewMonth] + " " + root.viewYear
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: palette.windowText
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Go to today
                        Text {
                            text: "●"
                            font.pixelSize: 8
                            color: "#888"
                            Layout.preferredWidth: 28
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.viewMonth = root.today.getMonth();
                                    root.viewYear = root.today.getFullYear();
                                }
                            }
                        }

                        // Next month
                        Text {
                            text: "▶"
                            font.pixelSize: 12
                            color: "#888"
                            Layout.preferredWidth: 28
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.viewMonth === 11) {
                                        root.viewMonth = 0;
                                        root.viewYear++;
                                    } else {
                                        root.viewMonth++;
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Weekday headers ──────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    spacing: 0

                    Repeater {
                        model: root.weekdayHeaders
                        delegate: Text {
                            Layout.fillWidth: true
                            text: modelData
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: "#999"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // ── Calendar grid ────────────────────────────────────
                GridLayout {
                    id: calendarGrid
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    columns: 7
                    columnSpacing: 0
                    rowSpacing: 0

                    Repeater {
                        model: root.calendarModel
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "transparent"

                            readonly property var d: modelData

                            Rectangle {
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                radius: 14
                                color: {
                                    if (d.isToday)
                                        return "#007aff";                     // macOS blue
                                    if (d.isCurrentMonth && d.isWeekend)
                                        return "#20000000";
                                    return "transparent";
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: d.dayNumber
                                    font.pixelSize: 12
                                    font.weight: d.isToday ? Font.DemiBold : Font.Normal
                                    color: {
                                        if (d.isToday)
                                            return "#fff";
                                        if (!d.isCurrentMonth)
                                            return "#666";
                                        return palette.windowText;
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (d.isCurrentMonth) {
                                        root.viewMonth = d.monthIndex;
                                        root.viewYear = d.yearNumber;
                                    }
                                }
                            }
                        }
                    }
                }
            } // ColumnLayout
        } // card

        Rectangle {
            id: card2
            Layout.fillWidth: true
            radius: 16
            color: "transparent"

            implicitHeight: contentColumn2.implicitHeight + 64

            Item {
                id: mask2
                anchors.fill: card2
                visible: false
                layer.enabled: true
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 16
                    radius: card2.radius
                    color: "#fff"
                }
            }
            RectangularShadow {
                id: outerShadow2
                anchors.fill: card2
                radius: card2.radius
                blur: 16
                color: Qt.rgba(0, 0, 0, 0.35)
                spread: -16
                visible: false
            }
            MultiEffect {
                anchors.fill: outerShadow2
                source: outerShadow2
                maskSource: mask2
                maskEnabled: true
                maskInverted: true
            }

            Rectangle {
                id: borderRect2
                anchors.fill: card2
                anchors.margins: 16
                radius: card2.radius
                color: "#a2e4e7ef"
                border.color: "#a0a0a0"
                border.width: 1
            }

            ColumnLayout {
                id: contentColumn2
                anchors {
                    top: card2.top
                    left: card2.left
                    right: card2.right
                    margins: 32
                }
                spacing: 0

                // ── Heading ───────────────────────────────────────
                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 16
                    Layout.bottomMargin: 8
                    text: "Notifications"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: "#555"
                    horizontalAlignment: Text.AlignHCenter
                }

                // ── Empty state ───────────────────────────────────
                Text {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    text: "No notifications"
                    font.pixelSize: 11
                    font.weight: Font.Light
                    color: "#aaa"
                    horizontalAlignment: Text.AlignHCenter
                    //visible: notifRepeater.count === 0
                    visible: true
                }

                // ── Notification list ─────────────────────────────
                ColumnLayout {
                    id: notifList
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    spacing: 6
                    visible: false
                }
            }
        }
    }

    // ── Calendar data model ─────────────────────────────────────
    property var calendarModel: {
        var days = [];
        var firstDay = new Date(viewYear, viewMonth, 1);
        var startOffset = firstDay.getDay();  // 0 = Sunday
        var daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();

        // Days from previous month
        var prevMonthLastDay = new Date(viewYear, viewMonth, 0).getDate();
        var prevMonth = viewMonth === 0 ? 11 : viewMonth - 1;
        var prevYear = viewMonth === 0 ? viewYear - 1 : viewYear;
        for (var i = startOffset - 1; i >= 0; i--) {
            days.push({
                dayNumber: prevMonthLastDay - i,
                isCurrentMonth: false,
                isToday: false,
                isWeekend: false,
                monthIndex: prevMonth,
                yearNumber: prevYear
            });
        }

        // Current month days
        var now = new Date();
        var todayDate = now.getDate();
        var todayMonth = now.getMonth();
        var todayYear = now.getFullYear();
        for (var d = 1; d <= daysInMonth; d++) {
            var wday = new Date(viewYear, viewMonth, d).getDay();
            var isToday = (d === todayDate && viewMonth === todayMonth && viewYear === todayYear);
            days.push({
                dayNumber: d,
                isCurrentMonth: true,
                isToday: isToday,
                isWeekend: (wday === 0 || wday === 6),
                monthIndex: viewMonth,
                yearNumber: viewYear
            });
        }

        // Days from next month to fill the last row
        var remaining = 7 - (days.length % 7);
        if (remaining < 7) {
            var nextMonth = viewMonth === 11 ? 0 : viewMonth + 1;
            var nextYear = viewMonth === 11 ? viewYear + 1 : viewYear;
            for (var n = 1; n <= remaining; n++) {
                days.push({
                    dayNumber: n,
                    isCurrentMonth: false,
                    isToday: false,
                    isWeekend: false,
                    monthIndex: nextMonth,
                    yearNumber: nextYear
                });
            }
        }

        return days;
    }
}
