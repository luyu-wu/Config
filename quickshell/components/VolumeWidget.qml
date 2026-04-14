import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Widgets

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

    readonly property string iconName: {
        if (muted || volume === 0.0)
            return "audio-volume-muted";
        if (volume < 0.34)
            return "audio-volume-low";
        if (volume < 0.67)
            return "audio-volume-medium";
        return "audio-volume-high";
    }

    IconImage {
        id: icon
        anchors.centerIn: parent
        implicitSize: 32
        source: "image://icon/" + root.iconName
    }
}
