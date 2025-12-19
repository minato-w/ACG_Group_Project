/**
 * ACG Group Project: Black Hole 3D Base
 * このファイルは WebGL2 の初期化、シェーダーのコンパイル、
 * および描画ループ（アニメーション）を管理します。
 */

const canvas = document.getElementById('gl-canvas');
const gl = canvas.getContext('webgl2');

if (!gl) {
    alert('WebGL2 is not supported. Please use a modern browser.');
}

// -----------------------------------------------------------
// 1. シェーダーのコンパイルとリンク
// -----------------------------------------------------------

function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    
    // コンパイルエラーのチェック
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error('Shader compile error:', gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}

// HTML内の <script id="vs"> と <script id="fs"> からソースを取得
const vsSource = document.getElementById('vs').text.trim();
const fsSource = document.getElementById('fs').text.trim();

const vertexShader = createShader(gl, gl.VERTEX_SHADER, vsSource);
const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fsSource);

const program = gl.createProgram();
gl.attachShader(program, vertexShader);
gl.attachShader(program, fragmentShader);
gl.linkProgram(program);

// リンクエラーのチェック
if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error('Program link error:', gl.getProgramInfoLog(program));
}
gl.useProgram(program);

// -----------------------------------------------------------
// 2. 頂点データの設定 (画面全体を覆う板)
// -----------------------------------------------------------

// 画面を覆う2つの三角形（TRIANGLE_STRIP形式）
const vertices = new Float32Array([
    -1.0, -1.0, 
     1.0, -1.0, 
    -1.0,  1.0, 
     1.0,  1.0
]);

const buffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

const posLoc = gl.getAttribLocation(program, 'position');
gl.enableVertexAttribArray(posLoc);
gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);

// -----------------------------------------------------------
// 3. Uniform（シェーダーへの変数）の場所を取得
// -----------------------------------------------------------

const resLoc = gl.getUniformLocation(program, 'u_resolution');
const timeLoc = gl.getUniformLocation(program, 'u_time');
const cameraPosLoc = gl.getUniformLocation(program, 'u_cameraPos');

// -----------------------------------------------------------
// 4. 描画ループ
// -----------------------------------------------------------

function render(time) {
    // 時間を秒単位に変換
    const seconds = time * 0.001;

    // キャンバスサイズをウィンドウに合わせる
    if (canvas.width !== window.innerWidth || canvas.height !== window.innerHeight) {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        gl.viewport(0, 0, canvas.width, canvas.height);
    }

    // 画面をクリア（濃い紺色）
    gl.clearColor(0.01, 0.01, 0.05, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.useProgram(program);

    // --- Uniformの更新 ---
    // 解像度を送る
    gl.uniform2f(resLoc, canvas.width, canvas.height);
    
    // 時間を送る
    gl.uniform1f(timeLoc, seconds);

    // カメラ位置を計算（半径3.0の円周上をゆっくり移動）
    const radius = 3.0;
    const camX = Math.sin(seconds * 0.5) * radius;
    const camZ = Math.cos(seconds * 0.5) * radius;
    const camY = 0.5; // 少し上から見下ろす
    gl.uniform3f(cameraPosLoc, camX, camY, camZ);

    // 描画実行
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    // 次のフレームへ
    requestAnimationFrame(render);
}

// アニメーション開始
requestAnimationFrame(render);
