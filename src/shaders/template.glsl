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