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
#define power 1.
#define range 1.

#define pi_2 1.57079632679
float get_luma(vec3 rgb) {
    return dot(vec3(.299f, .587f, .114f), rgb);
}

vec4 hook() {
    vec3 c = HOOKED_tex(HOOKED_pos).rgb;
    vec3 bezier1 = vec3(0.f), bezier2 = vec3(0.f);
    float p[6] = float[6](1.f, 5.f, 10.f, 10.f, 5.f, 1.f);

    int i;
    //vetical
    for(i = -3; i < 0; ++i) bezier1 += p[i + 3] * HOOKED_texOff(vec2(0, i) * range).rgb;
    for(i = 1; i <= 3; ++i) bezier1 += p[i + 2] * HOOKED_texOff(vec2(0, i) * range).rgb;
    bezier1 /= 32.f;

    //horizenal
    for(i = -3; i < 0; ++i) bezier2 += p[i + 3] * HOOKED_texOff(vec2(i, 0) * range).rgb;
    for(i = 1; i <= 3; ++i) bezier2 += p[i + 2] * HOOKED_texOff(vec2(i, 0) * range).rgb;
    bezier2 /= 32.f;

    //The closer the colors are, the blurrier they are.
    bezier1 = mix(c, bezier1, pow(2.718f, -abs(get_luma(150.f / power * (bezier1 - c)))));
    bezier2 = mix(c, bezier2, pow(2.718f, -abs(get_luma(150.f / power * (bezier2 - c)))));
    c = bezier1 + bezier2 - c;
    return vec4(c, 1.f);

    //bezier1=mix(bezier1,c,dot(c,bezier1)/length(bezier1));
    //bezier2=mix(bezier2,c,dot(c,bezier2)/length(bezier2));
    //c=bezier1+bezier2-c;
    //return vec4(c,1.0);
}

void main() {
    color = hook();
}