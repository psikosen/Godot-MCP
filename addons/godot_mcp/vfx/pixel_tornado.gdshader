shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Tornado: dust at the base, a banded funnel, debris circling it (passing behind on the far side) and
// wind arcs. Loops.
uniform vec2 canvas = vec2(64.0, 96.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 6;
uniform sampler2D debris_ramp : filter_nearest, repeat_disable;
uniform int debris_bands = 4;
uniform sampler2D dust_ramp : filter_nearest, repeat_disable;
uniform int dust_bands = 5;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		vec2 ground = vec2(0.0, 1.38);
		px_paint(col, px_puffs(p, t, k, looping, s, 7, ground, 0.5, 0.2, 0.18, 0.1, 0.25, vec2(0.55, 1.0), 0.3, 0.6),
			dust_ramp, dust_bands, 0.1, 0.0, cell);
		uint ds = s + 11u;
		px_paint(col, px_particles(cell, canvas, t, k, looping, ds, 2, 9, vec2(0.0, 0.45), vec2(1.0), vec2(1.0), 0.0, 0.0, 360.0,
			0.0, vec2(1.0), 0.0, 0.0, 0.28, 2, vec2(2.0), vec2(0.8), 0.0, 0.6, 2.0, 0.0, 0.0, -1), debris_ramp, debris_bands, 0.1, 0.0, cell);
		px_paint(col, px_funnel(px_frame_of(p, ground, 0.0, 1.0), t, s + 22u, 0.09, 0.8, 2.75, 3.5, 0.13),
			main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, t, k, looping, ds, 2, 9, vec2(0.0, 0.45), vec2(1.0), vec2(1.0), 0.0, 0.0, 360.0,
			0.0, vec2(1.0), 0.0, 0.0, 0.28, 2, vec2(2.0), vec2(0.8), 0.0, 0.6, 2.0, 0.0, 0.0, 1), debris_ramp, debris_bands, 0.1, 0.0, cell);
		px_paint(col, px_gusts(cell, canvas, t, s + 33u, 5, vec2(0.0, 0.55), 0.62, 0.5, 0.85), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
