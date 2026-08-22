import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Io
import QtQuick.Effects
import Quickshell.Hyprland


PanelWindow {
	id: panel 
    Process {
        id: launchedApp
    } 
    FileView {
        id: jsonFile
        path: Qt.resolvedUrl("./appdata.json")
        blockLoading: true
    }
    readonly property var listData: {
        var txt = jsonFile.text();
        return txt ? JSON.parse(txt) : [];
    }
    property int margin: 0
    property bool panelExpanded: false
    property int panelheight: 40
    property int panelwidth: 200
    property int expandedpanelheight: 40
    property int expandedpanelwidth: listData.length * 35 + 10
	property bool panelVisible: true
    property int allIndex: listData.length
    property int currentIndex: 0

    aboveWindows: true
    exclusiveZone: panelVisible ? panelheight + panel.margin - 2 : 0

    anchors {
        top: true
    }

    color: "transparent"

    implicitWidth: expandedpanelwidth > panelwidth ? expandedpanelwidth : panelwidth
    implicitHeight: expandedpanelheight + panel.margin

    GlobalShortcut {
        appid: "my_quickshell"
        name: "my_panel"
        description: "Expand custom panel"

        onPressed: {
            panel.currentIndex = 0
            panel.panelExpanded = true
            console.log("Panel expanded")
        }

        onReleased: {
            panel.panelExpanded = false
            launchedApp.command = [listData[panel.currentIndex].command]
            launchedApp.running = true
            console.log("Panel collapsed")
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

    GlobalShortcut {
        appid: "my_quickshell"
        name: "up"
        description: "Scroll up"

        onPressed: {
            console.log("Scrolled up")
            panel.currentIndex = (panel.currentIndex - 1 + panel.allIndex) % panel.allIndex
        }
    }
    
    GlobalShortcut {
        appid: "my_quickshell"
        name: "down"
        description: "Scroll down"

        onPressed: {
            console.log("Scrolled down")
            panel.currentIndex = (panel.currentIndex + 1) % panel.allIndex
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
        height: panel.panelExpanded ? panel.expandedpanelheight + listData[panel.currentIndex].extraHeight : panel.panelheight
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
                duration: 200
                easing.type: Easing.OutCirc 
            }
        }
		Behavior on anchors.topMargin {
			NumberAnimation {
				duration: 350
				easing.type: Easing.OutCirc
			}
		}
        Rectangle {
            id: cursor
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10 + currentIndex * 35
            color: Colors.md3.primary
            radius: 12.5
            visible: panel.panelExpanded
            Behavior on anchors.leftMargin {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}