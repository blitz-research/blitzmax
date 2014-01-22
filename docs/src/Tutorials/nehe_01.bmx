
'Ok, this demo's a little pointless!
'
'All it does is show you how to open an OpenGL window
'
GLGraphics 640,480

While Not KeyHit( KEY_ESCAPE )

	glClear GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT	'Clear The Screen And The Depth Buffer
	
	Flip

Wend