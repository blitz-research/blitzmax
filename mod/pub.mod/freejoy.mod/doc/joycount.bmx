' testjoy.bmx

Import Pub.FreeJoy

Strict

If Not JoyCount() RuntimeError "No joystick found!"

Graphics 640,480

Function drawprop(n$,p#,y)
	Local	w
	DrawText n$,0,y
	w=Abs(p)*256
	If p<0
		DrawRect 320-w,y,w,16
	Else
		DrawRect 320,y,w,16
	EndIf
End Function		

Local t=0

While Not KeyHit(KEY_ESCAPE)
	Cls
	
	SetColor 255,255,255
	Local n=JoyCount()
	DrawText "joycount="+n,0,0
	DrawText "JoyName(0)="+JoyName(0),0,20
	DrawText "JoyButtonCaps(0)="+Bin$(JoyButtonCaps(0)),0,40
	DrawText "JoyAxisCaps(0)="+Bin$(JoyAxisCaps(0)),0,60

	For Local i=0 To 31
		SetColor 255,255,255
		If JoyDown(i) SetColor 255,0,0
		DrawOval i*16,80,14,14
	Next
	
	SetColor 255,255,0
	drawprop "JoyX=",JoyX(0),100
	drawprop "JoyY:",JoyY(0),120
	drawprop "JoyZ:",JoyZ(0),140
	drawprop "JoyR:",JoyR(0),160
	drawprop "JoyU:",JoyU(0),180
	drawprop "JoyV:",JoyV(0),200
	drawprop "JoyHat:",JoyHat(0),220
	drawprop "JoyWheel:",JoyWheel(0),240
	
	DrawRect 0,280,t,10
	t=(t+1)&511
	
	Flip	
Wend

End
