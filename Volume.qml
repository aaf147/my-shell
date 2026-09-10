import QtQuick
import Quickshell
import Quickshell.Services.Pipewire 

Item {
    property MainPanel panel
    property bool shouldShowOsd: false
    property int volume: Math.round(panel.volume * 100)
    property bool volumeOnRight: volume > 50
    property bool noActivation: true
    
    function positionVolumeText() {
        if (volume > 50) {    
            volumeText.x = panel.panelwidth / 6 - volumeText.width / 2
        } else {
            volumeText.x = panel.panelwidth / 1.2 - volumeText.width / 2
        }
    }

    Component.onCompleted: {
        print(panel.panelStats)
        positionVolumeText()
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
    Timer {
        id: volumeChangeTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            positionVolumeText()
            volumeText.opacity = 1.0
        }
    }
    onVolumeOnRightChanged: {
        print(volumeOnRight)
        volumeText.opacity = 0.0
        volumeChangeTimer.restart()
    }
    Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
            if (!noActivation) {
                shouldShowOsd = true;
                osdTimer.restart()
                panel.volume = Pipewire.defaultAudioSink?.audio.volume
            }
            noActivation = false
		}
	}
    onShouldShowOsdChanged: {
        if (shouldShowOsd) {
            panel.panelStats = "volume"
            volumeText.opacity = 1.0
            positionVolumeText()
        } else {
            panel.panelStats = "none"
            volumeText.opacity = 0.0
        }
    }
    Text {
        id: volumeText
        y: parent.parent.height / 2 - height / 2
        text: volume + "%"
        
        color: Colors.md3.on_surface
        font.pointSize: 12
        font.bold: true
        opacity: 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }
        }
        transform: Translate {
            x: volume < 10 ? 5 : 0
        }


        Rectangle {
            id: volumeTextBackground
            anchors.centerIn: parent

            width: volume < 10 ? volumeText.width + 10 : volumeText.width + 10
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
 