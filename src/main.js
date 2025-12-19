const canvas = document.getElementById('gl-canvas');
const gl = canvas.getContext('webgl2');

// --- 1. シェーダー準備 ---
function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error(gl.getShaderInfoLog(shader));
        return null;
    }
    return shader;
}

const program = gl.createProgram();
gl.attachShader(program, createShader(gl, gl.VERTEX_SHADER, document.getElementById('vs').text.trim()));
gl.attachShader(program, createShader(gl, gl.FRAGMENT_SHADER, document.getElementById('fs').text.trim()));
gl.linkProgram(program);
gl.useProgram(program);

// --- 2. 頂点データ (画面全体を覆う板) ---
const vertices = new Float32Array([-1,-1, 1,-1, -1,1, 1,1]);
const buffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
const posLoc = gl.getAttribLocation(program, 'position');
gl.enableVertexAttribArray(posLoc);
gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);

// --- 3. UIと極座標のセットアップ ---
const gui = new dat.GUI();
const camParams = {
    radius: 3.0,
    theta: 0.0, // 水平方向の回転
    phi: 0.2    // 上下の角度 (ラジアン)
};

gui.add(camParams, 'radius', 1.0, 10.0).name('距離 (r)');
gui.add(camParams, 'theta', 0, Math.PI * 2).name('水平回転 (θ)');
gui.add(camParams, 'phi', -Math.PI/2.1, Math.PI/2.1).name('垂直角度 (φ)');

const resLoc = gl.getUniformLocation(program, 'u_resolution');
const cameraPosLoc = gl.getUniformLocation(program, 'u_cameraPos');

// --- 4. 描画ループ ---
function render(time) {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, canvas.width, canvas.height);

    // 極座標からデカルト座標(x,y,z)への変換
    const x = camParams.radius * Math.cos(camParams.phi) * Math.sin(camParams.theta);
    const y = camParams.radius * Math.sin(camParams.phi);
    const z = camParams.radius * Math.cos(camParams.phi) * Math.cos(camParams.theta);

    gl.useProgram(program);
    gl.uniform2f(resLoc, canvas.width, canvas.height);
    gl.uniform3f(cameraPosLoc, x, y, z);

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(render);
}
requestAnimationFrame(render);
