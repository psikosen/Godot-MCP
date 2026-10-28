shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Hit spark: a spiky star that pops and hollows out, a quick ring, sparks and a one-frame flash.
uniform vec2 canvas = vec2(48.0, 48.0);
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
	k = px_span(t, 0.0, 0.6);
	if (k >= 0.0) {
		px_paint(col, px_ring(p, k, s, 0.2, 0.92, 0.12, 0.5), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_star(p, k, s + 11u, 8.0, 0.9, 0.28, 1.4), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, k, k, false, s + 22u, 0, 9, vec2(0.0), vec2(2.0, 3.2), vec2(0.3, 0.6), 0.0,
			0.0, 360.0, 0.05, vec2(1.0), 0.0, 3.0, 1.0, 1, vec2(2.0), vec2(1.0, 0.55), 0.0, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
		px_paint(col, px_flash(p, k / 0.15, 0.38) * step(k, 0.15), main_ramp, main_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
