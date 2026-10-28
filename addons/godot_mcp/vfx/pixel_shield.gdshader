shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Shield bubble: a wavering rim, a glint, rings of light running out through hex cells, sparkles
// circling it. Loops; parent it to a character.
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
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_bubble(p, t, 0.82, 0.05, 0.17, 0.16), main_ramp, main_bands, 0.1, 0.9, cell);
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 11u, 2, 5, vec2(0.0), vec2(1.0), vec2(1.0), 0.0,
			0.0, 360.0, 0.0, vec2(1.0), 0.0, 0.0, 1.0, 4, vec2(1.0), vec2(1.0), 0.0, 0.86, 1.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
