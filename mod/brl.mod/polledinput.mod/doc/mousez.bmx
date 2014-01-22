' mousez.bmx

' prints mousez() the mousewheel position

Graphics 640,480
While Not keyhit(KEY_ESCAPE)
	cls
	drawtext "MouseZ()="+MouseZ(),0,0
	flip
Wend
