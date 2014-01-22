' drawpoly.bmx

' draws a simple triangle using the
' DrawPoly command and an array of
' floats listed as 3 pairs of x,y
' coordinates

Local tri#[]=[0.0,0.0,100.0,100.0,0.0,100.0]

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	DrawPoly tri
	Flip
Wend
