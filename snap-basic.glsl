//Copyright 2017 E. Kenji Takeuchi

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    vec4 _oColor;
    vec2 _otexCoord;
    gl_Position = VertexCoord.x * MVPMatrix[0] + VertexCoord.y * MVPMatrix[1] + VertexCoord.z * MVPMatrix[2] + VertexCoord.w * MVPMatrix[3];
    _oColor = COLOR;

    float logicalScreenHeight = OutputSize.y; //Usually 480

    float integerRatio = OutputSize.y / InputSize.y;
    integerRatio = floor( integerRatio ); //e.g. 2 = floor( 480 / 224 )
	
    //Set the logical screen size (for example, on NTSC, 240 for low res games, 480 for high res games):
    logicalScreenHeight /= integerRatio; //e.g. 240 = 480 / 2, or 480 = 480 / 1 for 480i games

    //Prevent, for example, 224 games from stretching to 240:
    gl_Position.y *= InputSize.y / logicalScreenHeight;

    _oPosition1 = gl_Position;

    COL0 = COLOR;
    TEX0.xy = TexCoord.xy;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

struct output_dummy {
    vec4 _color;
};

uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
//standard texture sample looks like this: COMPAT_TEXTURE(Texture, TEX0.xy);

void main()
{
    output_dummy _OUT;

    vec2 coord = TEX0.xy;

    coord.y = coord.y * TextureSize.y; 
    coord.y = floor(coord.y);
    coord.y += 0.5; //half-pixel offset
    coord.y = coord.y / TextureSize.y; 

    vec4 final = COMPAT_TEXTURE(Texture, coord.xy);

    _OUT._color = final;
    FragColor = _OUT._color;
    return;
} 
#endif
