uniform sampler2D sampler2d;
varying mediump vec2	myTexCoord;


void main() {
    
    mediump vec3 c = texture2D(sampler2d,myTexCoord).rgb;
    mediump float grey = dot(c, vec3(0.299, 0.587, 0.114));
    gl_FragColor = vec4(grey, grey, grey, 1.0);

}