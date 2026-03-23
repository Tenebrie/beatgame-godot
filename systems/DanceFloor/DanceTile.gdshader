shader_type spatial;

uniform float ImpactProgress : hint_range(0.0, 1.0);
uniform float TelegraphProgress : hint_range(0.0, 1.0);
uniform vec3 BaseColor : source_color = vec3(0.8, 0.8, 0.8);
uniform vec3 TelegraphColor : source_color = vec3(0.5, 0.3, 0.1);
uniform vec3 ImpactColor : source_color = vec3(0.4, 0.05, 0.05);

void fragment() {
	float fillValue = TelegraphProgress / 2.0;
	float minValue = 1.0 - fillValue - 0.5;
	float maxValue = fillValue + 0.5;
	
	//vec2 d = max(vec2(minValue) - UV, UV - vec2(maxValue));
	//float dist = max(d.x, d.y);
	vec2 center = (vec2(minValue) + vec2(maxValue)) * 0.5;
    vec2 halfSize = (vec2(maxValue) - vec2(minValue)) * 0.5;
    float radius = 0.00; // corner radius in UV units
    vec2 d = abs(UV - center) - halfSize + vec2(radius);
    float dist = length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0) - radius;
	float telegraphMask = 1.0 - smoothstep(-0.005, 0.005, dist);
    ALBEDO = mix(BaseColor, TelegraphColor, telegraphMask);
    ALBEDO = mix(ALBEDO, ImpactColor, ImpactProgress);
	//if (UV.x >= minValue && UV.x <= maxValue && UV.y >= minValue && UV.y <= maxValue) {
		//ALBEDO = TelegraphColor;
	//} else {
		//ALBEDO = BaseColor;
	//}
	//ALBEDO = mix(ALBEDO, ImpactColor, ImpactProgress);
}
