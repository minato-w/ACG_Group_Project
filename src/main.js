async function init() {
    const canvas = document.getElementById('gl-canvas');
    const gl = canvas.getContext('webgl2');

    if (!gl) {
        alert('WebGL2 is not supported');
        return;
    }
    async function loadShaderSource(path) {
        const response = await fetch(path);
        if (!response.ok) throw new Error(`Failed to load: ${path}`);
        return await response.text();
    }

    let fsParts;
    try {
        fsParts = await Promise.all([
            loadShaderSource('./shaders/common.glsl'),   
            loadShaderSource('./shaders/disk.glsl'),     
            loadShaderSource('./shaders/stars.glsl'),    
            loadShaderSource('./shaders/physics.glsl'),  
            loadShaderSource('./shaders/main.frag')      
        ]);
    } catch (e) {
        console.error("Shader loading error:", e);
        return;
    }

    const vsSource = await loadShaderSource('./shaders/main.vert');
    const fsSource = fsParts.join('\n'); 

    function createShader(gl, type, source) {
        const shader = gl.createShader(type);
        gl.shaderSource(shader, source.trim());
        gl.compileShader(shader);
        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            console.error(gl.getShaderInfoLog(shader));
            return null;
        }
        return shader;
    }

    const vertexShader = createShader(gl, gl.VERTEX_SHADER, vsSource);
    const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fsSource);

    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    gl.useProgram(program);

    const vertices = new Float32Array([-1,-1, 1,-1, -1,1, 1,1]);
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
    const posLoc = gl.getAttribLocation(program, 'position');
    gl.enableVertexAttribArray(posLoc);
    gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);

    const resLoc = gl.getUniformLocation(program, 'u_resolution');
    const cameraPosLoc = gl.getUniformLocation(program, 'u_cameraPos');
    const timeLoc = gl.getUniformLocation(program, 'u_time');


    const params = {
        radius: 3.0,
        theta: 0.0,
        phi: 0.3,
        gravity: 0.05
    };

    const gui = new dat.GUI();
    gui.add(params, 'radius', 1.0, 10.0).name('距離 (r)');
    gui.add(params, 'theta', 0.0, Math.PI * 2.0).name('水平回転 (θ)');
    gui.add(params, 'phi', -Math.PI / 2.2, Math.PI / 2.2).name('上下角度 (φ)');
    gui.add(params, 'gravity', 0.0, 0.2).name('重力強度 (M)');


    function render(time) {
        if (canvas.width !== window.innerWidth || canvas.height !== window.innerHeight) {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            gl.viewport(0, 0, canvas.width, canvas.height);
        }

        const x = params.radius * Math.cos(params.phi) * Math.sin(params.theta);
        const y = params.radius * Math.sin(params.phi);
        const z = params.radius * Math.cos(params.phi) * Math.cos(params.theta);

        gl.clearColor(0, 0, 0, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);

        gl.useProgram(program);
        gl.uniform2f(resLoc, canvas.width, canvas.height);
        gl.uniform1f(timeLoc, time * 0.001);
        gl.uniform3f(cameraPosLoc, x, y, z);

        const gravLoc = gl.getUniformLocation(program, 'u_gravity');
        gl.uniform1f(gravLoc, params.gravity);
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
        requestAnimationFrame(render);
    }
    requestAnimationFrame(render);
}
init();
