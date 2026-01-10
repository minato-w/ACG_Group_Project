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
    if (r < 0.8 || r > 3.5 || abs(p.y) > 0.08) return vec3(0.0);
    float theta = atan(p.z, p.x);
    
    float swirl = theta + r * 2.0; 
    

    float rotation = u_time * (1.5 / (r + 0.2));
    float finalTheta = swirl - rotation;

    float n = noise(vec2(r * 2.0, finalTheta * 1.2));
    n += 0.5 * noise(vec2(r * 4.0, finalTheta * 2.5));
    n *= 0.7; 
    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd);
    vec3 baseCol = mix(vec3(1.0, 0.2, 0.0), vec3(1.0, 0.8, 0.4), doppler * 0.5 + 0.5);
    float density = n * smoothstep(0.08, 0.0, abs(p.y)) * smoothstep(3.5, 1.5, r);

    return baseCol * density * (doppler + 1.2);
}
