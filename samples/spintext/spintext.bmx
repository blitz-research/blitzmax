
Graphics 640,480

t$="***** Some spinny text *****"
w=TextWidth(t)
h=TextHeight(t)

r#=0

While Not KeyHit( KEY_ESCAPE )

	Cls
	
	r:+3
	SetOrigin 320,240
	SetHandle w/2,h/2
	SetTransform r,3,5

	SetColor 0,0,255
	DrawRect 0,0,w,h
	SetColor 255,255,255
	DrawText t,0,0

	SetOrigin 0,0
	SetHandle 0,0	
	SetTransform 0,1,1
	
	Flip

Wend
	