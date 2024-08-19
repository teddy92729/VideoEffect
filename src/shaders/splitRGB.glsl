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

#define RSplit vec2(-1.,1.)*strength
#define GSplit vec2(1.,-1.)*strength
#define BSplit vec2(0.,0.)*strength

void main(){
    color=vec4(MAIN_texOff(RSplit).r,MAIN_texOff(GSplit).g,MAIN_texOff(BSplit).b,1.);
}