float starHash(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

vec3 getBackground(vec3 rd) {
    float stars = pow(starHash(floor(rd * 200.0)), 20.0);
    return vec3(stars);
}
