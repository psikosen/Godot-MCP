// Pixel-art VFX for build_pixel_vfx. Every layer returns a heat value for one art pixel, and
// px_paint cuts heat into the hard colour bands of a ramp (dark to light). Hard bands on a real
// pixel grid are what make an effect read as hand-made pixel art instead of a soft glow.
// Units: p is in half-canvas units from the centre (1 reaches the edge of the shorter side, y down).
// build_pixel_vfx pastes this file into each effect's shader, so a scene needs no addon files.

const float PX_DARK = 1000.0; // heat that paints a ramp's darkest colour (void cores)
const float PX_BAYER[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);

// ---------- grid and time ----------

ivec2 px_cell(vec2 uv, vec2 canvas) {
	return ivec2(floor(uv * canvas));
}

vec2 px_units(ivec2 cell, vec2 canvas) {
	return (vec2(cell) + 0.5 - canvas * 0.5) / (min(canvas.x, canvas.y) * 0.5);
}

int px_frame(float clock, float fps) {
	return int(floor(clock * fps + 0.001));
}

// Effect time 0..1, stepped at fps like drawn frames. One-shots return -1 once they are over.
float px_time(float clock, float fps, int frames, bool looping) {
	int f = px_frame(clock, fps);
	if (looping) {
		return float(f % frames) / float(frames);
	}
	return f >= frames ? -1.0 : float(f) / float(max(frames - 1, 1));
}

// A layer's own time 0..1 inside [t0, t1] of the effect, or -1 while it is not playing.
float px_span(float t, float t0, float t1) {
	float k = (t - t0) / max(t1 - t0, 0.0001);
	return (t < 0.0 || k < 0.0 || k > 1.0) ? -1.0 : k;
}

// ---------- random and noise ----------

uint px_pcg(uint v) {
	uint state = v * 747796405u + 2891336453u;
	uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
	return (word >> 22u) ^ word;
}

float px_rand(int a, int b, uint s) {
	return float(px_pcg(px_pcg(px_pcg(s) ^ uint(a)) ^ uint(b) * 2654435761u) >> 8u) / 16777216.0;
}

int px_mod(int i, int period) {
	return period > 0 ? i - period * int(floor(float(i) / float(period))) : i;
}

float px_lattice(int x, int y, int z, ivec3 per, uint s) {
	return float(px_pcg(px_pcg(px_pcg(s ^ uint(px_mod(x, per.x))) ^ uint(px_mod(y, per.y))) ^ uint(px_mod(z, per.z))) >> 8u) / 16777216.0;
}

// Smooth value noise, 0..1. An axis with a period above 0 tiles, so a loop's last frame meets its first.
float px_noise(vec3 p, uint s, ivec3 per) {
	vec3 i = floor(p);
	vec3 f = p - i;
	vec3 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	ivec3 c = ivec3(i);
	float x00 = mix(px_lattice(c.x, c.y, c.z, per, s), px_lattice(c.x + 1, c.y, c.z, per, s), u.x);
	float x10 = mix(px_lattice(c.x, c.y + 1, c.z, per, s), px_lattice(c.x + 1, c.y + 1, c.z, per, s), u.x);
	float x01 = mix(px_lattice(c.x, c.y, c.z + 1, per, s), px_lattice(c.x + 1, c.y, c.z + 1, per, s), u.x);
	float x11 = mix(px_lattice(c.x, c.y + 1, c.z + 1, per, s), px_lattice(c.x + 1, c.y + 1, c.z + 1, per, s), u.x);
	return mix(mix(x00, x10, u.y), mix(x01, x11, u.y), u.z);
}

// Layered noise, stretched back to about 0..1 (summed octaves crowd toward the middle).
float px_fbm(vec3 p, uint s, int octaves, ivec3 per) {
	float sum = 0.0;
	float weight = 0.0;
	float amp = 1.0;
	for (int o = 0; o < octaves; o++) {
		sum += px_noise(p, s + uint(o) * 7717u, per) * amp;
		weight += amp;
		amp *= 0.5;
		p *= 2.0;
		per *= 2;
	}
	return clamp((sum / weight - 0.5) * 1.7 + 0.5, 0.0, 1.0);
}

float px_ease_out(float t, float power) {
	return 1.0 - pow(1.0 - clamp(t, 0.0, 1.0), power);
}

// ---------- painting ----------

// A point in a layer's own frame: about an anchor, turned (degrees), y divided by squash (about 0.35
// lays a ring or glow flat on the ground).
vec2 px_frame_of(vec2 p, vec2 anchor, float angle, float squash) {
	vec2 d = p - anchor;
	float c = cos(radians(angle));
	float s = sin(radians(angle));
	return vec2(d.x * c + d.y * s, (d.y * c - d.x * s) / squash);
}

// Cuts heat into the ramp's bands and paints over col. Heat below cut stays clear; dither breaks the
// band edges with an ordered (Bayer) pattern.
void px_paint(inout vec4 col, float heat, sampler2D ramp, int bands, float cut, float dither, ivec2 cell) {
	if (heat <= 0.0) {
		return;
	}
	int band = 0;
	if (heat < PX_DARK) {
		float per_band = float(bands) / (1.0 - cut);
		heat += dither * ((PX_BAYER[(cell.x & 3) + ((cell.y & 3) << 2)] + 0.5) / 16.0 - 0.5) / per_band;
		if (heat < cut) {
			return;
		}
		band = min(int((heat - cut) * per_band), bands - 1);
	}
	col = vec4(texture(ramp, vec2((float(band) + 0.5) / float(bands), 0.5)).rgb, 1.0);
}

// ---------- shapes (heat at a point in the layer's frame) ----------

// One or two white-hot frames at the moment of impact.
float px_flash(vec2 p, float k, float r) {
	float d = length(p) / (r * (0.75 + 0.35 * k));
	return d >= 1.0 ? 0.0 : 1.45 * (1.0 - pow(d, 6.0)) * (1.0 - 0.5 * k);
}

// A shockwave: grows fast, thins, dims and tears into arcs.
float px_ring(vec2 p, float k, uint s, float r0, float r1, float width, float tear) {
	float r = mix(r0, r1, px_ease_out(k, 3.5));
	float w = width * (1.0 - 0.85 * k) + 0.015;
	float d = length(p);
	float dd = abs(d - r) / w;
	if (dd >= 1.0) {
		return 0.0;
	}
	float a = atan(p.y, p.x);
	if (px_fbm(vec3(cos(a) * 2.5, sin(a) * 2.5, k * 1.5), s, 2, ivec3(0)) < tear * pow(k, 1.2)) {
		return 0.0;
	}
	return (1.0 - dd * dd) * (1.05 - 0.55 * k) * (d < r ? 0.85 : 1.0);
}

// A fireball: swells with a lumpy edge, cools down the ramp, then gets eaten into chunks.
float px_fireball(vec2 p, float k, uint s, float size, float grow) {
	float a = atan(p.y, p.x);
	float R = size * (0.15 + 0.85 * px_ease_out(k / grow, 2.5)) * (1.0 + 0.1 * max(k - grow, 0.0));
	R *= 0.8 + 0.4 * px_fbm(vec3(cos(a) * 1.3, sin(a) * 1.3, k * 0.8), s + 3u, 2, ivec3(0));
	float d = length(p) / R;
	if (d > 1.2) {
		return 0.0;
	}
	if (px_fbm(vec3(p * 2.1 + 17.0, k * 1.2), s + 7u, 2, ivec3(0)) < smoothstep(0.25, 1.0, k) * 1.05) {
		return 0.0;
	}
	float heat = 1.55 * (1.0 - d) + (px_fbm(vec3(p * 2.6, k * 1.8), s, 3, ivec3(0)) - 0.5) * 1.1;
	return heat * (1.0 - 0.65 * smoothstep(0.1, 0.9, k));
}

// A funnel whose bands wrap round it and climb; loops (ph 0..1). x is read as a point on a cylinder
// (asin), so bands bunch at the edges and the funnel reads as round.
float px_funnel(vec2 p, float ph, uint s, float base_w, float top_w, float H, float twist, float sway) {
	float y = -p.y / H;
	if (y < 0.0 || y > 1.0) {
		return 0.0;
	}
	float centre = sway * sin(TAU * (y * 0.9 - ph));
	float u = (p.x - centre) / (base_w + (top_w - base_w) * pow(y, 1.5));
	if (abs(u) >= 1.0) {
		return 0.0;
	}
	float around = asin(u) / (PI * 0.5);
	float bands = smoothstep(0.2, 0.8, 0.5 + 0.5 * sin(PI * around * 1.6 + TAU * (y * twist - ph * 2.0)));
	float n = px_fbm(vec3(u * 1.8, y * H * 3.2 - ph * 16.0, 0.5), s, 2, ivec3(0, 8, 0));
	float heat = 0.28 + 0.85 * bands * (0.65 + (n - 0.5) * 0.8);
	return heat * (1.0 - 0.5 * u * u) * (1.0 - smoothstep(0.86, 1.0, y));
}

// A spiral disc turning once per loop (ph 0..1); a dark core with a bright rim reads as a black hole.
float px_spiral(vec2 p, float ph, uint s, float R, float core, float arms, float twist, bool dark_core) {
	float rad = length(p) / R;
	if (rad >= 1.0) {
		return 0.0;
	}
	if (rad < core) {
		return dark_core ? PX_DARK : 1.4 - rad / core * 0.4;
	}
	float a = atan(p.y, p.x) - TAU * ph;
	float arm = 0.5 + 0.5 * cos(arms * a + TAU * twist * rad);
	vec2 q = vec2(cos(a), sin(a)) * rad;
	float n = px_fbm(vec3(q * 3.0, 0.7), s, 2, ivec3(0));
	float heat = (0.3 + 0.9 * arm * (0.45 + n)) * smoothstep(core, core + 0.12, rad) * pow(1.0 - rad, 0.5);
	return dark_core ? max(heat, 1.2 * (1.0 - smoothstep(core, core + 0.08, rad))) : heat;
}

// A column of light rising from a glowing base; one-shot (k) or loop (looping, ph).
float px_column(vec2 p, float k, float ph, bool looping, uint s, float W, float H, float grow) {
	float rise = looping ? 1.0 : px_ease_out(k / grow, 3.0);
	float wide = looping ? 1.0 : (1.0 - smoothstep(0.5, 1.0, k)) * (0.55 + 0.45 * smoothstep(0.0, 0.12, k));
	if (W * wide < 0.01) {
		return 0.0;
	}
	float y = -p.y / max(H * rise, 0.02);
	float heat = 0.0;
	if (y >= 0.0 && y <= 1.0) {
		float n = px_fbm(vec3(p.x * 4.0, y * H * 3.0 - ph * 16.0, 0.4), s, 3, ivec3(0, 8, 0));
		float q = abs(p.x) / (W * wide * (0.85 + 0.35 * n) * (1.0 - 0.2 * y));
		if (q < 1.0) {
			heat = (1.0 - q * q) * (1.0 - y * y * y) * 1.1 + (n - 0.5) * 0.5;
		}
	}
	float base = length(vec2(p.x / (W * wide * 1.7), p.y / (W * wide * 0.5)));
	return max(heat, (1.0 - base) * 1.05);
}

// ---------- smoke ----------

// Puffs that swell, rise, drift and dissolve into noise as they age.
float px_puffs(vec2 p, float ph, float k, bool looping, uint s, int count, vec2 at, float spread, float flatness,
		float rise, float r0, float r1, vec2 life, float emit, float gain) {
	float heat = 0.0;
	for (int i = 0; i < count; i++) {
		float lf = mix(life.x, life.y, px_rand(i, 0, s));
		float born = looping ? (float(i) + px_rand(i, 1, s) * 0.6) / float(count) : px_rand(i, 1, s) * emit;
		float age = looping ? fract(ph - born) / lf : (k - born) / lf;
		if (age < 0.0 || age > 1.0) {
			continue;
		}
		float grow = px_ease_out(age, 3.0);
		vec2 c = at + vec2((px_rand(i, 2, s) - 0.5) * 2.0 * spread + (px_rand(i, 3, s) - 0.5) * 0.25 * age,
			(px_rand(i, 4, s) - 0.5) * spread * flatness - rise * grow);
		float d = length(p - c) / ((r0 + (r1 - r0) * grow) * (0.8 + 0.4 * px_rand(i, 5, s)));
		if (d >= 1.0) {
			continue;
		}
		float n = px_fbm(vec3(p * 3.4 + float(i) * 5.3, age * 1.4), s, 2, ivec3(0));
		if (n < pow(age, 1.3)) {
			continue;
		}
		heat = max(heat, ((1.0 - d) * 0.85 + (n - 0.5) * 0.75 + 0.25) * gain * (1.0 - 0.45 * age));
	}
	return heat;
}

// ---------- particles (drawn in art pixels) ----------

// One particle at art-pixel position xy. Shapes: 0 dot, 1 streak, 2 chunk, 3 cross, 4 star.
float px_stamp(ivec2 cell, vec2 xy, int shape, int size, float v, vec2 vel, float age, float r) {
	ivec2 at = ivec2(round(xy));
	ivec2 d = cell - at;
	if (shape == 1) {
		// A short line trailing back along the motion, cooling toward its tail.
		float speed = max(length(vel), 0.0001);
		vec2 tail = round(-vel / speed * max(1.0, round(float(size) * speed * 0.6)));
		vec2 q = vec2(d);
		float t = clamp(dot(q, tail) / max(dot(tail, tail), 0.0001), 0.0, 1.0);
		vec2 off = abs(q - tail * t);
		return max(off.x, off.y) <= 0.5 ? v * (1.0 - 0.55 * t) : 0.0;
	}
	if (shape == 2) {
		// A tumbling chunk: a square that drops two corners every other frame.
		if (d.x < 0 || d.y < 0 || d.x >= size || d.y >= size) {
			return 0.0;
		}
		if (size > 2 && int(floor(age * 9.0 + r * 4.0)) % 2 == 1 && (d.x + d.y == 0 || d.x + d.y == 2 * size - 2)) {
			return 0.0;
		}
		return v * (d == ivec2(0) ? 1.15 : 0.8);
	}
	if (shape == 3 || shape == 4) {
		// A plus; a star grows and shrinks its arms over its life.
		int arm = shape == 3 ? max(1, size) : max(1, int(round(float(size) * sin(PI * clamp(age, 0.0, 1.0)))));
		int k = abs(d.x) + abs(d.y);
		if ((d.x != 0 && d.y != 0) || k > arm) {
			return 0.0;
		}
		return shape == 4 ? v * (k == 0 ? 1.1 : 1.0 - float(k) / float(arm + 1)) : v;
	}
	float radius = float(size) * 0.5;
	float dist = length(vec2(d));
	return size <= 1 ? (d == ivec2(0) ? v : 0.0) : (dist * dist <= radius * radius + 0.3 ? v * (1.0 - 0.25 * dist / (radius + 0.5)) : 0.0);
}

// Emitters. mode: 0 burst (drag, gravity), 1 rise, 2 orbit, 3 implode. side (orbit only): -1 draws the
// far half, 1 the near half, 0 both, so debris can pass behind a funnel.
float px_particles(ivec2 cell, vec2 canvas, float ph, float k, bool looping, uint s, int mode, int count,
		vec2 at, vec2 speed, vec2 life, float emit, float dir, float spread, float area, vec2 area_scale,
		float gravity, float drag, float squash, int shape, vec2 size, vec2 heat, float wiggle,
		float radius, float turns, float swirl, float twinkle, int side) {
	float S = min(canvas.x, canvas.y) * 0.5;
	float best = 0.0;
	for (int i = 0; i < count; i++) {
		float lf = mix(life.x, life.y, px_rand(i, 0, s));
		float age = looping ? fract(ph - (float(i) + px_rand(i, 1, s) * 0.7) / float(count)) / lf
			: (k - px_rand(i, 1, s) * emit) / lf;
		if (age < 0.0 || age > 1.0) {
			continue;
		}
		float t = age * lf;
		float sp = mix(speed.x, speed.y, px_rand(i, 2, s));
		float ang = radians(dir + (px_rand(i, 3, s) - 0.5) * spread);
		vec2 heading = vec2(cos(ang), sin(ang));
		float spin = px_rand(i, 4, s) * TAU;
		float far = sqrt(px_rand(i, 5, s));
		float r = px_rand(i, 6, s);
		vec2 start = at + vec2(cos(spin) * area_scale.x, sin(spin) * squash * area_scale.y) * far * area;
		vec2 pos;
		vec2 vel;
		if (mode == 1) {
			pos = start + vec2(wiggle * sin(TAU * (age * 1.4 + r)) + heading.x * sp * t * 0.2, -sp * t);
			vel = vec2(0.0, -sp);
		} else if (mode == 2) {
			float a = spin + TAU * turns * (looping ? ph : k);
			if (side != 0 && (sin(a) < 0.0 ? -1 : 1) != side) {
				continue;
			}
			pos = at + vec2(cos(a), sin(a) * squash) * radius * mix(0.75, 1.1, far);
			vel = vec2(-sin(a), cos(a) * squash);
		} else if (mode == 3) {
			float pull = age * age * age;
			float a = spin + swirl * pull;
			pos = at + vec2(cos(a), sin(a) * squash) * radius * mix(0.6, 1.0, far) * (1.0 - pull);
			vel = -vec2(cos(a), sin(a) * squash) * 2.0;
		} else {
			float travel = drag > 0.0 ? (1.0 - exp(-drag * t)) / drag : t;
			pos = start + vec2(heading.x * sp * travel, heading.y * sp * travel * squash + 0.5 * gravity * t * t);
			vel = vec2(heading.x, heading.y * squash) * sp * exp(-drag * t) + vec2(0.0, gravity * t);
		}
		float v = mix(heat.x, heat.y, age);
		if (twinkle > 0.0) {
			v *= 0.55 + 0.45 * abs(sin(TAU * (age * twinkle + r)));
		}
		int px = max(1, int(round(mix(size.x, size.y, age))));
		best = max(best, px_stamp(cell, canvas * 0.5 + pos * S - 0.5, shape, px, v, vel, age, r));
	}
	return best;
}

// Wind arcs circling an anchor, one turn per loop.
float px_gusts(ivec2 cell, vec2 canvas, float ph, uint s, int count, vec2 at, float r, float squash, float gain) {
	float S = min(canvas.x, canvas.y) * 0.5;
	float best = 0.0;
	for (int i = 0; i < count; i++) {
		float R = mix(0.35, 1.0, px_rand(i, 0, s)) * r;
		float span = mix(0.7, 1.5, px_rand(i, 1, s));
		float head = px_rand(i, 2, s) * TAU + TAU * ph;
		int steps = int(ceil(R * S * span));
		for (int m = 0; m <= steps; m++) {
			float a = head - float(m) / float(steps) * span;
			if (ivec2(round(canvas * 0.5 + (at + vec2(cos(a), sin(a) * squash) * R) * S - 0.5)) == cell) {
				best = max(best, gain * (1.0 - 0.7 * float(m) / float(steps)));
			}
		}
	}
	return best;
}

// ---------- lightning ----------

// Sideways offset of a jagged path at t (0..1): every level adds a tent between the new midpoints,
// the shape repeated midpoint splitting with random shifts gives.
float px_jag(float t, float len, float jag, int depth, uint s) {
	float off = 0.0;
	for (int level = 1; level <= depth; level++) {
		float n = exp2(float(level));
		int k = clamp(int(floor(t * n * 0.5)), 0, int(n * 0.5) - 1);
		off += (px_rand(level, k, s) - 0.5) * jag * len / exp2(float(level - 1)) * max(0.0, 1.0 - abs(t * n - float(2 * k + 1)));
	}
	return off;
}

// One jagged segment from a to b: 1 on the line (half width w), 0.5 in a one-pixel halo of width halo.
float px_jag_line(vec2 p, vec2 a, vec2 b, float jag, int depth, uint s, float w, float halo, float px) {
	vec2 ab = b - a;
	float len = length(ab);
	if (len < 0.0001) {
		return 0.0;
	}
	vec2 dir = ab / len;
	float t = dot(p - a, dir) / len;
	float h = px * 0.75 / len;
	if (t < -h || t > 1.0 + h) {
		return 0.0;
	}
	float o0 = px_jag(clamp(t - h, 0.0, 1.0), len, jag, depth, s);
	float o1 = px_jag(clamp(t + h, 0.0, 1.0), len, jag, depth, s);
	float side = dot(p - a, vec2(-dir.y, dir.x));
	float gap = max(0.0, max(min(o0, o1) - side, side - max(o0, o1)));
	return gap <= w ? 1.0 : (gap <= w + halo ? 0.5 : 0.0);
}

// Forked lightning from the top edge down to the anchor, re-rolled every frame.
float px_bolt(vec2 p, vec2 canvas, float k, int frame, uint s, int count, vec2 at, float spread, float jag, float fork) {
	float fade = 1.0 - smoothstep(0.35, 1.0, k);
	if (fade < 0.05) {
		return 0.0;
	}
	float px = 2.0 / min(canvas.x, canvas.y);
	uint fs = s + uint(frame) * 7919u;
	float top = -canvas.y / min(canvas.x, canvas.y) - 0.05;
	float reach = px_ease_out(k / 0.1, 4.0);
	float best = 0.0;
	for (int i = 0; i < count; i++) {
		uint bs = fs + uint(i) * 104729u;
		float sx = at.x + (px_rand(i, 0, fs) - 0.5) * spread;
		vec2 a = vec2(sx, top);
		vec2 b = mix(a, at, reach);
		best = max(best, px_jag_line(p, a, b, jag, 6, bs, px, px, px) * fade);
		vec2 ab = b - a;
		float len = length(ab);
		vec2 nrm = vec2(-ab.y, ab.x) / max(len, 0.0001);
		for (int j = 3; j < 61; j += 4) {
			if (px_rand(j, 9, bs) > fork) {
				continue;
			}
			float t0 = float(j) / 64.0;
			float t1 = float(j + 2) / 64.0;
			vec2 n0 = mix(a, b, t0) + nrm * px_jag(t0, len, jag, 6, bs);
			vec2 n1 = mix(a, b, t1) + nrm * px_jag(t1, len, jag, 6, bs);
			float ang = atan(n1.y - n0.y, n1.x - n0.x) + (px_rand(j, 10, bs) < 0.5 ? -1.0 : 1.0) * mix(0.4, 1.0, px_rand(j, 11, bs));
			vec2 tip = n0 + vec2(cos(ang), sin(ang)) * len * mix(0.12, 0.3, px_rand(j, 12, bs));
			best = max(best, px_jag_line(p, n0, tip, jag * 1.2, 3, bs + uint(j), px * 0.5, 0.0, px) * fade * 0.7);
		}
	}
	return best;
}

// ---------- more shapes ----------

// A sword arc: its head sweeps from a0 to a1 (radians, either way round), its tail chases it, and the
// crescent is thickest in the middle and sharp at both ends.
float px_arc(vec2 p, float k, uint s, float R, float th, float a0, float a1, float sweep) {
	float head = 0.12 + 0.88 * px_ease_out(k / sweep, 3.0);
	float tail = smoothstep(sweep * 0.4, 1.0, k) * 0.98;
	float rad = length(p);
	if (head <= tail + 0.01 || rad > R + 0.04 || rad < R - th * 2.0) {
		return 0.0;
	}
	float span = a1 - a0;
	float a = atan(p.y, p.x) - a0;
	float q = mod(span < 0.0 ? -a : a, TAU) / abs(span);
	if (q < tail || q > head) {
		return 0.0;
	}
	float u = (q - tail) / (head - tail);
	float w = th * pow(sin(PI * pow(u, 0.85)), 0.7) * (0.35 + 0.65 * (1.0 - smoothstep(0.45, 1.0, k)));
	float dr = R - rad;
	if (dr < -0.02 || dr > w) {
		return 0.0;
	}
	if (px_fbm(vec3(p * 5.0, k * 2.0), s, 2, ivec3(0)) < smoothstep(0.5, 1.0, k) * (1.0 - u) * 0.9) {
		return 0.0;
	}
	return (0.45 + 0.9 * (1.0 - dr / max(w, 0.001))) * (0.55 + 0.45 * u);
}

// A hit star: uneven spikes pop out fast, then the middle hollows out.
float px_star(vec2 p, float k, uint s, float points, float r, float inner, float sharp) {
	float R = r * px_ease_out(k / 0.25, 3.0) * (1.0 + 0.15 * k);
	float a = atan(p.y, p.x) / TAU * points;
	float f = abs(a - round(a)) * 2.0;
	float reach = R * mix(0.65, 1.1, px_rand(px_mod(int(round(a)), int(points)), 0, s));
	float d = length(p) / (reach * (inner + (1.0 - inner) * pow(1.0 - f, sharp)));
	if (d >= 1.0) {
		return 0.0;
	}
	float hollow = smoothstep(0.25, 1.0, k) * 1.6 * pow(max(0.0, 1.0 - length(p) / (R * 0.9)), 0.6);
	return ((1.0 - d) * 1.5 + 0.2 - hollow) * (1.0 - 0.4 * k);
}

// A projectile head flying toward +x with a streaming, flickering tail; loops (ph 0..1).
float px_comet(vec2 p, float ph, uint s, float r, float len) {
	float n = px_fbm(vec3(p.x * 3.0 + ph * 16.0, p.y * 3.0, 0.3), s, 2, ivec3(8, 0, 0));
	float heat = 0.0;
	float d = length(p) / r;
	if (d < 1.0) {
		heat = (1.0 - d * d) * 1.4 + 0.25 + (n - 0.5) * 0.3;
	}
	if (p.x < 0.0 && p.x > -len) {
		float along = -p.x / len;
		float w = r * pow(1.0 - along, 0.8) * (0.8 + 0.5 * n);
		float q = abs(p.y + sin(TAU * (along * 1.5 + ph * 2.0)) * 0.06 * along) / max(w, 0.001);
		if (q < 1.0) {
			heat = max(heat, (1.0 - q * q) * (1.1 - along * 0.9) + (n - 0.5) * 0.8);
		}
	}
	return heat;
}

// A beam from the anchor toward +x with a flaring, pulsing origin; its edges churn as it fires. Loops.
float px_beam(vec2 p, float ph, uint s, float len, float th, float cap) {
	float heat = 0.0;
	if (p.x >= -0.05 && p.x <= len) {
		float n = px_fbm(vec3(p.x * 2.5 - ph * 16.0, p.y * 2.0, 0.3), s, 2, ivec3(8, 0, 0));
		float T = th * (0.75 + 0.6 * n) * (1.0 - 0.2 * p.x / len) * (1.0 + 0.1 * sin(TAU * ph * 4.0));
		float q = abs(p.y) / max(T * sqrt(clamp((len - p.x) / 0.15, 0.0, 1.0)), 0.001);
		if (q < 1.0) {
			// A white-hot core line inside a coloured body.
			heat = (1.0 - q * q) * 0.82 + pow(1.0 - q, 4.0) * 0.45 + (n - 0.5) * 0.45;
		}
	}
	float d = length(p) / (cap * (1.0 + 0.12 * sin(TAU * ph * 3.0)));
	return max(heat, d < 1.0 ? (1.0 - d) * 1.3 : 0.0);
}

// 0 in the middle of a hexagonal cell, 1 on its border (cells `size` across).
float px_hex_edge(vec2 p, float size) {
	vec2 r = vec2(1.0, 1.7320508);
	vec2 a = mod(p / size, r) - r * 0.5;
	vec2 b = mod(p / size - r * 0.5, r) - r * 0.5;
	vec2 g = abs(dot(a, a) < dot(b, b) ? a : b);
	return max(dot(g, vec2(0.5, 0.8660254)), g.x) * 2.0;
}

// A shield bubble: a wavering rim, a fixed glint, and rings of light running out through its hex
// cells once per loop. The faint fill is meant to be dithered.
float px_bubble(vec2 p, float ph, float R, float rim, float cell, float fill) {
	float d = length(p) / R;
	if (d > 1.0 + rim) {
		return 0.0;
	}
	if (d > 1.0 - rim) {
		return 0.75 + 0.12 * sin(TAU * (atan(p.y, p.x) / TAU * 3.0 + ph));
	}
	if (length((p / R - vec2(-0.35, -0.42)) * vec2(1.0, 1.7)) < 0.17) {
		return 1.1;
	}
	float wave = 0.5 + 0.5 * cos(TAU * (d * 1.5 - ph));
	if (px_hex_edge(p, cell) > 0.8) {
		return 0.22 + 0.5 * wave * d;
	}
	return fill * (0.5 + d * d);
}

// A flame standing on its base (y = 0, up is -y): a tapering tongue that sways and flickers, licked
// upward by scrolling noise. Loops (ph 0..1).
float px_flame(vec2 p, float ph, uint s, float W, float H) {
	float y = -p.y / H;
	if (y < -0.15 || y > 1.1) {
		return 0.0;
	}
	float x = p.x / W - 0.12 * sin(TAU * (y * 0.8 - ph * 2.0)) * max(y, 0.0);
	float prof = y < 0.0 ? sqrt(max(0.0, 1.0 - (y / 0.15) * (y / 0.15))) : pow(1.0 - min(y, 1.0), 1.1);
	float side = 1.0 - abs(x) / max(prof, 0.02);
	if (side < -0.5) {
		return 0.0;
	}
	float n = px_fbm(vec3(x * W * 4.0, y * H * 3.0 - ph * 16.0, 0.5), s, 3, ivec3(0, 8, 0));
	return side * 0.9 + (n - 0.5) * 1.4 - max(y, 0.0) * 0.5 + 0.15;
}
