#version 300 es
precision highp float;
in vec2 vTextureCoord;
uniform sampler2D uTexture;
uniform sampler2D uOTexture;
uniform vec4 uInputSize;
uniform vec4 uOutputFrame;
out vec4 color;

//-------------------------------------------
#define MAIN_pos      vTextureCoord
#define MAIN_tex(pos) texture(uTexture, pos)
#define Orginal_tex(pos) texture(uOTexture, (pos)*uotex_scale)
#define MAIN_pt       uInputSize.zw
#define MAIN_size       uInputSize.xy
#define MAIN_texOff(offset) MAIN_tex(MAIN_pos+(offset)*MAIN_pt)
//-------------------------------------------

#define STRENGTH 1.0

vec4 hook() {
    highp vec2 uotex_scale = uInputSize.xy / uOutputFrame.zw;
    vec2 f0 = fract(MAIN_pos * MAIN_size);
    ivec2 i0 = ivec2(f0 * vec2(2.0f));
    float c0 = MAIN_tex((vec2(0.5f) - f0) * MAIN_pt + MAIN_pos)[i0.y * 2 + i0.x];
    float c1 = c0;
    float c2 = c1;
    float c3 = c2;
    return vec4(c0, c1, c2, 0.0f) * STRENGTH + Orginal_tex(MAIN_pos);
}

void main() {
    color = hook();
}