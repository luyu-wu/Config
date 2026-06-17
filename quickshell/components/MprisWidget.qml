import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.popups.mpris

Item {
    id: root

    Layout.leftMargin: 10
    Layout.fillHeight: true
    implicitWidth: visible ? (mprisLabel.implicitWidth + 20) : 0
    visible: Mpris.players.values.length > 0

    readonly property var player: {
        let players = Mpris.players.values;
        if (players.length === 0)
            return null;
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing)
                return players[i];
        }
        return players[0];
    }

    readonly property string playerIcon: {
        if (!player)
            return "";
        if (player.playbackState === MprisPlaybackState.Paused)
            return "󰏤";
        let id = player.identity.toLowerCase();
        if (id.includes("spotify"))
            return "󰓇";
        if (id.includes("io"))
            return "󰫔";
        if (id.includes("firefox"))
            return "";
        return "󰎈";
    }

    readonly property string trackTitle: {
        if (!player)
            return "";
        let t = player.trackTitle ?? "";
        return t.length > 16 ? t.substring(0, 14) + " ..." : t;
    }
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mprisPopup.visible ? "#20000000" : "transparent"
    }

    Text {
        id: mprisLabel
        anchors.centerIn: parent
        text: root.player ? root.playerIcon + "    " + root.trackTitle : ""
        font.family: "SF Pro"
        font.pixelSize: 19
        color: root.player?.playbackState === MprisPlaybackState.Playing ? "#222" : "#555"
        font.weight: 400
        elide: Text.ElideRight
        renderType: Text.NativeRendering
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            mprisPopup.visible = !mprisPopup.visible;
            mprisPopup.updatesEnabled = mprisPopup.visible;
            root.player.positionChanged();
        }
    }

    MprisPopup {
        id: mprisPopup
        visible: false
        player: root.player
    }
}
