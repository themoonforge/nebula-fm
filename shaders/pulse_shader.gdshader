shader_type canvas_item;

// --- Uniform Parameters ---
uniform float beat_speed : hint_range(0.1, 10.0) = 1.0; // Beats per second
uniform float pulse_strength : hint_range(0.0, 0.25) = 0.2; // How much to scale

// Pulse Mode Selector
// 0: Sine Pulse (Smooth)
// 1: Single Pulse (Sharp Spike & Trail)
// 2: Double Pulse (True Lub-Dub Heartbeat)
uniform int pulse_mode : hint_range(0, 2) = 0; 

vec2 pulse_uv(vec2 uv, float scale) {
    // Center UVs and scale around the middle
    return (uv - 0.5) / scale + 0.5;
}

// --- Mode 0: Smooth Sine Wave ---
float sine_pulse(float t) {
    return (sin(t * 2.0 * PI) * 0.5) + 0.5; // 0..1 smooth sine
}

// --- Mode 1: Sharp Single Pulse (Your Original Logic) ---
float single_pulse(float t) {
    float cycle = fract(t);
    float p = 0.0;
    
    // First (and highest) peak ramps up and stops at 0.2 cycle
    if (cycle < 0.2) {
        // Ramps up smoothly to 1.0 at 0.2
        p = smoothstep(0.0, 0.2, cycle) * 1.0; 
    } 
    // The trailing decay (from 0.6 down to 0.0) happens between 0.2 and 0.4
    else if (cycle < 0.4) {
        // sub goes from 0.0 to 1.0 over the range [0.2, 0.4]
        float sub = (cycle - 0.2) / 0.2;
        // p starts at 0.6 and fades to 0.0
        p = (1.0 - sub) * 0.6; 
    }
    // Else stays at 0 until next cycle
    return p;
}

// --- Mode 2: True Double Pulse (Lub-Dub) ---
float double_pulse(float t) {
    float cycle = fract(t);
    float p = 0.0;
    
    // First Bump (Lub): Peaks at 0.1, fades out by 0.2
    if (cycle < 0.2) {
        float ramp_up = smoothstep(0.0, 0.1, cycle); 
        float ramp_down = 1.0 - smoothstep(0.1, 0.2, cycle);
        p = ramp_up * ramp_down; 
    } 
    // Second Bump (Dub): Peaks at 0.3, fades out by 0.4 (scaled to 60%)
    else if (cycle < 0.4) {
        float ramp_up = smoothstep(0.2, 0.3, cycle); 
        float ramp_down = 1.0 - smoothstep(0.3, 0.4, cycle);
        p = ramp_up * ramp_down * 0.6; 
    }
    return p;
}

// --- Fragment Processor ---

void fragment() {
    float t = TIME * beat_speed;
    float pulse = 0.0;

    // Select pulse function based on mode
    if (pulse_mode == 0) {
        pulse = sine_pulse(t);
    } else if (pulse_mode == 1) {
        pulse = single_pulse(t);
    } else { // pulse_mode == 2
        pulse = double_pulse(t);
    }

    // Scale UVs
    float scale = 1.0 + pulse * pulse_strength;
    vec2 uv_scaled = pulse_uv(UV, scale);

    // Sample
    vec4 tex_color = texture(TEXTURE, uv_scaled);

    COLOR = tex_color;
}