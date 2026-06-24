shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform float alpha_boost : hint_range(0.0, 5.0) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float alpha = clamp(tex.a * alpha_boost, 0.0, 1.0) * opacity;

    vec3 rgb = mix(tex.rgb, tint_color.rgb, tint_color.a);

    COLOR = vec4(rgb, alpha);
}