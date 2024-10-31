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

uniform float strength;

#define RSplit vec2(-1.,1.)*strength
#define GSplit vec2(1.,-1.)*strength
#define BSplit vec2(0.,0.)*strength

void main() {
    color = vec4(HOOKED_texOff(RSplit).r, HOOKED_texOff(GSplit).g, HOOKED_texOff(BSplit).b, 1.f);
}