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
    float theta = atan(p.z, p.x);
    if (r > 0.8 && r < 2.8 && abs(p.y) < 0.05) {
        
        float n = noise(vec2(r * 4.0, theta * 3.0 - u_time * 2.0));
        float falloff = pow(1.0 - (r - 0.8) / 2.0, 2.0);
        
        vec3 color = vec3(1.0, 0.4, 0.1) * n * falloff;
        
        float edgeAlpha = smoothstep(0.05, 0.0, abs(p.y));
        
        return color * edgeAlpha;
    }
    return vec3(0.0);
}
