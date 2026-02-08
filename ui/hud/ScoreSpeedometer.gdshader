shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.65;
uniform float inner_radius : hint_range(0.0, 0.5) = 0.30;
uniform float outer_radius : hint_range(0.0, 0.5) = 0.45;

uniform float start_angle : hint_range(0.0, 6.283185) = 3.9269907;
uniform float sweep_angle : hint_range(0.0, 6.283185) = 4.1887903;

uniform vec4 fill_color : source_color = vec4(0.2, 0.7, 1.0, 1.0);
uniform vec4 back_color : source_color = vec4(0.1, 0.1, 0.1, 0.35);

void fragment() {
    vec2 p = UV - vec2(0.5);
    float r = length(p);

    // Ring mask
    float in_ring = step(inner_radius, r) * (1.0 - step(outer_radius, r));

    // Angle in [0..TAU)
    float a = atan(p.y, p.x);
    a += TAU * step(a, 0.0);

    // Relative angle from start
    float rel = a - start_angle;
    rel += TAU * step(rel, 0.0);

    // Arc mask
    float in_arc = step(rel, sweep_angle);

    float filled = progress * sweep_angle;
    float is_filled = step(rel, filled);

    vec4 col = mix(back_color, fill_color, is_filled);

    COLOR = vec4(col.rgb, col.a * in_ring * in_arc);
}
