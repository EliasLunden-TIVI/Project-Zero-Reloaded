
shader_type canvas_item;

uniform float scanline_density : hint_range(50.0, 1000.0) = 400.0;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.12;
uniform float scanline_speed : hint_range(-5.0, 5.0) = 0.0;

uniform float flicker_strength : hint_range(0.0, 0.2) = 0.015;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.08;

// Color customization
uniform vec4 hologram_color : source_color = vec4(0.65, 0.85, 1.0, 1.0);
uniform float color_strength : hint_range(0.0, 1.0) = 0.25;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Horizontal scanlines
    float scanline = sin(
        (UV.y * scanline_density + TIME * scanline_speed)
        * 6.283185
    );

    float line_effect = 1.0 - (
        (scanline * 0.5 + 0.5) * scanline_strength
    );

    // Subtle display flicker
    float flicker = 1.0 - (
        flicker_strength * (0.5 + 0.5 * sin(TIME * 17.0))
    );

    float brightness = line_effect * flicker + glow_strength;

    // Apply brightness
    color.rgb *= brightness;

    // Apply holographic tint
    color.rgb = mix(
        color.rgb,
        color.rgb * hologram_color.rgb,
        color_strength
    );

    COLOR = color;
}
