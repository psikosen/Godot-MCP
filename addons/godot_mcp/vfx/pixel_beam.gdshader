shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Beam firing toward +x (flip the node for -x): a churning ray from a pulsing origin flare, with
// streaks racing along it. Loops.
uniform vec2 canvas = vec2(128.0, 32.0);
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
	vec2 origin = vec2(-3.0, 0.0);
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_beam(p - origin, t, s, 7.2, 0.42, 0.52), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 11u, 0, 14, origin + vec2(0.25, 0.0), vec2(5.0, 8.0), vec2(0.3, 0.6), 0.0,
			0.0, 14.0, 0.15, vec2(1.0), 0.0, 0.0, 1.0, 1, vec2(2.0), vec2(1.0, 0.6), 0.0, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
