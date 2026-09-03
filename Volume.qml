import QtQuick
import Quickshell
import Quickshell.Services.Pipewire 

// TODO make it that panelstats change triggers shouldShowOsd to false
// TODO make the ui cooler

Item {
    property MainPanel panel
    property bool shouldShowOsd: false

    Component.onCompleted: {
        print(panel.panelStats)
    }
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }
    Timer {
        id: osdTimer
        interval: 1000
        running: false
        repeat: false

        onTriggered: {
            shouldShowOsd = false
        }
    }
    Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
            shouldShowOsd = true;
            osdTimer.restart()
            panel.volume = Pipewire.defaultAudioSink?.audio.volume
		}
	}
    onShouldShowOsdChanged: {
        if (shouldShowOsd) {
            panel.panelStats = "volume"
        } else {
            panel.panelStats = "none"
        }
    }
}
 