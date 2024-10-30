#version 300 es
precision highp float;
in vec2 vTextureCoord;
in vec2 vPosition;
uniform sampler2D uTexture;
uniform sampler2D uOTexture;
uniform vec4 uInputSize;
uniform vec4 uOutputFrame;
out vec4 color;

//-------------------------------------------
#define HOOKED_pos      vTextureCoord
#define HOOKED_tex(pos) texture(uTexture, pos)
#define HOOKED_pt       uInputSize.zw
#define HOOKED_size       uInputSize.xy
#define HOOKED_texOff(offset) HOOKED_tex(HOOKED_pos+(offset)*HOOKED_pt)
#define MAIN_pos vPosition
#define MAIN_tex(pos) texture(uOTexture, pos)
//-------------------------------------------

#define STRENGTH 1.0

vec4 hook() {
    vec2 f0 = fract(HOOKED_pos * HOOKED_size);
    ivec2 i0 = ivec2(f0 * vec2(2.0f));
    float c0 = HOOKED_tex((vec2(0.5f) - f0) * HOOKED_pt + HOOKED_pos)[i0.y * 2 + i0.x];
    float c1 = c0;
    float c2 = c1;
    float c3 = c2;
    return vec4(c0, c1, c2, 0.0f) * STRENGTH + MAIN_tex(MAIN_pos);
}

void main() {
    color = hook();
}