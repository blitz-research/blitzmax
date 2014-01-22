' drawline.bmx

' draws a cross hair at the mouse position using DrawLine

Graphics 640,480

HideMouse 

While Not KeyHit(KEY_ESCAPE)
	Cls
	x=MouseX()
	y=MouseY()
	DrawLine 320,240,x,y
	DrawLine x-2,y,x-10,y
	DrawLine x+2,y,x+10,y
	DrawLine x,y-2,x,y-10
	DrawLine x,y+2,x,y+10
	Flip
Wend
