float hash(float n) { return fract(sin(n) * 43750.0); }

float noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0;
    return mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
               mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5; 
    float frequency = 1.0; 
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.2; 
        amplitude *= 0.5; 
        const float c = cos(0.5); const float s = sin(0.5);
        p *= mat2(c, s, -s, c);
    }
    return value * 0.5 + 0.5;
}

vec4 getAccretionDiskVolumetric(vec3 p, vec3 rd) {
    float r = length(p.xz);
    if (r < 1.0 || r > 5.0 || abs(p.y) > 0.3) return vec4(0.0);

    float theta = atan(p.z, p.x);
    float speed = 3.5 / (r * r + 0.1);
    float movingTheta = theta - u_time * speed * 0.5;
    
    vec2 uv = vec2(movingTheta * 5.0, r * 12.0 + fbm(vec2(movingTheta, r) * 4.0) * 0.5);
    float d = fbm(uv + fbm(uv * 1.5) * 0.4);
    
    float finalDensity = pow(d, 3.0) * smoothstep(0.3, 0.1, abs(p.y));
    finalDensity *= smoothstep(1.0, 1.3, r) * smoothstep(6.0, 4.0, r);

    vec3 whiteCore = vec3(1.2, 1.0, 0.7);
    vec3 orangeHot = vec3(1.1, 0.6, 0.1);
    vec3 redDeep = vec3(0.6, 0.05, 0.0);
    
    vec3 color;
    if (r < 2.8) {
        color = mix(whiteCore, orangeHot, smoothstep(1.0, 2.8, r));
    } else {
        color = mix(orangeHot, redDeep, smoothstep(2.8, 5.5, r));
    }

    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd) * 0.5 + 0.5;
    float intensity = (3.0 / pow(r, 0.8)) * (doppler + 0.4) * 4.5;
    
    return vec4(color * intensity, finalDensity);
}
