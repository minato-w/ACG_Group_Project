vec3 getAccretionDisk(vec3 p) {  // 引数が vec3 であること！
    float dXZ = length(p.xz);
    if(dXZ > 0.8 && dXZ < 2.5 && abs(p.y) < 0.02) {
        float intensity = smoothstep(2.5, 0.8, dXZ);
        return vec3(1.0, 0.5, 0.2) * intensity;
    }
    return vec3(0.0);
}
