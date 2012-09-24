attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump vec2 v_blurCoords[9];
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_blurCoords[9];
#endif

uniform mediump vec2 u_blurSize;

void main()
{
    gl_Position = CC_MVPMatrix * a_position;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
    v_blurCoords[0] = v_texCoord - 4.0 * u_blurSize;
    v_blurCoords[1] = v_texCoord - 3.0 * u_blurSize;
    v_blurCoords[2] = v_texCoord - 2.0 * u_blurSize;
    v_blurCoords[3] = v_texCoord - 1.0 * u_blurSize;
    v_blurCoords[4] = v_texCoord;
    v_blurCoords[5] = v_texCoord + 1.0 * u_blurSize;
    v_blurCoords[6] = v_texCoord + 2.0 * u_blurSize;
    v_blurCoords[7] = v_texCoord + 3.0 * u_blurSize;
    v_blurCoords[8] = v_texCoord + 4.0 * u_blurSize;
}
