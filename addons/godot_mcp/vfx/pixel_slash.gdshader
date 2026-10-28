shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Sword slash: a thin inner arc just behind a thick crescent sweeping over the top, sparks flung off
// where the blade ends.
uniform vec2 canvas = vec2(64.0, 64.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 6;
uniform sampler2D spark_ramp : filter_nearest, repeat_disable;
uniform int spark_bands = 6;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	k = px_span(t, 0.03, 0.7);
	if (k >= 0.0) {
		px_paint(col, 0.8 * px_arc(p, k, s, 0.55, 0.1, radians(-150.0), radians(40.0), 0.38), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 0.75);
	if (k >= 0.0) {
		px_paint(col, px_arc(p, k, s + 11u, 0.74, 0.28, radians(-150.0), radians(40.0), 0.36), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.12, 0.85);
	if (k >= 0.0) {
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 22u, 0, 10, vec2(cos(radians(40.0)), sin(radians(40.0))) * 0.7,
			vec2(1.4, 2.6), vec2(0.3, 0.55), 0.0, 130.0, 70.0, 0.05, vec2(1.0), 0.0, 3.0, 1.0, 1, vec2(2.0), vec2(1.0, 0.5),
			0.0, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
