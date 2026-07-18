shader_type canvas_item;

// Controls how much the texture is desaturated
uniform float desaturate : hint_range(0.0, 1.0) = 1.0;

// Overlay image for stoney effect
uniform sampler2D overlay_tex;

// Strength of overlay effect
uniform float overlay_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
    // Base texture color
    vec4 tex = texture(TEXTURE, UV);

    // Desaturate the base texture
    float grey = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 stone = mix(tex.rgb, vec3(grey), desaturate);

    // Sample the overlay texture
    vec4 overlay = texture(overlay_tex, UV * 1.0); // UV scale can tile or stretch

    // Mix overlay with base texture
    stone = mix(stone, overlay.rgb, overlay_strength);

    COLOR = vec4(stone, tex.a);
}