shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.65; // 0..1
uniform float inner_radius : hint_range(0.0, 0.5) = 0.30;
uniform float outer_radius : hint_range(0.0, 0.5) = 0.45;

uniform float start_angle : hint_range(0.0, 6.283185) = 3.9269907; // radians
uniform float sweep_angle : hint_range(0.0, 6.283185) = 4.1887903; // radians (240°)

uniform vec4 fill_color : source_color = vec4(0.2, 0.7, 1.0, 1.0);
uniform vec4 back_color : source_color = vec4(0.1, 0.1, 0.1, 0.35);

void fragment() {
    // UV in [0..1]. Convert to centered coordinates [-0.5..0.5]
    vec2 p = UV - vec2(0.5);
    float r = length(p);

    // Ring mask
    float in_ring = step(inner_radius, r) * (1.0 - step(outer_radius, r));
    if (in_ring < 0.5) {
        COLOR = vec4(0.0);
        return;
    }

    // Angle in [0..TAU)
    float a = atan(p.y, p.x);            // [-PI..PI]
    if (a < 0.0) a += 6.28318530718;     // [0..TAU)

    // Normalize angle within the gauge arc:
    // We want angles starting at start_angle and going forward by sweep_angle.
    float rel = a - start_angle;
    if (rel < 0.0) rel += 6.28318530718; // wrap into [0..TAU)

    float filled = progress * sweep_angle;

    // Only show within sweep arc; outside arc = background (still in ring)
    float in_arc = step(rel, sweep_angle);

    // Filled portion within arc
    float is_filled = step(rel, filled);

    vec4 col = mix(back_color, fill_color, is_filled);
    COLOR = col * in_arc;
}
