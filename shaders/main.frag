vec3 getAccretionDisk(vec3 p, vec3 rd);
vec3 getBackground(vec3 rd);
void applyGravity(inout vec3 rd, vec3 p, float dt);

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    vec3 ro = u_cameraPos;
    vec3 target = vec3(0.0);
    vec3 forward = normalize(target - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);
    bool rayHasHit = false; 
    float t = 0.0;
    float dt = 0.1;
    vec3 color = vec3(0.0);
    float seed = dot(uv, vec2(20.0, 80.0));
    float jitter = fract(sin(seed) * 45000.0);
    float t =  jitter * 0.1;

    for(int i = 0; i < 256; i++) {
        vec3 p = ro + rd * t;

        applyGravity(rd, p, dt);

        float dBH = length(p) - 0.5;
        if(dBH < 0.01) {
            color = vec3(0.0);
            rayHasHit = true;
            break;
        }
        if (abs(p.y) < 0.05) {
            float r = length(p.xz);
            if (r > 0.8 && r < 5.0) {
                color = getAccretionDisk(p, rd);
                rayHasHit = true;
                break;
            }
        }

        t += dt;
        if(t > 25.0) break;
    }

    if (rayHasHit == false) {
        color = getBackground(rd);
    }

    outColor = vec4(color, 1.0);
}
