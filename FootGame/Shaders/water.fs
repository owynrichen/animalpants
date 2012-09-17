#ifdef GL_ES
precision lowp float;
#endif

const float pi = 3.14159;
const vec2 resolution = vec2(1,1);

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;
uniform sampler2D u_reflect_texture;
uniform mediump float u_time;
uniform vec2 u_touchPos;
uniform mediump float u_touchAmp;

vec2 getSample(vec2 pos, float wlength, float freq, float amp) {
    vec2 offset = -2.0 * pos;
    vec2 center = offset + 2.0 * v_texCoord;
    float distance = length(center);
    
    vec2 uv = v_texCoord + (center / distance) * (cos(wlength * distance - u_time * freq) * amp) * 0.005;

    return uv;
}

void main()
{
    vec2 col1 = getSample(vec2(1.0,0.5), 12.0, 8.0, 2.0);
    //vec2 col2 = getSample(vec2(0.34,0.0), 16.0, 4.0, 4.5);
    //vec2 col3 = getSample(vec2(0.0,0.78), 4.0, 15.0, 1.1);
    vec2 col4 = getSample(u_touchPos, 10.0, 9.0, u_touchAmp);
    
    //vec2 uv = (col1 + col2 + col3 + col4) / 4.0;
    vec2 uv = (col1 + col4) / 2.0;
    vec2 uv_ref = vec2(uv.x, 1.0-uv.y);
    vec4 col = texture2D(u_texture,uv);
    vec4 ref = texture2D(u_reflect_texture,uv_ref);
    
    float height = distance(v_texCoord, uv);
    
    gl_FragColor = col + (height * 20.0) * ref;
    
    // gl_FragColor = v_fragmentColor * texture2D(u_texture, v_texCoord);
}
