float hash(float n) { return fract(sin(n) * 43758.5453); }

float noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    return mix(mix(hash(n+0.0), hash(n+1.0), f.x),
               mix(hash(n+57.0), hash(n+58.0), f.x), f.y);
}

vec3 getAccretionDisk(vec3 p) {
    float r = length(p.xz);
    if (r > 0.7 && r < 2.5 && abs(p.y) < 0.04) {
        float temp = exp(-2.0 * (r - 0.7));
        vec3 hotColor = vec3(1.0, 0.9, 0.7);
        vec3 coolColor = vec3(1.0, 0.3, 0.0);        
        vec3 baseColor = mix(coolColor, hotColor, temp);
        float alpha = smoothstep(0.04, 0.0, abs(p.y));
        return baseColor * alpha * 0.8;
    }
    return vec3(0.0);
}
