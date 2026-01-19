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
        
        frequency *= 2.2; 
        amplitude *= 0.5; 

        const float c = cos(0.5); const float s = sin(0.5);
        p *= mat2(c, s, -s, c);
    }
    return value * 0.5 + 0.5;
}
vec3 applyDoppler(vec3 color, vec3 p, vec3 rd) {
    vec3 velocity = normalize(vec3(-p.z, 0.0, p.x));
    float cosTheta = dot(velocity, -rd);
    float factor = pow(1.0 + cosTheta * 0.5, 3.0);
    return color * factor;
}

vec4 getAccretionDiskVolumetric(vec3 p, vec3 rd) {
    float r = length(p.xz);
    if (r < 1.0 || r > 4.5 || abs(p.y) > 0.15) return vec4(0.0);

    float theta = atan(p.z, p.x);
    float speed = 3.0 / (r * r + 0.1);
    float movingTheta = theta - u_time * speed * 0.5;

    vec2 uv = vec2(movingTheta * 3.0, r * 4.0);
    float density = fbm(uv + fbm(uv * 0.5));
    
    density = pow(density, 2.5);

    float verticalFade = smoothstep(0.15, 0.0, abs(p.y));
    float radialFade = smoothstep(1.0, 1.3, r) * smoothstep(4.5, 3.0, r);
    float finalDensity = density * verticalFade * radialFade;

    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd) * 0.5 + 0.5;

    vec3 coreColor = vec3(1.0, 0.9, 0.4);
    vec3 midColor  = vec3(1.0, 0.4, 0.05);
    vec3 edgeColor = vec3(0.5, 0.05, 0.0);
    
    vec3 tempColor = mix(coreColor, midColor, smoothstep(1.0, 2.0, r));
    tempColor = mix(tempColor, edgeColor, smoothstep(2.0, 4.5, r));
    float intensity = (smoothstep(4.5, 1.0, r) * 12.0) + 1.0;
    vec3 emission = tempColor * intensity * (doppler + 0.2);

    return vec4(emission, finalDensity);
}
