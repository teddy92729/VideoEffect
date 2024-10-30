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

// Enhanced hash function with maximum noise
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(443.897f, 441.423f, 437.195f));
    p3 += dot(p3, p3.yzx + 19.19f);
    return fract((p3.x + p3.y) * p3.z) - 0.5f;
}

// Much more aggressive threshold calculation
float getThreshold(vec3 color) {
    float luma = dot(color, vec3(0.299f, 0.587f, 0.114f));
    // Drastically increased threshold range
    return mix(1.0f / 255.0f, 4.0f / 255.0f, luma);
}

void main() {
    vec4 texColor = HOOKED_tex(HOOKED_pos);

    // Generate maximum strength noise pattern
    // float noise = hash(HOOKED_pos * HOOKED_size); 

    // Calculate adaptive threshold with maximum sensitivity
    float threshold = getThreshold(texColor.rgb);

    // Sample in a wider pattern for more aggressive detection
    vec4 n1 = HOOKED_texOff(vec2(-2.0f, 0.0f));
    vec4 n2 = HOOKED_texOff(vec2(2.0f, 0.0f));
    vec4 n3 = HOOKED_texOff(vec2(0.0f, -2.0f));
    vec4 n4 = HOOKED_texOff(vec2(0.0f, 2.0f));
    vec4 n5 = HOOKED_texOff(vec2(-2.0f, -2.0f));
    vec4 n6 = HOOKED_texOff(vec2(2.0f, 2.0f));
    vec4 n7 = HOOKED_texOff(vec2(-1.0f, 1.0f));
    vec4 n8 = HOOKED_texOff(vec2(1.0f, -1.0f));

    // Calculate color differences with maximum sensitivity
    vec4 diff = abs(texColor - n1) + abs(texColor - n2) +
        abs(texColor - n3) + abs(texColor - n4) +
        abs(texColor - n5) + abs(texColor - n6) +
        abs(texColor - n7) + abs(texColor - n8);
    float diffAmount = dot(diff.rgb, vec3(0.333f));

    // Threshold for detecting banding
    float bandingThreshold = threshold * 4.0f;

    // Apply maximum strength dithering
    vec3 dithered = texColor.rgb;

    // Always apply base dithering
    // dithered += noise * threshold * 0.5f;

    // Additional strong per-channel noise
    vec3 noiseColor = vec3(hash(HOOKED_pos * HOOKED_size + vec2(0.0f, 0.0f)), hash(HOOKED_pos * HOOKED_size + vec2(1.0f, 0.0f)), hash(HOOKED_pos * HOOKED_size + vec2(0.0f, 1.0f))) * threshold * 2.0f;

    // dithered += noiseColor;

    // Extra high-frequency noise layer
    // vec3 highFreqNoise = vec3(hash(HOOKED_pos * HOOKED_size * 2.0f), hash(HOOKED_pos * HOOKED_size * 2.0f + vec2(0.5f)), hash(HOOKED_pos * HOOKED_size * 2.0f + vec2(1.0f))) * threshold;

    // dithered += highFreqNoise;

    // If in a banding-prone area, apply even more aggressive dithering
    if(diffAmount < bandingThreshold) {
        dithered += noiseColor;
    }

    // Ensure we stay within valid color range
    color = vec4(clamp(dithered, 0.0f, 1.0f), texColor.a);
}