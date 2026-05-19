shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.5;
uniform float outer_radius : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    // Center the UV coordinates (-0.5 to 0.5)
    vec2 uv = UV - 0.5;
    
    // Calculate distance from the center of the screen
    float dist = length(uv);
    
    // Create a smooth gradient between the inner and outer radii
    float alpha = smoothstep(inner_radius, outer_radius, dist);
    
    // Apply the color and mix the alpha
    COLOR = vec4(border_color.rgb, border_color.a * alpha);
}