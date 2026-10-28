shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Lightning strike: a forked bolt from the sky (a new path every frame), a flash and blast where it
// lands, a ring along the ground, sparks thrown up and settling dust.
uniform vec2 canvas = vec2(64.0, 96.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 6;
uniform sampler2D smoke_ramp : filter_nearest, repeat_disable;
uniform int smoke_bands = 6;
uniform sampler2D spark_ramp : filter_nearest, repeat_disable;
uniform int spark_bands = 6;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	int frame = px_frame(clock, fps);
	vec2 ground = vec2(0.0, 1.22);
	k = px_span(t, 0.2, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_puffs(p, k, k, false, s, 6, ground, 0.45, 0.3, 0.26, 0.12, 0.28, vec2(0.55, 0.8), 0.15, 0.55),
			smoke_ramp, smoke_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.04, 0.62);
	if (k >= 0.0) {
		px_paint(col, px_ring(px_frame_of(p, ground, 0.0, 0.32), k, s + 11u, 0.2, 0.95, 0.2, 0.6), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.04, 0.7);
	if (k >= 0.0) {
		px_paint(col, px_fireball(px_frame_of(p, ground - vec2(0.0, 0.1), 0.0, 0.75), k, s + 22u, 0.42, 0.4), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 0.75);
	if (k >= 0.0) {
		px_paint(col, px_bolt(p, canvas, k, frame, s + 33u, 2, ground, 0.35, 0.32, 0.45), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.04, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 44u, 0, 12, ground, vec2(1.6, 2.8), vec2(0.3, 0.6), 0.0,
			-90.0, 130.0, 0.05, vec2(1.0), 4.0, 1.0, 1.0, 1, vec2(2.0), vec2(1.0, 0.5), 0.0, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 0.14);
	if (k >= 0.0) {
		px_paint(col, px_flash(px_frame_of(p, ground - vec2(0.0, 0.1), 0.0, 1.0), k, 0.6), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
