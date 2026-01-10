float hash(float n) { return fract(sin(n) * 43758.5453); }

float noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    return mix(mix(hash(n+0.0), hash(n+1.0), f.x),
               mix(hash(n+57.0), hash(n+58.0), f.x), f.y);
}
vec3 applyDoppler(vec3 color, vec3 p, vec3 rd) {
    vec3 velocity = normalize(vec3(-p.z, 0.0, p.x));
    float cosTheta = dot(velocity, -rd);
    float factor = pow(1.0 + cosTheta * 0.5, 3.0);
    return color * factor;
}


vec3 getAccretionDisk(vec3 p, vec3 rd) {
    float r = length(p.xz);
    
    if (r < 0.7 || r > 3.0 || abs(p.y) > 0.06) return vec3(0.0);

    float theta = atan(p.z, p.x);
    float speed = 2.0 / (r + 0.5); 
    float rotatedTheta = theta - u_time * speed;

    float n = noise(vec2(r * 4.0, rotatedTheta * 2.0));
    n = n * 0.7 + 0.3 * noise(vec2(r * 8.0, rotatedTheta * 4.0));


    vec3 velocity = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(velocity, -rd); 
    float dopplerFactor = pow(1.0 + doppler * 0.5, 3.0);

    float temp = exp(-1.5 * (r - 0.7));
    vec3 hotColor = vec3(1.0, 0.9, 0.7);
    vec3 coolColor = vec3(1.0, 0.3, 0.0);
    vec3 baseColor = mix(coolColor, hotColor, temp);

    float alpha = smoothstep(0.06, 0.0, abs(p.y));
    float distFade = smoothstep(3.0, 2.0, r) * smoothstep(0.5, 0.8, r);
    return baseColor * n * dopplerFactor * alpha * distFade * 1.5;
}
