vec3 getBackground(vec3 rd) {
    float stars = pow(fract(sin(dot(rd, vec3(12.9898, 78.233, 45.164))) * 43758.5453), 20.0);
    return vec3(stars);
}
