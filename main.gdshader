shader_type spatial;
render_mode cull_disabled; // optional: see both sides if needed

// Heightmap (grayscale). Drag your MyNoiseTexture.tres onto this in the Inspector.
uniform sampler2D heightmap : source_color;

// How high to raise the terrain
uniform float height_scale = 5.0;

void vertex() {
    // Sample the height from the texture (0..1)
    float h = texture(heightmap, UV).r;
    // Displace along the surface normal so rotation doesn't matter
    VERTEX += NORMAL * (h * height_scale);
}

void fragment() {
    // Show the same grayscale as the surface color (helps you confirm matching)
    vec3 tex_rgb = texture(heightmap, UV).rgb;
    ALBEDO = tex_rgb;
}