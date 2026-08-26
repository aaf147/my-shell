import Quickshell
import Quickshell.Wayland
import QtQuick
import Quickshell.Io
import QtQuick.Effects
import Quickshell.Hyprland
import QtQuick.Layouts


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
    property string panelStats: "none"
    property bool panelExpanded: false
    property bool panelSemiExpanded: false
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
    implicitHeight: 1000

    GlobalShortcut {
        appid: "my_quickshell"
        name: "my_panel"
        description: "Expand custom panel"

        onPressed: {
            if (panelVisible) {
                panelStats = "expanded"
            } else {
                panelStats = "semiexpanded"
            }
            console.log("Panel expanded")
        }

        onReleased: {
            launchedApp.command = ["hyprctl", "dispatch", "hl.dsp.exec_cmd(\"" + listData[panel.currentIndex].command + "\")"]
            launchedApp.running = true
            panel.currentIndex = 0
            panelStats = "none"
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
            if (panelStats == "expanded") {
                panel.currentIndex = (panel.currentIndex - 1 + panel.allIndex) % panel.allIndex;
            } else if (panelStats == "semiexpanded") {
                panelStats = "expanded";
                panel.currentIndex = (panel.currentIndex - 1 + panel.allIndex) % panel.allIndex;
            }
        }
    }
    
    GlobalShortcut {
        appid: "my_quickshell"
        name: "down"
        description: "Scroll down"

        onPressed: {
            console.log("Scrolled down")
            if (panelStats == "expanded") {
                panel.currentIndex = (panel.currentIndex + 1) % panel.allIndex;
            } else if (panelStats == "semiexpanded") {
                panelStats = "expanded";
                panel.currentIndex = (panel.currentIndex + 1) % panel.allIndex;
            }
        }
    }
    
    onCurrentIndexChanged: {
        if (currentIndex == 0) {
            panelStats = "semiexpanded";
        }
    }

	mask: Region {
        item: panelSurface
    }

    Rectangle {
        id: panelSurface

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: if (panelStats == "expanded" || panelStats == "semiexpanded") { 
            panel.margin
        } else {
            panelVisible ? panel.margin : panel.margin - panel.panelheight - 2
        }


        width: panelStats == "expanded" ? panel.expandedpanelwidth : panel.panelwidth
        height: panelStats == "expanded" ? panel.expandedpanelheight + listData[panel.currentIndex].extraHeight : panel.panelheight
        color: Colors.md3.surface
        border.color: Qt.alpha(Colors.md3.outline, 0.3)
        border.width: 1
        clip: true
        radius: panel.panelheight / 2
        
        Text {
            id: clock
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 15
            text: Qt.formatDateTime(new Date(), "M/d ddd hh:mm")
            color: Colors.md3.on_surface
            font.pointSize: 12
            font.bold: true
            opacity: panelStats == "expanded" ? 0.0 : 1.0 
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "M/d ddd hh:mm")
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutQuad
                }
            }
        }
        
        Behavior on height {
            NumberAnimation {
                id: heightAnim
                duration: 200
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
            anchors.top: parent.top
            anchors.topMargin: 7.5
            anchors.left: parent.left
            anchors.leftMargin: 10 + currentIndex * 35
            color: Colors.md3.primary
            radius: 12.5
            visible: true
            Behavior on anchors.leftMargin {
                NumberAnimation {
                    id: cursorAnim
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            text: listData[panel.currentIndex].extraHeight == 0 ? text : listData[panel.currentIndex].name
            visible: true
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 0
            color: Colors.md3.on_surface
            font.pointSize: 12
            font.bold: true
        }
        
        RowLayout {
            spacing: 10
            anchors.top: parent.top
            anchors.topMargin: 7.5
            anchors.left: parent.left
            anchors.leftMargin: 9.5
            Repeater {
                model: listData.length
                Item {
                    width: 25
                    height: 25
                    Image {
                        anchors.centerIn: parent
                        source: listData[index].icon
                        width: 20
                        height: 20
                        fillMode: Image.PreserveAspectFit
                        opacity: panelStats == "expanded" ? 1.0 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: listData[index].nfIcon
                        font.family: "JetBrainsMono Nerd Font"
                        font.pointSize: 15
                        opacity: panelStats == "expanded" ? 1.0 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                        color: currentIndex === index && !cursorAnim.running ? Colors.md3.on_primary : Colors.md3.on_surface
                    }
                }
            }
        }
    }
}