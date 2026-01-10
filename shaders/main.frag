void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    vec3 ro = u_cameraPos; 
    vec3 target = vec3(0.0); 
    vec3 forward = normalize(target - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);

    float t = 0.0;
    vec3 color = vec3(0.0);

    for(int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        color += getAccretionDisk(p);

        float d = length(p) - 0.5;
        if(d < 0.001) {
            color = vec3(0.0); 
            break;
        }
        t += d;

        if(t > 15.0) {
            color += vec3(0.02, 0.02, 0.05);
            break;
        }
    }
    outColor = vec4(color, 1.0);
}
