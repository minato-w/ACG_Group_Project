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
    if (r < 1.0 || r > 4.0 || abs(p.y) > 0.2) return vec4(0.0);

    float theta = atan(p.z, p.x);
    float speed = 3.0 / (r * r + 0.1);
    float movingTheta = theta - u_time * speed * 0.5;

    vec2 uv = vec2(movingTheta * 2.0, r * 3.0 + sin(movingTheta * 3.0) * 0.2);
    
    float density = fbm(uv);
    density = smoothstep(0.1, 0.9, density);
    density = pow(density, 1.5);

    float verticalFade = smoothstep(0.2, 0.0, abs(p.y));
    float radialFade = smoothstep(1.0, 1.2, r) * smoothstep(4.0, 3.0, r);
    
    float finalDensity = density * verticalFade * radialFade;
    
    if (finalDensity < 0.01) return vec4(0.0);

    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd) * 0.5 + 0.5;

    vec3 hotColor = vec3(1.0, 0.9, 0.7); 
    vec3 coldColor = vec3(0.8, 0.2, 0.0);
    vec3 tempColor = mix(hotColor, coldColor, smoothstep(1.0, 3.5, r));

    vec3 emission = tempColor * (doppler + 0.5);
    emission *= smoothstep(4.0, 1.0, r) * 8.0 + 1.0; 

    return vec4(emission, finalDensity * 1.5);
}
