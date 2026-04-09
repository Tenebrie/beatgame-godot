shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler3D CloudNoise;
uniform sampler3D MacroNoise;
uniform sampler2D DepthTexture : hint_depth_texture;
uniform float Brightness: hint_range(0.0, 25.0, 0.01) = 1.0;
uniform float ExtraBrightness: hint_range(0.0, 5.0, 0.05) = 1.0;
uniform float Coverage: hint_range(0.0, 3.0, 0.01) = 0.5;
uniform float CloudSharpness: hint_range(1.0, 3.0, 0.05) = 2.0;
uniform float StepSize: hint_range(0.01, 3.0, 0.005) = 2.0;
uniform float SamplerScale: hint_range(0.5, 100.0, 0.5) = 20.0;
uniform float WindStrength: hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float LayerSpeedDifference: hint_range(0.0, 5.0, 0.1) = 1.0;

uniform vec3 Tint: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 DenseTint: source_color = vec3(0.6, 0.65, 0.7);
uniform float DenseTintModifier = 1.0;
uniform vec3 BoxHalfSize = vec3(2.5, 2.5, 2.5);
uniform vec3 WindDirection = vec3(1.0, 0.0, 0.5);
varying vec3 VertexPosition;

void vertex() {
	VertexPosition = VERTEX;
}

float sampleCloudDensity(int i, vec3 pos, vec3 worldPos, vec3 windOffset, float microSample, float macroSample) {
	vec3 q = abs(pos) - BoxHalfSize;
	float box_dist = length(max(q, vec3(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);

	float local_coverage = Coverage - (macroSample - 0.5) * 1.5;
	float current = max(microSample - 1.0 + local_coverage, 0.0);
	if (current <= 0.0) {
		return 0.0;
	}
	current = pow(current, CloudSharpness);
	return current * Brightness * StepSize * 0.01;
}

void fragment() {
	vec3 cam_local = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	bool inside = all(lessThan(abs(cam_local), BoxHalfSize));
	vec3 ray_start = inside ? cam_local : VertexPosition;
	vec3 ray_dir = normalize((inverse(VIEW_MATRIX * MODEL_MATRIX) * vec4(VIEW, 0.0)).xyz);
	int i = 0;
	float density = 0.0;
	vec3 pos = ray_start;

	float camDist = length(cam_local - ray_start);
	float stepSizeModifier = max(1.0, camDist * 0.01);

	float scene_depth = texture(DepthTexture, SCREEN_UV).r;
	vec4 ndc = vec4(SCREEN_UV * 2.0 - 1.0, scene_depth, 1.0);
	vec4 view_pos = INV_PROJECTION_MATRIX * ndc;
	view_pos.xyz /= view_pos.w;
	float scene_dist = -view_pos.z;
	float transmittance = 1.0;
	vec3 light_energy = vec3(0.0);

	float lastMicroSample;
	float lastMacroSample;

	bool finalIteration = false;

	for (int i = 0; i < 500; i++) {
		stepSizeModifier *= 1.005;
		pos -= ray_dir * StepSize * stepSizeModifier;
		//float jitter = fract(dot(SCREEN_UV * 1000.0, vec2(0.754877, 0.569840)) + TIME * 0.61803398875);
		//pos -= ray_dir * StepSize * jitter;
		vec3 worldPos = (MODEL_MATRIX * vec4(pos, 1.0)).xyz;
		vec3 windOffset = WindDirection * WindStrength * TIME;

		vec4 ray_view = VIEW_MATRIX * MODEL_MATRIX * vec4(pos, 1.0);
		float ray_depth = -ray_view.z;
		if (ray_depth > scene_dist) break;

		vec3 uv = worldPos / SamplerScale + windOffset;
		lastMicroSample = texture(CloudNoise, uv).r;
		if (i % 8 == 0) {
			vec3 macroUV = worldPos / SamplerScale / 9.7143 + windOffset / (9.7143 * (LayerSpeedDifference + 1.0));
		    lastMacroSample = texture(MacroNoise, macroUV).r;
		}

		float sample_density = sampleCloudDensity(i, pos, worldPos, windOffset, lastMicroSample, lastMacroSample) * stepSizeModifier;
		if (sample_density > 0.0) {
		    transmittance *= exp(-sample_density * 8.0); // tweak multiplier
	    	light_energy += sample_density * transmittance;
		}
		if (transmittance < 0.05) break;

		//if (density >= 0.95) {
			//break;
		//}

		if (finalIteration) {
			break;
		}

		// Out of bounds
		if (pos.x > BoxHalfSize.x
			|| pos.x < -BoxHalfSize.x
			|| pos.y > BoxHalfSize.y
			|| pos.y < -BoxHalfSize.y
			|| pos.z > BoxHalfSize.z
			|| pos.z < -BoxHalfSize.z) {
				finalIteration = true;
		}
	}

	float energyFactor = min((1.0 - transmittance) * DenseTintModifier, 1.0);
	ALBEDO = mix(Tint, DenseTint, energyFactor) * ExtraBrightness;
	ALPHA = min(1.0, 1.0 - transmittance);
}