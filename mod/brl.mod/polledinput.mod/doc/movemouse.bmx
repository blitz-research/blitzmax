' movemouse.bmx

' demonstrates using the mouse as a proportional controller
' by locking the mouse to the center of the screen and reporting
' MouseXSpeed and MouseYSpeed variables 

Global MouseXSpeed,MouseYSpeed

Function SampleMouse()
	MouseXSpeed=MouseX()-320
	MouseYSpeed=MouseY()-240
	MoveMouse 320,240
End Function

Graphics 640,480

HideMouse
MoveMouse 320,240

While Not KeyHit(KEY_ESCAPE)
	SampleMouse
	Cls
	DrawText "MouseXSpeed="+MouseXSpeed,0,0
	DrawText "MouseYSpeed="+MouseYSpeed,0,20
	Flip
Wend

