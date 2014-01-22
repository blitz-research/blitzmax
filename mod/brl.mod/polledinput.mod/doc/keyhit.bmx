' keyhit.bmx

' the following code draws a circle every time the
' program detects the spacebar has been pressed
' and exits when it detects the ESCAPE key has
' been pressed

graphics 640,480
while not keyhit(KEY_ESCAPE)
	cls
	if keyhit(KEY_SPACE) drawoval 0,0,640,480
	flip
wend
