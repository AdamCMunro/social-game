shader_type canvas_item;

// --- Uniforms ---
uniform float progress : hint_range(0.0, 1.0) = 0.0; // 0.0 = fully visible, 1.0 = fully pruned
uniform float edge_thickness : hint_range(0.0, 0.2) = 0.05;
uniform float cosmic_thickness : hint_range(0.0, 0.3) = 0.12;

uniform vec4 glow_color : source_color = vec4(4.0, 1.2, 0.2, 1.0);     // Over-exposed HDR orange
uniform vec4 cosmic_color : source_color = vec4(0.2, 0.0, 0.5, 1.0);   // Void purple

uniform sampler2D noise_texture : repeat_enable, filter_linear_mipmap;
uniform vec2 noise_scale = vec2(2.0, 2.0);

void fragment() {

	vec4 base_color = texture(TEXTURE, UV);
	
	float noise_val = texture(noise_texture, UV * noise_scale).r;
	
	float sweep = UV.y - (noise_val * 0.2);
	
	float current_threshold = mix(-0.2, 1.2, progress);
	
	if (sweep < current_threshold) {
		discard;
	}
	
	float distance_from_cutoff = sweep - current_threshold;
	
	float edge_glow_mask = 1.0 - smoothstep(0.0, edge_thickness, distance_from_cutoff);
	float cosmic_mask = 1.0 - smoothstep(0.0, cosmic_thickness, distance_from_cutoff);
	
	vec3 final_rgb = mix(base_color.rgb, cosmic_color.rgb, cosmic_mask);
	final_rgb = mix(final_rgb, glow_color.rgb, edge_glow_mask);
	
	COLOR = vec4(final_rgb, base_color.a);
}