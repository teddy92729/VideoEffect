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

float get_luma(vec4 rgba) {
    return dot(vec4(.299f, .587f, .114f, 0.f), rgba);
}

vec4 LINELUMA_tex(vec2 pos) {
    return vec4(get_luma(HOOKED_tex(pos)), 0.f, 0.f, 0.f);
}
//------------------------------------------

#define L_tex LINELUMA_tex

float max3v(float a, float b, float c) {
    return max(max(a, b), c);
}
float min3v(float a, float b, float c) {
    return min(min(a, b), c);
}

vec2 minmax3(vec2 pos, vec2 d) {
    float a = L_tex(pos - d).x;
    float b = L_tex(pos).x;
    float c = L_tex(pos + d).x;

    return vec2(min3v(a, b, c), max3v(a, b, c));
}

float lumGaussian7(vec2 pos, vec2 d) {
    float g = (L_tex(pos - (d + d)).x + L_tex(pos + (d + d)).x) * .06136f;
    g = g + (L_tex(pos - d).x + L_tex(pos + d).x) * .24477f;
    g = g + (L_tex(pos).x) * .38774f;

    return g;
}

vec4 MMKERNEL_tex(vec2 pos) {
    return vec4(lumGaussian7(pos, vec2(HOOKED_pt.x, 0.f)), minmax3(pos, vec2(HOOKED_pt.x, 0.f)), 0.f);
}
//-------------------------------------------------
#undef L_tex
#define L_tex MMKERNEL_tex

vec2 minmax3_y(vec2 pos, vec2 d) {
    float a0 = L_tex(pos - d).y;
    float b0 = L_tex(pos).y;
    float c0 = L_tex(pos + d).y;

    float a1 = L_tex(pos - d).z;
    float b1 = L_tex(pos).z;
    float c1 = L_tex(pos + d).z;

    return vec2(min3v(a0, b0, c0), max3v(a1, b1, c1));
}

float lumGaussian7_y(vec2 pos, vec2 d) {
    float g = (L_tex(pos - (d + d)).x + L_tex(pos + (d + d)).x) * .06136f;
    g = g + (L_tex(pos - d).x + L_tex(pos + d).x) * .24477f;
    g = g + (L_tex(pos).x) * .38774f;

    return g;
}

vec4 MMKERNEL_y_tex(vec2 pos) {
    return vec4(lumGaussian7_y(pos, vec2(0.f, HOOKED_pt.y)), minmax3_y(pos, vec2(0.f, HOOKED_pt.y)), 0.f);
}
//-------------------------------------------------
#define STRENGTH.6//De-blur proportional strength, higher is sharper. However, it is better to tweak BLUR_CURVE instead to avoid ringing.
#define BLUR_CURVE.6//De-blur power curve, lower is sharper. Good values are between 0.3 - 1. Values greater than 1 softens the image;
#define BLUR_THRESHOLD.1//Value where curve kicks in, used to not de-blur already sharp edges. Only de-blur values that fall below this threshold.
#define NOISE_THRESHOLD.01//Value where curve stops, used to not sharpen noise. Only de-blur values that fall above this threshold.
#undef L_tex
#define L_tex LINELUMA_tex

vec4 Apply_tex(vec2 pos) {
    float c = (L_tex(pos).x - MMKERNEL_y_tex(pos).x) * STRENGTH;

    float t_range = BLUR_THRESHOLD - NOISE_THRESHOLD;

    float c_t = abs(c);
    if(c_t > NOISE_THRESHOLD) {
        c_t = (c_t - NOISE_THRESHOLD) / t_range;
        c_t = pow(c_t, BLUR_CURVE);
        c_t = c_t * t_range + NOISE_THRESHOLD;
        c_t = c_t * sign(c);
    } else {
        c_t = c;
    }

    float cc = clamp(c_t + L_tex(pos).x, MMKERNEL_y_tex(pos).y, MMKERNEL_y_tex(pos).z) - L_tex(pos).x;

    //This trick is only possible if the inverse Y->RGB matrix has 1 for every row... (which is the case for BT.709)
    //Otherwise we would need to convert RGB to YUV, modify Y then convert back to RGB.
    return MAIN_tex(pos) + cc;
}
//-------------------------------------------------
void main() {
    color = Apply_tex(HOOKED_pos);
}