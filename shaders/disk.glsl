#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_cameraPos;

#define iterations 17
#define formuparam 0.53
#define volsteps 20
#define stepsize 0.1
#define zoom   0.800
#define tile   0.850
#define speed  0.010 
#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 1.0

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

void applyGravity(inout vec3 rd, vec3 p, float dt) {
    float r = length(p);
    float f = 1.5 * (1.0 / (r * r + 0.01)); 
    vec3 acc = normalize(-p) * f;
    rd += acc * dt;
}

vec4 getAccretionDiskVolumetric(vec3 p, vec3 rd) {
    float r = length(p.xz);
    
    if (r < 1.0 || r > 10.0 || abs(p.y) > (0.1 + r * 0.08)) return vec4(0.0);

    float rotSpeed = 3.0 / (r * r + 0.1);
    float angle = u_time * rotSpeed * 0.5;
    
    vec3 q = p;
    q.xz *= rot2(angle);

    float n = fbm(q.xz * 3.0); 
    float n2 = fbm(q.xz * 6.0 - vec2(u_time * 0.5));
    float d = mix(n, n2, 0.5);
    
    d = smoothstep(0.3, 0.8, d);

    float finalDensity = d * smoothstep(0.5, 0.0, abs(p.y) / (0.1 + r * 0.05)); 
    
    finalDensity *= smoothstep(2.0, 3.5, r) * smoothstep(8.0, 5.0, r);

    vec3 whiteCore = vec3(1.2, 1.0, 0.7);
    vec3 orangeHot = vec3(1.1, 0.6, 0.1);
    vec3 redDeep = vec3(0.6, 0.05, 0.0);
    
    vec3 color;
    if (r < 3.0) {
        color = mix(whiteCore, orangeHot, smoothstep(2.0, 3.0, r));
    } else {
        color = mix(orangeHot, redDeep, smoothstep(3.0, 6.0, r));
    }

    vec3 vel = normalize(vec3(-p.z, 0.0, p.x));
    float doppler = dot(vel, -rd); 
    float dopplerFactor = doppler * 0.5 + 0.5; 
    float intensity = (4.0 / pow(r, 0.7)) * (0.5 + 1.5 * dopplerFactor);
    
    return vec4(color * intensity, finalDensity * 2.0);
}

vec3 getBackground(vec3 rd, vec3 ro) {
    vec3 from = ro + vec3(12.34, 56.78, 91.01); 
    
    float s = 0.1, fade = 1.;
    vec3 v = vec3(0.);
    float density_scale = 0.02;
    
    for (int r = 0; r < volsteps; r++) {
        vec3 p_star = from + s * rd * 0.5;
        vec3 p_noise = p_star * density_scale; 

        p_noise = abs(vec3(tile) - mod(p_noise, vec3(tile * 2.))); 
        
        float pa, a = pa = 0.;
        for (int i = 0; i < iterations; i++) { 
            p_noise = abs(p_noise) / dot(p_noise, p_noise) - formuparam;
            a += abs(length(p_noise) - pa); 
            pa = length(p_noise);
        }
        
        float dm = max(0., darkmatter - a * a * .001);
        a *= a * a; 
        if (r > 6) fade *= 1. - dm; 
        
        v += fade;
        v += vec3(s, s * s, s * s * s * s) * a * brightness * fade;
        fade *= distfading; 
        s += stepsize;
    }
    
    v = mix(vec3(length(v)), v, saturation);
    return v * 0.01; 
}

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    vec3 ro = u_cameraPos;
    
    vec3 forward = normalize(-ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);

    float seed = dot(uv, vec2(13.0, 78.0));
    float jitter = fract(sin(seed) * 43760.0);

    vec3 accumulatedColor = vec3(0.0); 
    float accumulatedOpacity = 0.0; 
    float bgTransmittance = 1.0;
    float extinction = 3.5; 

    vec3 p = ro;
    float t = 0.0;
    float dt = 0.04; 
    t += jitter * dt;

    for(int i = 0; i < 256; i++) {
        p += rd * dt;
        applyGravity(rd, p, dt);
        
        float dist = length(p);

        dt = max(0.02, 0.05 * dist);

        if(dist < 1.02) {
            float shadowEdge = smoothstep(1.0, 1.02, dist);
            accumulatedOpacity += (1.0 - shadowEdge) * 2.0;
            bgTransmittance *= shadowEdge;
            if(accumulatedOpacity >= 1.0) {
                accumulatedOpacity = 1.0;
                bgTransmittance = 0.0;
                break;
            }
        }

        vec4 gas = getAccretionDiskVolumetric(p, rd);
        float density = gas.a;

        if(density > 0.0) {
            float stepOpacity = density * dt;
            accumulatedColor += gas.rgb * 0.35 * stepOpacity * (1.0 - accumulatedOpacity);
            accumulatedOpacity += stepOpacity;
            bgTransmittance *= exp(-density * extinction * dt);
        }

        if(accumulatedOpacity >= 0.99) break;
        if(bgTransmittance < 0.01) {
            bgTransmittance = 0.0;
            break;
        }

        t += dt;
        if(t > 30.0) break;
    }

    rd = normalize(rd);
    
    vec3 bgColor = 0.5 * getBackground(rd, p);
    vec3 sceneColor = accumulatedColor + bgColor * bgTransmittance;

    vec3 mapped = (sceneColor * (2.5 * sceneColor + 0.03)) / 
                  (sceneColor * (2.45 * sceneColor + 0.6) + 0.15);
    
    gl_FragColor = vec4(clamp(mapped, 0.0, 1.0), 1.0);
}
