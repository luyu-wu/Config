import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.popups.stocks
import ".."

Item {
    Variables { id: v }
    id: root

    Layout.leftMargin: 10
    Layout.fillHeight: true
    implicitWidth: stocksLabel.implicitWidth + 20

    // ── shared stock data ────────────────────────────────────────────
    property var quotes: []
    property bool loading: false
    property date lastUpdated: new Date(0)

    readonly property color stockGain: "#4CD964"
    readonly property color stockLoss: "#FF453A"

    function refresh() {
        fetchProc.running = true;
    }

    function onQuotesFetched(raw) {
        try {
            const data = JSON.parse(raw);
            if (Array.isArray(data)) {
                root.quotes = data;
                root.lastUpdated = new Date();
            }
        } catch (e) {
            console.warn("stocks: could not parse quotes:", e);
        }
    }

    Process {
        id: fetchProc
        running: false
        command: ["python3", Quickshell.shellPath("share/stocks/stocks.py")]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.onQuotesFetched(this.text)
        }
        stderr: StdioCollector {
            waitForEnd: true
        }
        onRunningChanged: root.loading = running
    }

    // Refresh only while the popup is open to conserve resources:
    // on open (MouseArea below) and periodically while it stays open.
    Timer {
        interval: 60 * 1000
        running: stocksPopup.visible
        repeat: true
        onTriggered: root.refresh()
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: stocksPopup.visible ? v.widgetHighlight : "transparent"
    }

    Text {
        id: stocksLabel
        anchors.centerIn: parent
        text: "󰠟"
        font.family: "SF Pro"
        font.pixelSize: 19
        font.weight: 400
        color: v.textSecondary
        renderType: Text.NativeRendering
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            stocksPopup.visible = !stocksPopup.visible;
            stocksPopup.updatesEnabled = stocksPopup.visible;
            if (stocksPopup.visible)
                root.refresh();
        }
    }

    StocksPopup {
        id: stocksPopup
        visible: false
        quotes: root.quotes
        loading: root.loading
        lastUpdated: root.lastUpdated
        gainColor: root.stockGain
        lossColor: root.stockLoss
        onRefreshRequested: root.refresh()
    }
}
