uniform sampler2D sampler2d;
varying mediump vec2	myTexCoord;
mediump float threshold = 100.000/255.000;

void main() {
    
    // テクスチャから画素値取得
	mediump vec4 tcolor = texture2D(sampler2d, myTexCoord);

	// 輝度算出
	mediump float y, u, v;
	y = tcolor.r * 0.299 + tcolor.g * 0.587 + tcolor.b * 0.114;
	// セピア色調固定値
	u = -0.091;
	v = 0.056;
    
    // RGBに戻す
	tcolor.r = y + v * 1.402;
	tcolor.g = y + u * -0.344 + v * -0.714;
	tcolor.b = y + u * 1.772;

	
    gl_FragColor = tcolor;
    
}