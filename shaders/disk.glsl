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

    float rotSpeed = 0.5 * u_time / (r + 0.1); 
    float currentAngle = angle + rotSpeed;
    float inflowSpeed = 0.8 * u_time;
    float flowR = r + inflowSpeed;

    vec2 uv = vec2(currentAngle * 2.0, flowR * 1.5);
    uv.x += r * 1.0; 
    float gas = fbm(uv * vec2(1.0, 3.0)); 
    gas = smoothstep(0.2, 0.8, gas);
    float verticalFade = smoothstep(0.1 + r * 0.05, 0.0, abs(p.y));
    float radialFade = smoothstep(1.2, 2.5, r) * smoothstep(8.0, 4.0, r);
    
    float density = gas * verticalFade * radialFade;
    vec3 colInner = vec3(1.0, 0.9, 0.8);
    vec3 colMid   = vec3(1.0, 0.5, 0.1);
    vec3 colOuter = vec3(0.5, 0.05, 0.0);
    
    vec3 color;
    if (r < 3.0) {
        color = mix(colInner, colMid, smoothstep(1.2, 3.0, r));
    } else {
        color = mix(colMid, colOuter, smoothstep(3.0, 7.0, r));
    }
    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd);
    float dopplerFactor = doppler * 0.5 + 0.5;
    float intensity = (8.0 / (r * r)) * (0.5 + 1.5 * dopplerFactor);
    return vec4(color * intensity, density * 2.0);
}
