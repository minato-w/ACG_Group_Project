const canvas = document.getElementById('gl-canvas');
const gl = canvas.getContext('webgl2');

if (!gl) {
    alert('WebGL2 is not supported');
}

// エラーチェック付きのシェーダー作成関数
function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    
    // コンパイル成功判定を追加
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error('Shader compile error:', gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}

// HTMLからソースを取得
const vsElement = document.getElementById('vs');
const fsElement = document.getElementById('fs');

if (!vsElement || !fsElement) {
    console.error('Shader elements not found! Check IDs "vs" and "fs" in index.html');
}

const vsSource = vsElement.text;
const fsSource = fsElement.text;

const vertexShader = createShader(gl, gl.VERTEX_SHADER, vsSource);
const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fsSource);

// プログラムの作成とリンク
const program = gl.createProgram();
gl.attachShader(program, vertexShader);
gl.attachShader(program, fragmentShader);
gl.linkProgram(program);

// リンク成功判定を追加
if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error('Program link error:', gl.getProgramInfoLog(program));
}
gl.useProgram(program);

// --- 頂点データ設定などは変更なし ---
const vertices = new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]);
const buffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

const posLoc = gl.getAttribLocation(program, 'position');
gl.enableVertexAttribArray(posLoc);
gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);

const resLoc = gl.getUniformLocation(program, 'u_resolution');
const timeLoc = gl.getUniformLocation(program, 'u_time');

function render(time) {
    // 毎フレーム背景を青色でクリアして、描画が動いているか確認しやすくする
    gl.clearColor(0.0, 0.0, 0.3, 1.0); 
    gl.clear(gl.COLOR_BUFFER_BIT);

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, canvas.width, canvas.height);

    gl.uniform2f(resLoc, canvas.width, canvas.height);
    gl.uniform1f(timeLoc, time * 0.001);

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(render);
}

requestAnimationFrame(render);
