shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Fireball in flight toward +x (flip the node for -x): a hot head, a churning tail, embers shed behind.
// Loops; move the node to fly it.
uniform vec2 canvas = vec2(64.0, 32.0);
uniform float clock = 0.0; // seconds since the effect fired; its script steps it
uniform float fps = 12.0;
uniform int frames = 16;
uniform bool looping = false;
uniform int seed = 1;
uniform sampler2D main_ramp : filter_nearest, repeat_disable;
uniform int main_bands = 7;
uniform sampler2D spark_ramp : filter_nearest, repeat_disable;
uniform int spark_bands = 7;

void fragment() {
	ivec2 cell = px_cell(UV, canvas);
	vec2 p = px_units(cell, canvas);
	float t = px_time(clock, fps, frames, looping);
	uint s = uint(seed) * 2246822519u;
	vec4 col = vec4(0.0);
	float k;
	vec2 head = vec2(1.0, 0.0);
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 11u, 0, 10, head, vec2(1.6, 3.0), vec2(0.35, 0.7), 0.0,
			180.0, 40.0, 0.15, vec2(1.0), 0.0, 1.0, 1.0, 0, vec2(2.0, 1.0), vec2(1.0, 0.4), 0.0, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
		px_paint(col, px_comet(p - head, t, s, 0.45, 2.4), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
