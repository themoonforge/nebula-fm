shader_type canvas_item;

uniform float twinkle_speed = 2.0; // Speed of the twinkling effect
uniform float min_brightness = 0.2; // Minimum brightness (0.0 = fully dark, 1.0 = full brightness)
uniform float grid_size = 32.0; // Size of grid cells for grouping stars together

// Simple hash function to generate pseudo-random values
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Get the original texture color
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Check if pixel is non-black (has any color value above a small threshold)
    float brightness = max(max(tex_color.r, tex_color.g), tex_color.b);
    
    if (brightness > 0.01) {
        // Create grid cells - stars in the same cell will twinkle together
        vec2 grid_uv = floor(UV * grid_size);
        
        // Generate unique random offset for this grid cell
        float random_offset = hash(grid_uv) * 6.28318; // Random phase offset (0 to 2*PI)
        
        // Calculate twinkling factor with unique timing per grid cell
        float twinkle = sin(TIME * twinkle_speed + random_offset) * 0.5 + 0.5;
        
        // Map twinkle to range between min_brightness and 1.0
        twinkle = mix(min_brightness, 1.0, twinkle);
        
        // Apply twinkling to the color while preserving alpha
        COLOR = vec4(tex_color.rgb * twinkle, tex_color.a);
    } else {
        // Keep black pixels black
        COLOR = tex_color;
    }
}