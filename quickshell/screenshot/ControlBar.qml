import QtQuick
import ".."

// Segmented pill for picking the capture mode.
//
// Unlike the standalone ControlBar, the highlight follows the tab that is
// actually selected instead of collapsing the active tab out of the row, and
// visible tabs are the ones flagged visible: a hidden tab still holds its width
// here, so the highlighted pill would otherwise slide to the wrong place.
Rectangle {
    id: root

    Variables { id: v }

    property var modes: []
    property string mode: "region"
    property bool editActive: false
    property bool tempActive: false

    readonly property real tabItemSize: 100
    readonly property var visibleModes: modes.filter(m => {
        if (m === "edit")
            return !root.editActive;
        if (m === "temp")
            return !root.tempActive;
        return true;
    })
    readonly property int selectedIndex: Math.max(0, visibleModes.indexOf(root.mode))

    signal modeSelected(string mode)

    implicitHeight: 50
    implicitWidth: visibleModes.length * tabItemSize + 8
    radius: height / 2
    color: "#303030"
    border.color: v.popupBorder
    border.width: 1

    Behavior on implicitWidth {
        enabled: root.tabItemSize > 0
        SpringAnimation {
            spring: 4
            damping: 0.25
            mass: 1
        }
    }

    Rectangle {
        id: highlight

        width: root.tabItemSize
        height: parent.height - 8
        y: 4
        radius: height / 2
        color: v.accentColor
        x: 4 + root.selectedIndex * root.tabItemSize

        Behavior on x {
            SpringAnimation {
                spring: 4
                damping: 0.25
                mass: 1
            }
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 4

        Repeater {
            model: root.visibleModes

            Item {
                id: tabItem

                required property string modelData

                width: root.tabItemSize
                height: root.height - 8

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.modeSelected(tabItem.modelData)
                }

                Text {
                    anchors.centerIn: parent
                    text: {
                        const icons = {
                            "region": "󰒉",
                            "temp": "󰅇",
                            "edit": "󰏫"
                        };
                        const labels = {
                            "region": "Region",
                            "temp": "Temp",
                            "edit": "Edit"
                        };
                        return (icons[tabItem.modelData] || "") + "  " + (labels[tabItem.modelData] || tabItem.modelData);
                    }
                    color: root.mode === tabItem.modelData ? v.accentForeground : v.textSecondary
                    font.weight: root.mode === tabItem.modelData ? Font.Bold : Font.Medium
                    font.pixelSize: 15
                }
            }
        }
    }
}
