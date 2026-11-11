shader_type canvas_item;

uniform vec4 white_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float white_progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    COLOR = vec4(mix(tex_color.rgb, white_color.rgb, white_progress), tex_color.a);
}