shader_type spatial;

// Trippy dark purple space background
// All hashing is integer-based — no sin(dot()) anywhere

render_mode unshaded, cull_disabled;

uniform float time_scale : hint_range(0.01, 1.0) = 0.12;
uniform float zoom : hint_range(1.0, 30.0) = 3.0;
uniform float warp_intensity : hint_range(0.0, 5.0) = 1.8;
uniform float star_density : hint_range(0.0, 300.0) = 120.0;
uniform float star_brightness : hint_range(0.0, 2.0) = 0.7;
uniform vec3 color_deep : source_color = vec3(0.02, 0.0, 0.06);
uniform vec3 color_purple : source_color = vec3(0.25, 0.05, 0.35);
uniform vec3 color_accent : source_color = vec3(0.4, 0.1, 0.55);
uniform vec3 color_highlight : source_color = vec3(0.15, 0.05, 0.4);

// --- Stable integer-based hashing ---

// PCG-style hash via Jarzynski & Olano
uint pcg(uint v) {
	uint state = v * 747796405u + 2891336453u;
	uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
	return (word >> 22u) ^ word;
}

float hash_stable(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)));
	uint h = pcg(q.x + pcg(q.y));
	return float(h) / float(0xFFFFFFFFu);
}

float hash_stable2(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)));
	uint h = pcg(q.x * 1299709u + pcg(q.y * 1500450271u));
	return float(h) / float(0xFFFFFFFFu);
}

// --- Value noise with quintic interpolation ---

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	// Quintic smoothstep
	f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

	float a = hash_stable(i);
	float b = hash_stable(i + vec2(1.0, 0.0));
	float c = hash_stable(i + vec2(0.0, 1.0));
	float d = hash_stable(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 3-octave FBM — big smooth blobs
float fbm3(vec2 p) {
	float val = 0.0;
	val += 0.50 * noise(p);
	val += 0.25 * noise(p * 2.0 + vec2(1.7, 9.2));
	val += 0.125 * noise(p * 4.0 + vec2(5.3, 2.8));
	return val / 0.875;
}

// --- Warped FBM (the trippy part) ---

float warped_fbm(vec2 p, float t) {
	vec2 q = vec2(
		fbm3(p),
		fbm3(p + vec2(5.2, 1.3))
	);
	vec2 r = vec2(
		fbm3(p + warp_intensity * q + vec2(1.7, 9.2) + 0.15 * t),
		fbm3(p + warp_intensity * q + vec2(8.3, 2.8) + 0.126 * t)
	);
	return fbm3(p + warp_intensity * r);
}

float warped_fbm2(vec2 p, float t) {
	vec2 q = vec2(
		fbm3(p + vec2(3.1, 7.7)),
		fbm3(p + vec2(1.5, 4.2))
	);
	vec2 r = vec2(
		fbm3(p + warp_intensity * 0.8 * q + vec2(4.2, 0.6) + 0.11 * t),
		fbm3(p + warp_intensity * 0.8 * q + vec2(6.1, 3.9) + 0.09 * t)
	);
	return fbm3(p + warp_intensity * 0.8 * r);
}

// --- Stars ---

float stars(vec2 uv, float t) {
	float result = 0.0;

	vec2 grid = floor(uv * star_density);
	vec2 grid_uv = fract(uv * star_density);
	float h = hash_stable(grid + vec2(7.0, 13.0));
	if (h > 0.93) {
		vec2 center = vec2(
			hash_stable(grid + vec2(10.0, 0.0)),
			hash_stable(grid + vec2(0.0, 20.0))
		);
		float d = length(grid_uv - center);
		float twinkle = sin(t * (2.0 + h * 4.0) + h * 6.283) * 0.5 + 0.5;
		twinkle = mix(0.3, 1.0, twinkle);
		result += smoothstep(0.04, 0.0, d) * twinkle * star_brightness;
	}

	float d2_density = star_density * 0.25;
	vec2 grid2 = floor(uv * d2_density);
	vec2 grid_uv2 = fract(uv * d2_density);
	float h2 = hash_stable(grid2 + vec2(100.0, 200.0));
	if (h2 > 0.96) {
		vec2 center2 = vec2(
			hash_stable(grid2 + vec2(110.0, 0.0)),
			hash_stable(grid2 + vec2(0.0, 120.0))
		);
		float d2 = length(grid_uv2 - center2);
		float twinkle2 = sin(t * (1.0 + h2 * 2.0) + h2 * 6.283) * 0.5 + 0.5;
		twinkle2 = mix(0.5, 1.0, twinkle2);
		float glow = smoothstep(0.1, 0.0, d2) * 0.25;
		float core = smoothstep(0.025, 0.0, d2);
		result += (glow + core) * twinkle2 * star_brightness * 1.3;
	}

	return result;
}

void fragment() {
	float t = TIME * time_scale;
	vec2 uv = (UV - 0.5) * zoom;

	// Slow rotation
	float rot = t * 0.06;
	float ca = cos(rot);
	float sa = sin(rot);
	vec2 ruv = vec2(uv.x * ca - uv.y * sa, uv.x * sa + uv.y * ca);

	// Breathing
	ruv *= 1.0 + sin(t * 0.3) * 0.04;

	// Two warped FBM layers
	float n1 = warped_fbm(ruv, t);
	float n2 = warped_fbm2(ruv * 0.7 + vec2(10.0), t * 0.8);
	float nebula = mix(n1, n2, 0.4);

	// Color mapping
	vec3 col = color_deep;
	col = mix(col, color_deep * 1.5, smoothstep(0.1, 0.3, nebula));
	col = mix(col, color_purple, smoothstep(0.3, 0.55, nebula));
	col = mix(col, color_accent, smoothstep(0.55, 0.75, nebula));
	col = mix(col, color_highlight, smoothstep(0.7, 0.9, nebula) * 0.5);

	// Edge glow
	float edge = abs(nebula - 0.5);
	col += color_accent * smoothstep(0.15, 0.0, edge) * 0.3;

	// Color cycling
	float cycle = sin(t * 0.25) * 0.5 + 0.5;
	vec3 shift = mix(color_purple, vec3(0.2, 0.02, 0.4), cycle);
	col = mix(col, shift, nebula * 0.12);

	// Stars
	float star_val = stars(UV, TIME * 0.8);
	float nebula_mask = 1.0 - smoothstep(0.35, 0.65, nebula);
	vec3 star_col = mix(vec3(0.7, 0.6, 1.0), vec3(1.0, 0.85, 1.0),
		hash_stable(floor(UV * star_density) + vec2(50.0, 60.0)));
	col += star_val * star_col * nebula_mask;

	// Vignette
	float vig = 1.0 - length(UV - 0.5) * 1.2;
	vig = smoothstep(0.0, 0.7, vig);
	col *= mix(0.4, 1.0, vig);

	// Clamp brightness
	col = min(col, vec3(0.55, 0.25, 0.65));

	ALBEDO = col;
}
