pragma ComponentBehavior: Bound

import QtQuick

//  Animated rainbow wave background
//
// Draws several overlapping semi-transparent sinusoidal bands that drift
// horizontally over time, tinted with a rainbow hue that cycles through
// the colour wheel. The bands are confined to a thin strip along the
// bottom edge of the host item (roughly its lower fifth) and fade out
// just above that strip.
//
// Performance notes:
//   * A single fragment shader renders every band in one pass — no layered
//     items, no per-band draw calls.
//   * Only the band centre/falloff and a couple of sines are evaluated per
//     fragment; the HSV→RGB conversion is computed once and reused.
//   * The time accumulator lives in QML as a double and is pushed into the
//     shader as a float, so long sessions never lose precision.
//   * The host drives `time` from an infinitely looping animation, which
//     stops when the panel hides, so the effect costs nothing while closed.
//   * The shader draws an unclipped rectangle; the host clips it to the
//     rounded card (see AI.qml) so corner rounding stays off the shader.
//
// The shader is baked with `qsb` from ai/shaders/waves.frag:
//   /usr/lib/qt6/bin/qsb --qt6 -o waves.frag.qsb waves.frag
Item {
    id: wave

    // Number of overlapping bands. More bands = richer blending, more cost.
    property int bandCount: 4

    // Vertical position of the lowest band's centre, measured from the
    // bottom edge (uv.y = 0 at top, 1 at bottom). Keeps the waves hugging
    // the bottom of the item.
    property real bandBase: 0.92

    // Vertical half-thickness of each band, as a fraction of item height.
    property real bandHeight: 0.04

    // Vertical position step between band centre lines (fraction).
    property real bandSpacing: 0.02

    // Peak alpha of a single band (kept under 1 so overlaps show through).
    property real bandAlpha: 0.3

    // Horizontal frequency of the sine, in radians per item width.
    property real waveFrequency: 3

    // Vertical wobble amplitude as a fraction of item height.
    property real waveAmplitude: 0.03

    property real waveSpeed: -0.8
    property real hueSpeed: 0.2

    property real time: 0

    property real speed: 1.0

    ShaderEffect {
        anchors.fill: parent
        blending: true
        fragmentShader: "shaders/waves.frag.qsb"

        property real iTime: wave.time * wave.speed
        property int uBands: wave.bandCount
        property real uBandBase: wave.bandBase
        property real uBandHeight: wave.bandHeight
        property real uBandSpacing: wave.bandSpacing
        property real uBandAlpha: wave.bandAlpha
        property real uFreq: wave.waveFrequency
        property real uAmp: wave.waveAmplitude
        property real uSpeed: wave.waveSpeed
        property real uHueSpeed: wave.hueSpeed
    }
}
