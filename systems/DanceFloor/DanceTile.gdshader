shader_type spatial;

uniform float ImpactProgress : hint_range(0.0, 1.0);
uniform float TelegraphProgress : hint_range(0.0, 1.0);
uniform vec3 BaseColor : source_color = vec3(0.8, 0.8, 0.8);
uniform vec3 TelegraphColor : source_color = vec3(0.5, 0.3, 0.1);
uniform vec3 ImpactColor : source_color = vec3(0.4, 0.05, 0.05);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float fillValue = TelegraphProgress / 2.0;
	float minValue = 1.0 - fillValue - 0.5;
	float maxValue = fillValue + 0.5;
	//float dist = (UV.x - 0.5) * (UV.x - 0.5) + (UV.y - 0.5) * (UV.y - 0.5);
	if (UV.x >= minValue && UV.x <= maxValue && UV.y >= minValue && UV.y <= maxValue) {
	//if (dist < TelegraphProgress / 2.0) {
		ALBEDO = TelegraphColor;
	} else {
		ALBEDO = BaseColor;
	}
	ALBEDO = mix(ALBEDO, ImpactColor, ImpactProgress);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
