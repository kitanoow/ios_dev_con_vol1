attribute highp vec4	myVertex;
attribute mediump vec4	myUV;
uniform mediump mat4	myPMVMatrix;
uniform mediump mat4	myPMVMatrix2;
varying mediump vec2	myTexCoord;

void main(void)
{
	gl_Position = myPMVMatrix2 * myPMVMatrix * myVertex;
	myTexCoord = myUV.st;
}