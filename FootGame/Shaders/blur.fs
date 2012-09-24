#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_blurCoords[9];

uniform sampler2D CC_Texture0;

uniform mediump vec2 u_blurSize;
uniform vec4 u_substract;
uniform float u_desaturate;


vec4 Desaturate(vec3 color, float Desaturation)
{
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, color));
	return vec4(mix(color, gray, Desaturation), 1.0);
}

void main() {
	vec4 sum = vec4(0.0);

	sum += texture2D(CC_Texture0, v_blurCoords[0]) * 0.05;
	sum += texture2D(CC_Texture0, v_blurCoords[1]) * 0.09;
	sum += texture2D(CC_Texture0, v_blurCoords[2]) * 0.12;
	sum += texture2D(CC_Texture0, v_blurCoords[3]) * 0.15;
	sum += texture2D(CC_Texture0, v_blurCoords[4]) * 0.16;
	sum += texture2D(CC_Texture0, v_blurCoords[5]) * 0.15;
	sum += texture2D(CC_Texture0, v_blurCoords[6]) * 0.12;
	sum += texture2D(CC_Texture0, v_blurCoords[7]) * 0.09;
	sum += texture2D(CC_Texture0, v_blurCoords[8]) * 0.05;
    
	gl_FragColor = Desaturate(sum.xyz, u_desaturate);
}