vec3 computeDisk(vec3 p) {
    float distXZ = length(p.xz);
    if (distXZ > 0.8 && distXZ < 2.5 && abs(p.y) < 0.02) {
        float intensity = smoothstep(2.5, 0.8, distXZ);
        return vec3(1.0, 0.5, 0.2) * intensity;
    }
    return vec3(0.0);
}
