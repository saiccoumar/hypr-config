import QtQuick
import Quickshell.Io
import "../settings"

Item {
    id: root

    readonly property int pw: Settings.playerWidth || 320
    readonly property real sc: Settings.scale || 1.0
    function s(px) { return Math.round(px * sc) }

    property string weatherLoc: "Loading..."
    property string weatherCond: "..."
    property string weatherTemp: "--"
    property string weatherWind: "--"
    property string weatherHum: "--"

    
    implicitWidth: pw
    implicitHeight: contentRow.implicitHeight + s(40)

    property bool shown: false

    function toggleVisible() {
        if (root.shown) {
            root.shown = false
            revealAnim.stop()
            hideAnim.start()
        } else {
            root.shown = true
            hideAnim.stop()
            revealAnim.start()
        }
    }

    Item {
        id: wipeHost
        width: pw
        height: parent.implicitHeight
        clip: true
        x: pw + 2
        opacity: 1
        visible: false

        Rectangle {
            anchors.fill: parent
            color: Settings.playerBackground ? (Settings.playerBgColor || Qt.rgba(0,0,0,0.8)) : "transparent"
        }
        
        Rectangle {
            width: pw; height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.2; color: Qt.rgba(200/255,184/255,154/255,0.5) }
                GradientStop { position: 0.8; color: Qt.rgba(200/255,184/255,154/255,0.5) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
        
        Rectangle {
            anchors.bottom: parent.bottom
            width: pw; height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.2; color: Qt.rgba(200/255,184/255,154/255,0.5) }
                GradientStop { position: 0.8; color: Qt.rgba(200/255,184/255,154/255,0.5) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Column {
            id: contentRow
            anchors.centerIn: parent
            spacing: s(6)
            width: pw - s(30)

            Text {
                id: prefixText
                text: "NR-W // CURRENT WEATHER //"
                font.family: "Share Tech Mono"
                font.pixelSize: s(10)
                color: Qt.rgba(200/255, 184/255, 154/255, 0.5)
                opacity: 0
            }

            Rectangle { width: parent.width; height: 1; color: Qt.rgba(200/255, 184/255, 154/255, 0.1); opacity: prefixText.opacity }

            Text {
                id: locText
                text: root.weatherLoc
                font.family: "Share Tech Mono"
                font.pixelSize: s(16)
                color: Qt.rgba(200/255, 184/255, 154/255, 0.9)
                opacity: 0
            }

            Text {
                id: condText
                text: root.weatherCond
                font.family: "Share Tech Mono"
                font.pixelSize: s(14)
                color: Qt.rgba(200/255, 184/255, 154/255, 1.0)
                opacity: 0
            }

            Row {
                spacing: s(15)
                opacity: condText.opacity
                Text {
                    text: "TEMP: " + root.weatherTemp
                    font.family: "Share Tech Mono"
                    font.pixelSize: s(12)
                    color: Qt.rgba(200/255, 184/255, 154/255, 0.8)
                }
                Text {
                    text: "WIND: " + root.weatherWind
                    font.family: "Share Tech Mono"
                    font.pixelSize: s(12)
                    color: Qt.rgba(200/255, 184/255, 154/255, 0.8)
                }
                Text {
                    text: "HUM: " + root.weatherHum
                    font.family: "Share Tech Mono"
                    font.pixelSize: s(12)
                    color: Qt.rgba(200/255, 184/255, 154/255, 0.8)
                }
            }
        }

        Rectangle {
            id: curtain
            anchors { top: parent.top; bottom: parent.bottom }
            color: "#c8c8c8"
            z: 10
            x: 318
            width: 2
        }
    }

    SequentialAnimation {
        id: revealAnim
        ParallelAnimation {
            NumberAnimation { target: wipeHost; property: "x"; from: pw+2; to: 0; duration: 460; easing.type: Easing.OutExpo }
            NumberAnimation { target: curtain; property: "width"; from: 320; to: 320; duration: 460 }
        }
        ParallelAnimation {
            NumberAnimation { target: curtain; property: "x"; from: 0; to: 0; duration: 340 }
            NumberAnimation { target: curtain; property: "width"; from: 320; to: 0; duration: 340; easing.type: Easing.OutExpo }
        }
        onStarted: {
            wipeHost.x = pw+2; wipeHost.opacity = 1; wipeHost.visible = true
            curtain.x = 0; curtain.width = pw
            prefixText.opacity = 0; locText.opacity = 0; condText.opacity = 0
        }
        onFinished: {
            wipeHost.x = 0; curtain.x = 0; curtain.width = 0
            textFadeIn.start()
        }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: curtain; property: "x"; from: 0; to: 0; duration: 180 }
            NumberAnimation { target: curtain; property: "width"; from: 0; to: 320; duration: 180; easing.type: Easing.InOutQuart }
        }
        NumberAnimation { target: wipeHost; property: "x"; from: 0; to: pw+2; duration: 380; easing.type: Easing.InExpo }
        onStarted: { curtain.x = 0; curtain.width = 0 }
        onFinished: { wipeHost.visible = false; wipeHost.x = pw+2; curtain.x = 0; curtain.width = pw }
    }

    ParallelAnimation {
        id: textFadeIn
        NumberAnimation { target: prefixText; property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { target: locText; property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { target: condText; property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
    }
}
