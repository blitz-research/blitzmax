Rem
ATan2 returns the Inverse Tangent of two variables
End Rem

function Angle!(x0!,y0!,x1!,y1!)
	return ATan2(y1-y0,x1-x0)
end function

graphics 640,480
while not keyhit(KEY_ESCAPE)
	cls
	x#=mousex()
	y#=mousey()
	drawline 320,240,x,y
	drawtext "Angle="+Angle(320,240,x,y),20,20
	flip
wend
