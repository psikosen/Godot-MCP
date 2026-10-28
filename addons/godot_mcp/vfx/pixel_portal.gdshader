shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Portal: a tall spiral round a dark core, motes pulled in, sparkles rising off its rim. Loops.
uniform vec2 canvas = vec2(64.0, 64.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 7;
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
		px_paint(col, px_spiral(px_frame_of(p, vec2(0.0), 0.0, 1.5), t, s, 0.6, 0.28, 2.0, 1.8, true), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 11u, 3, 12, vec2(0.0), vec2(1.0), vec2(0.5, 1.0), 0.0,
			0.0, 360.0, 0.0, vec2(1.0), 0.0, 0.0, 1.5, 0, vec2(1.0), vec2(0.6, 1.05), 0.0, 0.85, 1.0, 1.2, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 22u, 1, 6, vec2(0.0, 0.6), vec2(0.5, 1.0), vec2(0.4, 0.8), 0.0,
			0.0, 360.0, 0.6, vec2(1.0, 0.25), 0.0, 0.0, 1.0, 4, vec2(2.0, 1.0), vec2(1.0, 0.5), 0.05, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
