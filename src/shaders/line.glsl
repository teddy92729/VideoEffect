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
#define Power 1.

float get_luma(vec3 rgb){
    return dot(vec3(.299,.587,.114),rgb);
}

void main(){
    float diff1=-dot(normalize(MAIN_texOff(vec2(1,1))),normalize(MAIN_texOff(vec2(1,1))))+1.;
    float diff2=-dot(normalize(MAIN_texOff(vec2(-1,1))),normalize(MAIN_texOff(vec2(1,-1))))+1.;
    float edge=diff1*diff1+diff2+diff2;
    vec3 c=MAIN_tex(MAIN_pos).rgb;
    float luma=get_luma(c);
    edge=clamp(edge*Power,-luma*.1,luma*.1);
    
    color=vec4(c+edge,1.);
}