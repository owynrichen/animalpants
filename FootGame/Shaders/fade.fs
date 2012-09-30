#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;

uniform mediump vec2 u_blurSize;
uniform float u_desaturate;


vec4 Desaturate(vec3 color, float Desaturation)
{
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, color));
	return vec4(mix(color, gray, Desaturation), 1.0);
}

void main() {
    //vec4 color = vec4(texture2D(CC_Texture0, v_texCoord).xyz * (1.0 - u_desaturate), 1.0);
    
	gl_FragColor = Desaturate(texture2D(CC_Texture0, v_texCoord).xyz, u_desaturate);
}