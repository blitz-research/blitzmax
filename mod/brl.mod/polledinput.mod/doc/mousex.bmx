' mousex.bmx

' the following tracks the position of the mouse

graphics 640,480
while not keyhit(KEY_ESCAPE)
	cls
	drawoval mousex()-10,mousey()-10,20,20
	flip
wend
