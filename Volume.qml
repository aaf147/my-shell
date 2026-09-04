import QtQuick
import Quickshell
import Quickshell.Services.Pipewire 

// TODO make it that panelstats change triggers shouldShowOsd to false

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
    Text {
        id: volumeText
        x: Math.round(panel.volume * 100) > 50 ? parent.parent.width / 6 - width / 2 : parent.parent.width / 1.2 - width / 2
        y: parent.parent.height / 2 - height / 2
        text: Math.round(panel.volume * 100) + "%"
        color: Colors.md3.on_surface
        opacity: panel.panelStats == "volume" ? 1.0 : 0.0
        font.pointSize: 12
        font.bold: true
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }
        }
        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
        Rectangle {
            id: volumeTextBackground
            anchors.centerIn: parent
            width: volumeText.width + 10
            height: volumeText.height + 4
            radius: height / 2
            color: Colors.md3.surface
            z: -1
        }
    }
    Rectangle {
        id: barDecor
        x: parent.parent.width / 2 - width / 2
        y: parent.parent.height / 2 - height / 2
        width: parent.parent.width / 1.2
        height: 4
        color: Colors.md3.surface_variant
        z: -1
        radius: height / 2
        opacity: panel.panelStats == "volume" ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }
        }
    }
}
 