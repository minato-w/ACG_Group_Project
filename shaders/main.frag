/*
vec3 getAccretionDisk(vec3 p, vec3 rd);
vec3 getBackground(vec3 rd);
void applyGravity(inout vec3 rd, vec3 p, float dt);
vec4 getAccretionDiskVolumetric(vec3 p, vec3 rd); 
vec3 getBackground(vec3 rd);
void applyGravity(inout vec3 rd, vec3 p, float dt);

vec4 getAccretionDiskVolumetric(vec3 p, vec3 rd);
vec3 getBackground(vec3 rd);
void applyGravity(inout vec3 rd, vec3 p, float dt);
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
    float extinction = 2.5; 

    float t = 0.0;
    float dt = 0.04; 
    t += jitter * dt;

    for(int i = 0; i < 256; i++) {
        vec3 p = ro + rd * t;
        applyGravity(rd, p, dt);

        float dist = length(p);
        
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
        float density = gas.a * 1.5;

        if(density > 0.0) {
            float stepOpacity = density * dt;
            accumulatedColor += gas.rgb * 0.35 * stepOpacity * (1.0 - accumulatedOpacity);
            accumulatedOpacity += stepOpacity;

            bgTransmittance *= exp(-density * extinction * dt);
        }

        if(accumulatedOpacity >= 0.99) break;
        if(bgTransmittance < 0.01) bgTransmittance = 0.0;

        t += dt;
        if(t > 30.0) break;
    }

    vec3 bgColor = .5*getBackground(rd);
    
    vec3 sceneColor = accumulatedColor + bgColor * bgTransmittance;

    vec3 mapped = (sceneColor * (2.5 * sceneColor + 0.03)) / 
                  (sceneColor * (2.45 * sceneColor + 0.6) + 0.15);
    
    outColor = vec4(clamp(mapped, 0.0, 1.0), 1.0);
}
*/
vec4 getAccretionDiskVolumetric(vec3 p, vec3 rd);
vec3 getBackground(vec3 rd, vec3 ro);
void applyGravity(inout vec3 rd, vec3 p, float dt);

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
    float extinction = 2.5; 

    vec3 p = ro;
    float t = 0.0;
    float dt = 0.04; 
    t += jitter * dt;

    for(int i = 0; i < 256; i++) {
        p += rd * dt;
        applyGravity(rd, p, dt);

        float dist = length(p);
        
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
        float density = gas.a * 1.5;

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
    vec3 bgColor = .5 * getBackground(rd, p);
    
    vec3 sceneColor = accumulatedColor + bgColor * bgTransmittance;

    vec3 mapped = (sceneColor * (2.5 * sceneColor + 0.03)) / 
                  (sceneColor * (2.45 * sceneColor + 0.6) + 0.15);
    
    outColor = vec4(clamp(mapped, 0.0, 1.0), 1.0);
}
