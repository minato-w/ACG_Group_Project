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

    float rotSpeed = 1.5 * u_time/ (r + 0.1); 
    float currentAngle = angle + rotSpeed;
    float inflowSpeed = 0.2 * u_time;
    float flowR = r + inflowSpeed;

    vec2 uv = vec2(currentAngle * 2.0, flowR * 1.5);
    uv.x -= 2.0 / (r + 0.05);
    vec2 warp = vec2(
        fbm(uv * 2.0 + vec2(u_time * 0.5, 0.0)), // 時間で動くオフセット
        fbm(uv * 2.0 + vec2(0.0, u_time * 0.5))
    );

    float gas = fbm(uv + warp * 0.5);
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
    float doppler = dot(vel, -rd); // -rd との内積で手前/奥を判定
    float dopplerFactor = doppler * 0.5 + 0.5;
    
    float intensity = (3.0 / pow(r, 0.8)) * (dopplerFactor + 0.4) * 3.0;

    return vec4(color * intensity, density * 2.0);
}
