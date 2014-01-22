' drawoval.bmx

' draws a pair of eyes using 4 DrawOval commands, 2 white, 2 blue
' positions the blue ovals so the eyes track the mouse

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	SetColor 255,255,255
	DrawOval 0,0,320,200
	DrawOval 320,0,320,200
	SetColor 0,0,255
	x=(MouseX()-320)/10
	y=(MouseY()-240)/10
	DrawOval 220-32+x,100+y,64,40
	DrawOval 420-32+x,100+y,64,40
	Flip
Wend
