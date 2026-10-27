shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Explosion: a white flash, a fireball that cools and breaks up, a shockwave, sparks, embers and smoke.
uniform vec2 canvas = vec2(64.0, 64.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 7;
uniform sampler2D smoke_ramp : filter_nearest, repeat_disable;
uniform int smoke_bands = 6;
uniform sampler2D spark_ramp : filter_nearest, repeat_disable;
uniform int spark_bands = 7;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	k = px_span(t, 0.2, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_puffs(p, k, k, false, s, 8, vec2(0.0, 0.05), 0.35, 0.7, 0.42, 0.15, 0.4, vec2(0.5, 0.8), 0.2, 0.65),
			smoke_ramp, smoke_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 0.85);
	if (k >= 0.0) {
		px_paint(col, px_fireball(p, k, s + 11u, 0.72, 0.4), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 0.5);
	if (k >= 0.0) {
		px_paint(col, px_ring(p, k, s + 22u, 0.22, 0.95, 0.13, 0.85), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 33u, 0, 16, vec2(0.0), vec2(1.6, 2.9), vec2(0.35, 0.7), 0.0,
			0.0, 360.0, 0.05, vec2(1.0), 0.0, 2.2, 1.0, 1, vec2(2.0), vec2(1.0, 0.5), 0.0, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
		px_paint(col, px_flash(p, k / 0.1, 0.45) * step(k, 0.1), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.1, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 44u, 1, 10, vec2(0.0), vec2(0.6, 1.3), vec2(0.4, 0.9), 0.6,
			0.0, 360.0, 0.45, vec2(1.0), 0.0, 0.0, 1.0, 0, vec2(1.0), vec2(1.0, 0.35), 0.07, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
