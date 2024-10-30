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
#define HDRPower 1.05
#define radius1 7.475000
#define radius2 7.547000

void main() {
    vec3 _color = HOOKED_tex(HOOKED_pos).rgb;

    vec3 bloom_sum1 = HOOKED_texOff(vec2(1.5f, -1.5f) * radius1).rgb;
    bloom_sum1 += HOOKED_texOff(vec2(-1.5f, -1.5f) * radius1).rgb;
    bloom_sum1 += HOOKED_texOff(vec2(1.5f, 1.5f) * radius1).rgb;
    bloom_sum1 += HOOKED_texOff(vec2(-1.5f, 1.5f) * radius1).rgb;
    bloom_sum1 += HOOKED_texOff(vec2(0.f, -2.5f) * radius1).rgb;
    bloom_sum1 += HOOKED_texOff(vec2(0.f, 2.5f) * radius1).rgb;
    bloom_sum1 += HOOKED_texOff(vec2(-2.5f, 0.f) * radius1).rgb;
    bloom_sum1 += HOOKED_texOff(vec2(2.5f, 0.f) * radius1).rgb;

    bloom_sum1 *= .005f;

    vec3 bloom_sum2 = HOOKED_texOff(vec2(1.5f, -1.5f) * radius2).rgb;
    bloom_sum2 += HOOKED_texOff(vec2(-1.5f, -1.5f) * radius2).rgb;
    bloom_sum2 += HOOKED_texOff(vec2(1.5f, 1.5f) * radius2).rgb;
    bloom_sum2 += HOOKED_texOff(vec2(-1.5f, 1.5f) * radius2).rgb;
    bloom_sum2 += HOOKED_texOff(vec2(0.f, -2.5f) * radius2).rgb;
    bloom_sum2 += HOOKED_texOff(vec2(0.f, 2.5f) * radius2).rgb;
    bloom_sum2 += HOOKED_texOff(vec2(-2.5f, 0.f) * radius2).rgb;
    bloom_sum2 += HOOKED_texOff(vec2(2.5f, 0.f) * radius2).rgb;

    bloom_sum2 *= .010f;

    float dist = radius2 - radius1;
    vec3 HDR = (_color + (bloom_sum2 - bloom_sum1)) * dist;
    vec3 blend = HDR + _color;
    _color = pow(abs(blend), abs(vec3(HDRPower, HDRPower, HDRPower))) - HDR;// pow - don't use fractions for HDRpower

    color = vec4(clamp(_color, 0.f, 1.f), 1.f);
}