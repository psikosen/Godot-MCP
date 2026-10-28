shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Poof: a burst of smoke with a ring of dust and a few stars (spawn, vanish, smoke bomb).
uniform vec2 canvas = vec2(48.0, 48.0);
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
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_puffs(p, k, k, false, s, 8, vec2(0.0), 0.3, 0.8, 0.22, 0.2, 0.44, vec2(0.6, 1.0), 0.1, 0.8), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 0.5);
	if (k >= 0.0) {
		px_paint(col, 0.7 * px_ring(p, k, s + 11u, 0.2, 0.9, 0.1, 0.6), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.1, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 22u, 0, 4, vec2(0.0), vec2(0.8, 1.4), vec2(0.35, 0.6), 0.0,
			0.0, 360.0, 0.05, vec2(1.0), 0.0, 2.0, 1.0, 4, vec2(2.0), vec2(1.0, 0.35), 0.0, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
