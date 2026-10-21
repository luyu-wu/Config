#version 310 es
precision highp float;

// Rainbow sine-wave bands for the AI panel background.
//
// A single pass draws N overlapping semi-transparent sinusoidal bands.
// Each band is a smooth vertical ramp modulated by a running sine wave. The
// bands are evenly spread in phase (band i is delayed by i * 2pi / N) and
// each gets its own hue, evenly spaced around the colour wheel (band i sits
// at i/N), so the set traces the full spectrum while the waves braid past
// one another; both the hues and the waves drift together over time. A tight
// vertical fade keeps the whole effect confined to a thin strip along the
// bottom edge of the item (roughly its lower fifth).
//
// Written in the Qt 6 / qsb Vulkan-compatible GLSL dialect:
//   * #version 310 es (required for SPIR-V on the Vulkan RHI path)
//   * explicit layout(location=...) for inputs/outputs
//   * uniforms in a std140 block named "buf", with qt_Matrix and
//     qt_Opacity first so Qt auto-binds them, followed by the custom
//     properties exposed by the ShaderEffect.
//
// qt_TexCoord0.y is 0 at the top and 1 at the bottom, so "uv.y" below is
// measured upward from the bottom edge of the item.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

// GLSL has no built-in PI constant.
const float TWO_PI = 6.28318530718;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float iTime;
    int uBands;
    float uBandBase;
    float uBandHeight;
    float uBandSpacing;
    float uBandAlpha;
    float uFreq;
    float uAmp;
    float uSpeed;
    float uHueSpeed;
} ubuf;

// Standard HSV -> RGB. h is in [0, 1).
vec3 hsv2rgb(float h, float s, float v) {
    vec3 p = abs(fract(vec3(h) + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
    return v * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), s);
}

void main() {
    // uv.y = 0 at the top, 1 at the bottom.
    vec2 uv = qt_TexCoord0;

    float t = ubuf.iTime;
    vec3 col = vec3(0.0);
    float accumAlpha = 0.0;

    // Base hue advances slowly over time; each band is offset by an equal
    // fraction of the wheel so the bands are spread evenly around the hue
    // circle and the whole set rotates together as it drifts.
    float baseHue = fract(t * ubuf.uHueSpeed);
    float invBands = 1.0 / max(1.0, float(ubuf.uBands));

    for (int i = 0; i < 8; i++) {
        if (i >= ubuf.uBands) {
            break;
        }

        float fi = float(i);

        // Horizontal phase: an evenly spaced per-band offset plus the travel
        // term. Offsetting band i by i * (2pi / bandCount) spreads the phase
        // delays uniformly over one full sine period; the per-band travel
        // multiplier below then makes them slide past each other, which is
        // what produces the overlapping, braided look.
        float phaseOffset = fi * (TWO_PI * invBands);
        float phase = phaseOffset + uv.x * ubuf.uFreq + t * ubuf.uSpeed * (1.0 + fi * 0.15);

        // Band centre lines are stacked from uBandBase, which sits near the
        // bottom edge, so the whole effect is confined to a thin strip there.
        float center = ubuf.uBandBase + fi * ubuf.uBandSpacing + sin(phase) * ubuf.uAmp;

        // Smooth symmetric falloff around the centre line.
        float d = abs(uv.y - center) / ubuf.uBandHeight;
        float band = smoothstep(1.0, 0.0, d);

        // This band's own tint, evenly spaced around the hue wheel.
        vec3 tint = hsv2rgb(fract(baseHue + fi * invBands), 0.85, 1.0);

        // Additive blend of each semi-transparent band. Where several band
        // cores overlap this pushes toward white, mimicking semi-transparent
        // light stacking.
        float a = band * ubuf.uBandAlpha;
        col += tint * a;
        accumAlpha += a;
    }

    // Fade the whole effect out just above the band strip, keeping the
    // waves localized to roughly the bottom fifth of the item.
    float verticalFade = smoothstep(0.80, 1.0, uv.y);

    float alpha = clamp(accumAlpha, 0.0, 0.95) * verticalFade * ubuf.qt_Opacity;
    fragColor = vec4(col * verticalFade, alpha);
}
