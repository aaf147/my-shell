import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import Quickshell.Hyprland

PanelWindow {
	id: panel
    property int margin: 0
    property bool panelExpanded: false
    property int panelheight: 40
    property int panelwidth: 200
    property int expandedpanelheight: 200
    property int expandedpanelwidth: 600
	property bool panelVisible: false

    aboveWindows: true
    exclusiveZone: panelVisible ? panelheight + panel.margin - 2 : 0

    anchors {
        top: true
    }

    color: "transparent"

    implicitWidth: expandedpanelwidth
    implicitHeight: expandedpanelheight + panel.margin

    GlobalShortcut {
        appid: "my_quickshell"
        name: "my_panel"
        description: "Expand custom panel"

        onPressed: {
            panel.panelExpanded = true
        }

        onReleased: {
            panel.panelExpanded = false
        }
    }
	GlobalShortcut {
        appid: "my_quickshell"
        name: "hide"
        description: "Hide custom panel"

        onPressed: {
            panel.panelVisible = !panel.panelVisible
        }

    }
	
	mask: Region {
        item: panelSurface
    }

    Rectangle {
        id: panelSurface

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: panelExpanded ? panel.margin : (panelVisible ? panel.margin : panel.margin - panel.panelheight - 2)

        width: panel.panelExpanded ? panel.expandedpanelwidth : panel.panelwidth
        height: panel.panelExpanded ? panel.expandedpanelheight : panel.panelheight
        color: Colors.md3.surface
        border.color: Qt.alpha(Colors.md3.outline, 0.3)
        border.width: 1

        radius: panel.panelheight / 2

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCirc
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCirc
            }
        }
		Behavior on anchors.topMargin {
			NumberAnimation {
				duration: 350
				easing.type: Easing.OutCirc
			}
		}

		
    }
}