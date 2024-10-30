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