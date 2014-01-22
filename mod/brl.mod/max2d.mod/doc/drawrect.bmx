' drawrect.bmx

' draws a sequence of rectangles across the screen with
' increasing rotation and scale

' uses the frame variable to cycle through the values 0..9 for
' an animation effect between frames 

Graphics 640,480

SetBlend ALPHABLEND
SetAlpha 0.2

While Not KeyHit(KEY_ESCAPE)
	Cls
	DrawText "DrawRect Example",0,0
	For r=t To t+500 Step 10
		SetRotation r
		SetScale r/5,r/5
		DrawRect r,r,2,2
	Next
	t=t+1
	If t=10 t=0
	Flip	
Wend
