import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.popups.volume

Item {
    id: root

    Layout.fillHeight: true
    Layout.leftMargin: 8
    implicitWidth: icon.implicitWidth + 24

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    readonly property real volume: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.volume : 0.0
    readonly property bool muted: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.muted : false

    Rectangle {
        id: volumeWidget
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 3
        radius: 6
        color: volumePopup.visible ? "#20000000" : "transparent"
    }

    readonly property string iconName: {
        if (muted || volume === 0.0)
            return "audio-volume-muted";
        if (volume < 0.34)
            return "audio-volume-low";
        if (volume < 0.67)
            return "audio-volume-medium";
        return "audio-volume-high";
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            volumePopup.visible = !volumePopup.visible;
        }
    }
    IconImage {
        id: icon
        anchors.centerIn: parent
        implicitSize: 32
        source: "image://icon/" + root.iconName
        visible: true
    }
    VolumePopup {
        id: volumePopup
        visible: false
    }
}
