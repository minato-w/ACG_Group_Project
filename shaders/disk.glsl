float hash(float n) { return fract(sin(n) * 43758.5453); }

float noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    return mix(mix(hash(n+0.0), hash(n+1.0), f.x),
               mix(hash(n+57.0), hash(n+58.0), f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.1; 
        amplitude *= 0.5; 
        p = vec2(p.x * 0.8 - p.y * 0.6, p.x * 0.6 + p.y * 0.8); 
    }
    return value;
}
vec3 applyDoppler(vec3 color, vec3 p, vec3 rd) {
    vec3 velocity = normalize(vec3(-p.z, 0.0, p.x));
    float cosTheta = dot(velocity, -rd);
    float factor = pow(1.0 + cosTheta * 0.5, 3.0);
    return color * factor;
}


vec3 getAccretionDisk(vec3 p, vec3 rd) {
    float r = length(p.xz);
    if (r < 0.8 || r > 4.0 || abs(p.y) > 0.1) return vec3(0.0); // 少し範囲を広げました

    float theta = atan(p.z, p.x);

    float speed = 2.0 / (r + 0.5);
    float movingTheta = theta - u_time * speed;

    vec2 noiseUV = vec2(movingTheta * 2.0, r * 10.0);
    float n = fbm(noiseUV);

    float density = pow(n, 3.0); 
    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd);
    vec3 baseCol = mix(vec3(1.0, 0.1, 0.0), vec3(1.2, 1.0, 0.8), doppler * 0.5 + 0.5);

    float alpha = smoothstep(0.1, 0.0, abs(p.y));
    float distFade = smoothstep(4.0, 2.5, r) * smoothstep(0.8, 1.0, r);

    return baseCol * density * alpha * distFade * (doppler + 1.5) * 2.0;
}
