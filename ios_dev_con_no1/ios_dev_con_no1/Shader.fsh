void main()
{
    lowp vec4 color = texture2D(tex0, texUVVarying).rgba;
    gl_FragColor = color;
}
