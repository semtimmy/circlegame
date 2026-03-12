shader_type canvas_item;

uniform vec4 color_primary : source_color = vec4(0.1, 0.0, 0.3, 1.0);
uniform vec4 color_secondary : source_color = vec4(0.0, 0.4, 0.6, 1.0);
uniform vec4 color_accent : source_color = vec4(0.5, 0.1, 0.8, 1.0);
uniform float swirl_offset = 0.0;
uniform float swirl_intensity : hint_range(0.0, 20.0, 0.1) = 8.0;
uniform int swirl_arms : hint_range(1, 8) = 3;

// Hash-based pseudo noise (no texture needed)
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float val = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 5; i++) {
		val += amp * noise(p);
		p *= 2.1;
		amp *= 0.5;
	}
	return val;
}

void fragment() {
	vec2 uv = UV - 0.5;
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);

	// Warp the UV with drifting fbm noise to break up uniformity
	float t = swirl_offset * 0.3;
	vec2 noise_uv = uv * 4.0 + vec2(t * 0.7, t * -0.5);
	float warp_x = fbm(noise_uv) - 0.5;
	float warp_y = fbm(noise_uv + vec2(5.2, 1.3)) - 0.5;
	vec2 warped_uv = uv + vec2(warp_x, warp_y) * 0.15;

	float warped_dist = length(warped_uv);
	float warped_angle = atan(warped_uv.y, warped_uv.x);

	// Vortex distortion on the warped coordinates
	float twist = swirl_intensity / (warped_dist + 0.1) * 0.1;
	float vortex_angle = warped_angle + twist - swirl_offset;

	// Spiral arms with non-uniform thickness via noise
	float arm_noise = fbm(vec2(vortex_angle * 2.0, warped_dist * 6.0) + t);
	float arms = sin(vortex_angle * float(swirl_arms) + arm_noise * 2.5) * 0.5 + 0.5;

	// Radial turbulence pulled into the vortex
	float ripple = fbm(vec2(warped_dist * 12.0 - swirl_offset * 2.0, vortex_angle * 3.0));

	// Combine
	float pattern = arms * 0.6 + ripple * 0.4;

	// Color mixing
	vec3 col = mix(color_primary.rgb, color_secondary.rgb, pattern);
	float center_glow = smoothstep(0.35, 0.0, dist);
	col = mix(col, color_accent.rgb, center_glow * 0.8);
	col += color_accent.rgb * arms * center_glow * 0.4;

	// Vignette
	float vignette = 1.0 - smoothstep(0.3, 0.72, dist);
	col *= vignette;

	COLOR = vec4(col, 1.0);
}
