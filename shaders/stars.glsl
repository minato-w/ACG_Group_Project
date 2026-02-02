// Based on "Star Nest" by Pablo Roman Andrioli
// License: MIT

#define iterations 17
#define formuparam 0.5312
#define volsteps 20
#define stepsize 0.1
#define tile   0.850
#define speed  0.010 
#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

vec3 getBackground(vec3 rd, vec3 ro) {
    vec3 from = ro+ vec3(12.34, 56.78, 91.01); 
    
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
    return v * .01; 
}
