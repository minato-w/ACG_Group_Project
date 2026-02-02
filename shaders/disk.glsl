mat2 rot2(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

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
    if (r < 1.2 || r > 8.0 || abs(p.y) > (0.1 + r * 0.1)) return vec4(0.0);

    float angle = atan(p.z, p.x);
    
    float loopPeriod = 20.0; 
    float t1 = mod(u_time, loopPeriod);
    float t2 = mod(u_time + loopPeriod * 0.5, loopPeriod);
    float rot1 = 1.5 * t1 / (r + 0.1);
    float flow1 = r + 0.2 * t1; // inflowSpeed
    vec2 uv1 = vec2((angle + rot1) * 2.0, flow1 * 1.5);
    uv1.x -= 2.0 / (r + 0.05); // Twist
    float gas1 = fbm(uv1 * vec2(0.5, 4.0));

    float rot2 = 1.5 * t2 / (r + 0.1);
    float flow2 = r + 0.2 * t2;
    vec2 uv2 = vec2((angle + rot2) * 2.0, flow2 * 1.5);
    uv2.x -= 2.0 / (r + 0.05);
    float gas2 = fbm(uv2 * vec2(0.5, 4.0));

    float blend = 0.5 - 0.5 * cos(u_time * 6.28318 / loopPeriod);
    
    float gas = mix(gas2, gas1, blend);
    
    gas = smoothstep(0.2, 0.8, gas);
    float verticalFade = smoothstep(0.1 + r * 0.05, 0.0, abs(p.y));
    float radialFade = smoothstep(1.2, 2.5, r) * smoothstep(8.0, 4.0, r);
    
    float density = gas * verticalFade * radialFade;
    
    vec3 whiteCore = vec3(1.2, 1.0, 0.7); 
    vec3 orangeHot = vec3(1.1, 0.6, 0.1);
    vec3 redDeep = vec3(0.6, 0.05, 0.0);
    
    vec3 color;
    if (r < 2.5) {
        color = mix(whiteCore, orangeHot, smoothstep(1.0, 2.5, r));
    } else {
        color = mix(orangeHot, redDeep, smoothstep(2.5, 6.0, r));
    }

    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd);
    float dopplerFactor = doppler * 0.5 + 0.5;
    
    float intensity = (3.0 / pow(r, 0.8)) * (dopplerFactor + 0.4) * 3.0;

    return vec4(color * intensity, density * 2.0);
}
