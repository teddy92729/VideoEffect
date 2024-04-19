import { Filter, GlProgram } from "pixi.js";

let vertex3 = `#version 300 es
in vec2 aPosition;
out vec2 vTextureCoord;

uniform vec4 uInputSize;
uniform vec4 uOutputFrame;
uniform vec4 uOutputTexture;

vec4 filterVertexPosition( void )
{
    vec2 position = aPosition * uOutputFrame.zw + uOutputFrame.xy;
    
    position.x = position.x * (2.0 / uOutputTexture.x) - 1.0;
    position.y = position.y * (2.0*uOutputTexture.z / uOutputTexture.y) - uOutputTexture.z;

    return vec4(position, 0.0, 1.0);
}

vec2 filterTextureCoord( void )
{
    return aPosition * (uOutputFrame.zw * uInputSize.zw);
}

void main(void)
{
    gl_Position = filterVertexPosition();
    vTextureCoord = filterTextureCoord();
}
`;

export function splitRGB(strength) {
    return new Filter({
        glProgram: GlProgram.from({
            vertex: vertex3,
            fragment: `#version 300 es
precision highp float;
in vec2 vTextureCoord;
uniform vec4 uInputSize;
uniform sampler2D uTexture;
uniform float strength;
out vec4 color;
//-------------------------------------------
#define MAIN_pos      vTextureCoord
#define MAIN_tex(pos) texture(uTexture, pos)
#define Orginal_tex(pos) texture(Orginal, pos)
#define MAIN_pt       uInputSize.zw
#define MAIN_texOff(offset) MAIN_tex(MAIN_pos+(offset)*MAIN_pt)
//-------------------------------------------

#define RSplit vec2(-1.0, 1.0)*strength
#define GSplit vec2( 1.0,-1.0)*strength
#define BSplit vec2( 0.0, 0.0)*strength

vec4 hook() {
    return vec4(MAIN_texOff(RSplit).r,MAIN_texOff(GSplit).g,MAIN_texOff(BSplit).b,1.0);
}
void main() {
    color = hook();
}
`,
        }),
        resources: {
            timeUniform: {
                strength: {
                    type: "f32",
                    value: strength,
                },
            },
        },
    });
}
