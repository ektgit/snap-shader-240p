//Copyright 2017-2018 E. Kenji Takeuchi

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
    
    const float scaleToSafeZone = 436.0 / 480.0;

    //Special cases:
    bool isTwoScreens = InputSize.x == 256.0 && InputSize.y == 448.0; //Nintendo Players' Choice
    isTwoScreens = isTwoScreens || ( InputSize.x == 320.0 && InputSize.y == 416.0 ); //Sega Mega Tech
    bool isHandheld = InputSize.x == 160.0 && InputSize.y == 144.0; //Currently only supports Game Boy, Game Boy Color, and Game Gear
    bool isVertical = MVPMatrix[0].y != 0.0; //detect rotated games

    float numInputLines = InputSize.y;
    numInputLines = InputSize.y <= 525.0 ? 480.0 : numInputLines; //480i games (15.7 and 31.5 KHz)
    numInputLines = InputSize.y <= 416.0 ? 384.0 : numInputLines; //Medium-resolution games (25 KHz, e.g. Williams)
    numInputLines = InputSize.y <= 312.0 ? 288.0 : numInputLines; //Extended-resolution games (16.5 KHz at 53 Hz, e.g. Midway)
    numInputLines = InputSize.y <= 262.0 ? 240.0 : numInputLines; //Standard-resolution games (15.7 Khz

    numInputLines = isTwoScreens ? 240.0 : numInputLines;

    vec2 rotatedInputSize = isVertical ? InputSize.yx : InputSize.xy;

    float integerRatio = OutputSize.y / numInputLines;
    integerRatio = floor( integerRatio ); //e.g. 2 = floor( 480 / 224 )
    integerRatio = max( 1.0, integerRatio ); //Some high-resolution vertical games are taller than 480 pixels.
    
    
    //Set the logical screen size (for example, on NTSC, 240 for low-res games, 480 for high-res games):
    vec2 logicalOutputSize = OutputSize.xy / integerRatio; //e.g. 240 = 480 / 2, or 480 = 480 / 1 for 480i games
    
    //For two-screen games like Punch-Out!!, just use the bottom screen.
    //(Pretend we have double the screen height, center scaling around middle of bottom screen, then restore).
    logicalOutputSize.y *= isTwoScreens ? 0.5 : 1.0;

    gl_Position.y += isTwoScreens ? 1.0 : 0.0;

    //Prevent, for example, 224 games from stretching to 240:
    vec2 transform;
    transform.x = isHandheld ? integerRatio * rotatedInputSize.x / OutputSize.x : 1.0;
    transform.y = isVertical ? 1.0 : rotatedInputSize.y / numInputLines;

    gl_Position.xy *= transform;
    
    gl_Position.y -= isTwoScreens ? 1.0 : 0.0;

    vec2 scaleToOutput = rotatedInputSize / logicalOutputSize;

    //In vertical mode, fill vertically, fit into safe zone:
    gl_Position.xy *= isVertical ? scaleToOutput : vec2( 1.0, 1.0 );
    gl_Position.xy *= isVertical ? logicalOutputSize.y / rotatedInputSize.y : 1.0;
    gl_Position.xy *= isVertical ? scaleToSafeZone : 1.0;

    _oPosition1 = gl_Position;

    COL0 = COLOR;
    TEX0.xy = TexCoord.xy;

    //TEX0.z seems to be unused, so use that to pass isVertical to the
    //pixel shader:
    TEX0.z = isVertical || ( rotatedInputSize.y * integerRatio > OutputSize.y ) ? 1.0 : 0.0;
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

    // Make sure we sample the pixel center so that we don't pick up neighbor pixels:
    coord.y = coord.y * TextureSize.y; 
    coord.y = floor(coord.y);
    coord.y += 0.5; // sample the pixel dead center
    coord.y = coord.y / TextureSize.y;

    // If we must shrink the image (for vertical games), regular
    // bilinear filtering looks better:
    bool useFilter = TEX0.z != 0.0;
    vec4 final = COMPAT_TEXTURE(Texture, useFilter ? TEX0.xy : coord.xy);

    _OUT._color = final;
    FragColor = _OUT._color;
    return;
} 
#endif
