pragma Singleton
import QtQuick

QtObject {
  // Couleurs principales
  readonly property color bg:     "#0b0a09"
  readonly property color bg2:    "#111008"
  readonly property color bg3:    "#1a1814"
  readonly property color fg:     "#c8c8c8"
  readonly property color fgd:    Qt.rgba(200/255, 200/255, 200/255, 0.5)
  readonly property color fgdd:   Qt.rgba(200/255, 200/255, 200/255, 0.2)

  // Accents
  readonly property color a1:     "#bdbdbd"
  readonly property color a2:     "#a6a6a6"
  readonly property color a3:     "#b0b0b0"
  readonly property color a4:     "#b5b5b5"

  // Bordures
  readonly property color ln:     Qt.rgba(200/255, 200/255, 200/255, 0.12)
  readonly property color lnm:    Qt.rgba(200/255, 200/255, 200/255, 0.22)

  // Font
  readonly property string mono:  "Share Tech Mono"

  // Timings animations
  readonly property int durationFast:   150
  readonly property int durationMid:    380
  readonly property int durationSlow:   650
}