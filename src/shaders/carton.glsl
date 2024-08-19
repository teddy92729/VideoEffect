#version 300 es
precision highp float;
in vec2 vTextureCoord;
uniform vec4 uInputSize;
uniform sampler2D uTexture;
uniform float strength;
out vec4 color;
//-------------------------------------------
#define MAIN_pos vTextureCoord
#define MAIN_tex(pos)texture(uTexture,pos)
#define Orginal_tex(pos)texture(Orginal,pos)
#define MAIN_pt uInputSize.zw
#define MAIN_texOff(offset)MAIN_tex(MAIN_pos+(offset)*MAIN_pt)
//-------------------------------------------
#define EdgeSlope 2.
#define Power 1.

float get_luma(vec4 rgba){
    return dot(vec4(.299,.587,.114,0.),rgba);
}

void main(){
    float diff1=get_luma(MAIN_texOff(vec2(1,1)));
    diff1=get_luma(MAIN_texOff(vec2(-1,-1)))-diff1;
    float diff2=get_luma(MAIN_texOff(vec2(1,-1)));
    diff2=get_luma(MAIN_texOff(vec2(-1,1)))-diff2;
    float edge=diff1*diff1+diff2+diff2;
    color=clamp(pow(abs(edge),EdgeSlope)*-Power+MAIN_tex(MAIN_pos),0.,1.);
}