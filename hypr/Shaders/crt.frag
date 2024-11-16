//modified version of [this shader](https://github.com/wessles/GLSL-CRT/blob/master/shader.frag)

precision mediump float;
varying vec2 v_texcoord;

uniform sampler2D tex;

void main() {
	vec2 tc = vec2(v_texcoord.x, v_texcoord.y);

	// Distance from the center
	float dx = abs(0.5-tc.x);
	float dy = abs(0.5-tc.y);

	// Square it to smooth the edges
	dx *= dx;
	dy *= dy;

	tc.x -= 0.5;
	tc.x *= 1.0 + (dy * 0.03);
	tc.x += 0.5;

	tc.y -= 0.5;
	tc.y *= 1.0 + (dx * 0.03);
	tc.y += 0.5;

	// Get texel, and add in scanline if need be
	vec4 cta = texture2D(tex, vec2(tc.x, tc.y));

	cta.rgb += sin(tc.y * 1250.0) * 0.02;

	// Cutoff
	if(tc.y > 1.0 || tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0)
		cta = vec4(0.0);

	// Apply
	gl_FragColor = cta;
}
