vec3 getAccretionDisk(vec3 p, vec3 rd);
vec3 getBackground(vec3 rd);
void applyGravity(inout vec3 rd, vec3 p, float dt);

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    vec3 ro = u_cameraPos;
    vec3 forward = normalize(-ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);

    float seed = dot(uv, vec2(12.9898, 78.233));
    float jitter = fract(sin(seed) * 43758.5453);

    vec3 accumulatedColor = vec3(0.0);
    float accumulatedOpacity = 0.0;
    float t = 0.0;
    float dt = 0.04; 
    t += jitter * dt;

    for(int i = 0; i < 256; i++) {
        vec3 p = ro + rd * t;
        applyGravity(rd, p, dt);
        if(length(p) < 1.0) {
            accumulatedOpacity = 1.0;
            break;
        }

        vec4 gasInfo = getAccretionDiskVolumetric(p, rd);
        vec3 emission = gasInfo.rgb;
        float density = gasInfo.a * 2.0; 

        if(density > 0.0) {
            float stepOpacity = density * dt;
            accumulatedColor += emission * stepOpacity * (1.0 - accumulatedOpacity);
            accumulatedOpacity += stepOpacity;
        }

        if(accumulatedOpacity >= 1.0) {
            accumulatedOpacity = 1.0;
            break;
        }
        
        t += dt;
        if(t > 30.0) break;
    }

    vec3 bgColor = vec3(0.0); 
    vec3 finalColor = accumulatedColor + bgColor * (1.0 - accumulatedOpacity);

    outColor = vec4(finalColor, 1.0);
}
