void applyGravity(inout vec3 rd, vec3 p, float dt) {
    float r2 = dot(p, p);
    vec3 acceleration = -normalize(p) * (u_gravity / r2);
    rd = normalize(rd + acceleration * dt);
}
