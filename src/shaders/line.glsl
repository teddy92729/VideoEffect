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

#define Power 1.

float get_luma(vec3 rgb) {
    return dot(vec3(.299f, .587f, .114f), rgb);
}

void main() {
    float diff1 = -dot(normalize(HOOKED_texOff(vec2(1, 1))), normalize(HOOKED_texOff(vec2(1, 1)))) + 1.f;
    float diff2 = -dot(normalize(HOOKED_texOff(vec2(-1, 1))), normalize(HOOKED_texOff(vec2(1, -1)))) + 1.f;
    float edge = diff1 * diff1 + diff2 + diff2;
    vec3 c = HOOKED_tex(HOOKED_pos).rgb;
    float luma = get_luma(c);
    edge = clamp(edge * Power, -luma * .1f, luma * .1f);

    color = vec4(c + edge, 1.f);
}