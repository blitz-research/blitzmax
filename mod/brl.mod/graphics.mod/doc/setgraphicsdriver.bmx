
SetGraphicsDriver GLMax2DDriver()

Graphics 640,480
DrawText "OpenGL Max2D Graphics! Hit any key (next to the whatever key)...",0,0
Flip
WaitKey
EndGraphics

SetGraphicsDriver GLGraphicsDriver()

Graphics 640,480
glClear GL_COLOR_BUFFER_BIT
GLDrawText "'Raw' OpenGL Graphics! Hit any key...",0,0
Flip
WaitKey

