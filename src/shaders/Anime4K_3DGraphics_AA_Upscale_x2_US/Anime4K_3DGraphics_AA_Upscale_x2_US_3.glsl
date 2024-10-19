#version 300 es
precision highp float;
in vec2 vTextureCoord;
uniform vec4 uInputSize;
uniform sampler2D uTexture;
uniform sampler2D uOTexture;
out vec4 color;
//-------------------------------------------
#define MAIN_pos      vTextureCoord
#define MAIN_tex(pos) texture(uTexture, pos)
#define Orginal_tex(pos) texture(uOTexture, pos)
#define MAIN_pt       uInputSize.zw
#define MAIN_size       uInputSize.xy
#define MAIN_texOff(offset) MAIN_tex(MAIN_pos+(offset)*MAIN_pt)
//-------------------------------------------

#define go_0(x_off, y_off) (max((MAIN_texOff(vec2(x_off, y_off))), 0.0))
vec4 hook() {
    vec4 result = mat4(-0.00055252935f, 0.0011350953f, -0.0016148019f, 0.0014946404f, -0.30635214f, -0.017596753f, -0.0036547943f, 0.016236471f, 0.005174489f, 0.0030302007f, 0.00019672248f, 0.0006430973f, 0.0007490077f, -0.0031795658f, -6.158733e-05f, 0.0006820584f) * go_0(-1.0f, -1.0f);
    result += mat4(0.15602079f, 0.011071071f, -0.0027609533f, -0.0034318874f, -0.0039016667f, 0.016504101f, -0.27816474f, -0.008282344f, 0.19063498f, 0.012465078f, 0.010091085f, -0.004841106f, -0.11758087f, -0.012808949f, 0.0067606894f, 0.005216566f) * go_0(-1.0f, 0.0f);
    result += mat4(0.013258877f, -0.014989483f, 0.22402754f, 0.013204027f, 0.00016207264f, -0.00042593342f, -0.00333761f, -0.0012207513f, 0.0033727325f, -0.007841196f, 0.16044731f, 0.00594871f, -0.0028581345f, 0.012616562f, -0.15928285f, -0.011812331f) * go_0(-1.0f, 1.0f);
    result += mat4(-0.0048872055f, -0.0011780986f, -0.0029523429f, 0.00082424335f, -0.0024385185f, -0.26525813f, 0.013532772f, -0.0008381766f, 0.0024996721f, 0.0022899017f, -0.0017697349f, -0.0010618394f, 0.0024938583f, 0.005421073f, 0.0028740794f, -0.007808829f) * go_0(0.0f, -1.0f);
    result += mat4(-0.08293415f, 0.2659366f, -0.010839574f, 0.023423964f, 0.01725351f, -0.009252893f, -0.011632222f, -0.308242f, 0.0001496815f, 0.16104282f, -0.0069378703f, 0.00842848f, 0.085917845f, -0.18407243f, -0.006601597f, -0.027134055f) * go_0(0.0f, 0.0f);
    result += mat4(-0.033873428f, -0.011743531f, -0.230377f, 0.116242796f, -0.0018527015f, -0.00853698f, 0.0059901997f, -0.006155517f, -0.009841329f, 0.006163952f, 0.014816026f, 0.18667653f, 0.016977048f, -0.0017093032f, 0.19695279f, -0.061764043f) * go_0(0.0f, 1.0f);
    result += mat4(-0.0003514533f, -0.0069080726f, 0.0052108583f, -0.0016346197f, -0.0016860099f, 0.006002445f, -0.0022835485f, -0.0028219873f, 0.0005367275f, 0.0005437954f, 0.00059865275f, -0.00014915364f, -0.0032214937f, -0.00052043283f, -0.0031621973f, 0.0055843857f) * go_0(1.0f, -1.0f);
    result += mat4(-0.006905302f, -0.20389622f, 0.01891904f, -0.018114902f, 0.00724176f, 0.011335843f, -0.0028616642f, 0.016452003f, -0.00013852821f, -0.00039706306f, 0.0011838446f, 0.0028873065f, 0.012857878f, 0.16889338f, -0.014114007f, 0.009388666f) * go_0(1.0f, 0.0f);
    result += mat4(0.0040798862f, 0.002933288f, -0.016012201f, -0.14650294f, -0.0017411204f, 0.0017980475f, 0.00056705566f, -0.0003218331f, -0.0014291195f, -0.0062614805f, 0.00082543516f, -0.00397049f, -0.004496662f, 0.0008032309f, 0.0049529593f, 0.117166765f) * go_0(1.0f, 1.0f);
    result += vec4(-3.1127936e-05f, 3.3726166e-05f, 4.8580805e-05f, -9.541029e-06f);
    return result;
}

void main() {
    color = hook();
}