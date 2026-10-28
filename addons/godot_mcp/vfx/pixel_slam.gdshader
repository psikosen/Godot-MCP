shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Ground slam: shockwaves rolling out flat along the ground, a burst at the impact, rock chunks
// thrown up and falling, dust settling.
uniform vec2 canvas = vec2(96.0, 64.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 6;
uniform sampler2D dust_ramp : filter_nearest, repeat_disable;
uniform int dust_bands = 5;
uniform sampler2D debris_ramp : filter_nearest, repeat_disable;
uniform int debris_bands = 4;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	vec2 ground = vec2(0.0, 0.6);
	k = px_span(t, 0.15, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_puffs(p, k, k, false, s, 8, ground, 0.9, 0.25, 0.3, 0.12, 0.3, vec2(0.5, 0.85), 0.15, 0.6), dust_ramp, dust_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 0.6);
	if (k >= 0.0) {
		px_paint(col, px_ring(px_frame_of(p, ground, 0.0, 0.3), k, s + 11u, 0.3, 1.45, 0.14, 0.5), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_fireball(px_frame_of(p, ground, 0.0, 0.6), k, s + 22u, 0.38, 0.35), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.15, 0.7);
	if (k >= 0.0) {
		px_paint(col, 0.85 * px_ring(px_frame_of(p, ground, 0.0, 0.3), k, s + 33u, 0.1, 1.0, 0.12, 0.6), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 44u, 0, 14, ground, vec2(1.8, 3.0), vec2(0.5, 0.85), 0.0,
			-90.0, 150.0, 0.1, vec2(1.0), 5.0, 0.8, 1.0, 2, vec2(3.0, 2.0), vec2(0.85, 0.55), 0.0, 0.0, 0.0, 0.0, 0.0, 0), debris_ramp, debris_bands, 0.1, 0.0, cell);
		px_paint(col, px_flash(px_frame_of(p, ground - vec2(0.0, 0.05), 0.0, 0.5), k / 0.1, 0.45) * step(k, 0.1), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
