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
#define power 1.
#define range 1.

#define pi_2 1.57079632679
float get_luma(vec3 rgb){
    return dot(vec3(.299,.587,.114),rgb);
}

vec4 hook(){
    vec3 c=MAIN_tex(MAIN_pos).rgb;
    vec3 bezier1=vec3(0.),bezier2=vec3(0.);
    float p[6]=float[6](
        1.,5.,10.,10.,5.,1.
    );
    
    int i;
    //vetical
    for(i=-3;i<0;++i)
    bezier1+=p[i+3]*MAIN_texOff(vec2(0,i)*range).rgb;
    for(i=1;i<=3;++i)
    bezier1+=p[i+2]*MAIN_texOff(vec2(0,i)*range).rgb;
    bezier1/=32.;
    
    //horizenal
    for(i=-3;i<0;++i)
    bezier2+=p[i+3]*MAIN_texOff(vec2(i,0)*range).rgb;
    for(i=1;i<=3;++i)
    bezier2+=p[i+2]*MAIN_texOff(vec2(i,0)*range).rgb;
    bezier2/=32.;
    
    //The closer the colors are, the blurrier they are.
    bezier1=mix(c,bezier1,pow(2.718,-abs(get_luma(150./power*(bezier1-c)))));
    bezier2=mix(c,bezier2,pow(2.718,-abs(get_luma(150./power*(bezier2-c)))));
    c=bezier1+bezier2-c;
    return vec4(c,1.);
    
    //bezier1=mix(bezier1,c,dot(c,bezier1)/length(bezier1));
    //bezier2=mix(bezier2,c,dot(c,bezier2)/length(bezier2));
    //c=bezier1+bezier2-c;
    //return vec4(c,1.0);
}

void main(){
    color=hook();
}