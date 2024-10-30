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
#define EdgeSlope 2.
#define Power 1.

float get_luma(vec4 rgba) {
    return dot(vec4(.299f, .587f, .114f, 0.f), rgba);
}

void main() {
    float diff1 = get_luma(HOOKED_texOff(vec2(1, 1)));
    diff1 = get_luma(HOOKED_texOff(vec2(-1, -1))) - diff1;
    float diff2 = get_luma(HOOKED_texOff(vec2(1, -1)));
    diff2 = get_luma(HOOKED_texOff(vec2(-1, 1))) - diff2;
    float edge = diff1 * diff1 + diff2 + diff2;
    color = clamp(pow(abs(edge), EdgeSlope) * -Power + HOOKED_tex(HOOKED_pos), 0.f, 1.f);
}