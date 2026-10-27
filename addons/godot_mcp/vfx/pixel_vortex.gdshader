shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Vortex or black hole: spiral arms round a dark core with a bright rim, motes pulled in, shadow
// wisps. Loops.
uniform vec2 canvas = vec2(64.0, 64.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 7;
uniform sampler2D smoke_ramp : filter_nearest, repeat_disable;
uniform int smoke_bands = 5;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_spiral(p, t, s, 0.86, 0.2, 3.0, 2.3, true), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 11u, 3, 14, vec2(0.0), vec2(1.0), vec2(0.5, 1.0), 0.0,
			0.0, 360.0, 0.0, vec2(1.0), 0.0, 0.0, 1.0, 0, vec2(1.0), vec2(0.6, 1.05), 0.0, 1.0, 1.0, 1.4, 0.0, 0), main_ramp, main_bands, 0.1, 0.0, cell);
		// Wisps fill in only where nothing is drawn yet, so they sit behind the disc.
		if (col.a == 0.0) {
			px_paint(col, px_puffs(p, t, k, looping, s + 22u, 6, vec2(0.0), 0.45, 0.6, 0.45, 0.06, 0.17, vec2(0.5, 0.9), 0.5, 0.75),
				smoke_ramp, smoke_bands, 0.1, 0.0, cell);
		}
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 33u, 1, 4, vec2(0.0), vec2(0.5, 1.0), vec2(0.4, 0.8), 0.0,
			0.0, 360.0, 0.5, vec2(1.0), 0.0, 0.0, 1.0, 0, vec2(1.0), vec2(0.95, 0.4), 0.05, 0.0, 0.0, 0.0, 0.0, 0), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
