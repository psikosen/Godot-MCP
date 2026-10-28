shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Heal: a ring on the ground, a dithered column of light, rising crosses and twinkling stars.
uniform vec2 canvas = vec2(48.0, 64.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 6;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	vec2 ground = vec2(0.0, 1.2);
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, 0.85 * px_ring(px_frame_of(p, ground, 0.0, 0.35), k, s, 0.3, 0.95, 0.12, 0.3), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, 0.62 * px_column(px_frame_of(p, ground, 0.0, 1.0), k, k, false, s + 11u, 0.5, 2.3, 0.25), main_ramp, main_bands, 0.1, 1.0, cell);
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 22u, 1, 9, ground - vec2(0.0, 0.15), vec2(0.8, 1.5), vec2(0.5, 0.85), 0.5,
			0.0, 360.0, 0.65, vec2(1.0, 0.25), 0.0, 0.0, 1.0, 3, vec2(1.0), vec2(1.05, 0.65), 0.06, 0.0, 0.0, 0.0, 0.0, 0), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 33u, 1, 8, ground - vec2(0.0, 0.2), vec2(0.5, 1.0), vec2(0.4, 0.8), 0.6,
			0.0, 360.0, 0.7, vec2(1.0, 0.3), 0.0, 0.0, 1.0, 4, vec2(2.0, 1.0), vec2(1.0, 0.35), 0.06, 0.0, 0.0, 0.0, 2.0, 0), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
