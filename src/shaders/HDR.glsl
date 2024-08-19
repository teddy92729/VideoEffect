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
#define HDRPower 1.2
#define radius1 7.475000
#define radius2 7.547000

void main(){
    vec3 _color=MAIN_tex(MAIN_pos).rgb;
    
    vec3 bloom_sum1=MAIN_texOff(vec2(1.5,-1.5)*radius1).rgb;
    bloom_sum1+=MAIN_texOff(vec2(-1.5,-1.5)*radius1).rgb;
    bloom_sum1+=MAIN_texOff(vec2(1.5,1.5)*radius1).rgb;
    bloom_sum1+=MAIN_texOff(vec2(-1.5,1.5)*radius1).rgb;
    bloom_sum1+=MAIN_texOff(vec2(0.,-2.5)*radius1).rgb;
    bloom_sum1+=MAIN_texOff(vec2(0.,2.5)*radius1).rgb;
    bloom_sum1+=MAIN_texOff(vec2(-2.5,0.)*radius1).rgb;
    bloom_sum1+=MAIN_texOff(vec2(2.5,0.)*radius1).rgb;
    
    bloom_sum1*=.005;
    
    vec3 bloom_sum2=MAIN_texOff(vec2(1.5,-1.5)*radius2).rgb;
    bloom_sum2+=MAIN_texOff(vec2(-1.5,-1.5)*radius2).rgb;
    bloom_sum2+=MAIN_texOff(vec2(1.5,1.5)*radius2).rgb;
    bloom_sum2+=MAIN_texOff(vec2(-1.5,1.5)*radius2).rgb;
    bloom_sum2+=MAIN_texOff(vec2(0.,-2.5)*radius2).rgb;
    bloom_sum2+=MAIN_texOff(vec2(0.,2.5)*radius2).rgb;
    bloom_sum2+=MAIN_texOff(vec2(-2.5,0.)*radius2).rgb;
    bloom_sum2+=MAIN_texOff(vec2(2.5,0.)*radius2).rgb;
    
    bloom_sum2*=.010;
    
    float dist=radius2-radius1;
    vec3 HDR=(_color+(bloom_sum2-bloom_sum1))*dist;
    vec3 blend=HDR+_color;
    _color=pow(abs(blend),abs(vec3(HDRPower,HDRPower,HDRPower)))-HDR;// pow - don't use fractions for HDRpower
    
    color=vec4(clamp(_color,0.,1.),1.);
}