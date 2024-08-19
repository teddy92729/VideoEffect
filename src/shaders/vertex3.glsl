#version 300 es
in vec2 aPosition;
out vec2 vTextureCoord;

uniform vec4 uInputSize;
uniform vec4 uOutputFrame;
uniform vec4 uOutputTexture;

vec4 filterVertexPosition(void)
{
    vec2 position=aPosition*uOutputFrame.zw+uOutputFrame.xy;
    
    position.x=position.x*(2./uOutputTexture.x)-1.;
    position.y=position.y*(2.*uOutputTexture.z/uOutputTexture.y)-uOutputTexture.z;
    
    return vec4(position,0.,1.);
}

vec2 filterTextureCoord(void)
{
    return aPosition*(uOutputFrame.zw*uInputSize.zw);
}

void main(void)
{
    gl_Position=filterVertexPosition();
    vTextureCoord=filterTextureCoord();
}