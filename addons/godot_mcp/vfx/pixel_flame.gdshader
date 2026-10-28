shader_type canvas_item;
render_mode unshaded;
#include "res://addons/godot_mcp/vfx/pixel_vfx.gdshaderinc"

// Flame (campfire, torch): a flickering tongue of fire, embers rising, wisps of smoke above. Loops.
uniform vec2 canvas = vec2(32.0, 48.0);
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
	vec2 base = vec2(0.0, 1.25);
	k = px_span(t, 0.0, 1.0);
	if (k >= 0.0) {
		px_paint(col, px_puffs(p, t, k, looping, s, 3, vec2(0.0, -0.6), 0.2, 0.6, 0.8, 0.08, 0.22, vec2(0.5, 0.9), 0.0, 0.45),
			smoke_ramp, smoke_bands, 0.1, 0.0, cell);
		px_paint(col, px_flame(px_frame_of(p, base, 0.0, 1.0), t, s + 11u, 0.55, 2.6), main_ramp, main_bands, 0.1, 0.0, cell);
		px_paint(col, px_particles(cell, canvas, t, k, looping, s + 22u, 1, 6, vec2(0.0, 0.3), vec2(0.8, 1.5), vec2(0.4, 0.8), 0.0,
			0.0, 360.0, 0.4, vec2(1.0), 0.0, 0.0, 1.0, 0, vec2(1.0), vec2(1.0, 0.35), 0.08, 0.0, 0.0, 0.0, 0.0, 0), spark_ramp, spark_bands, 0.1, 0.0, cell);
	}
	COLOR = col;
}
