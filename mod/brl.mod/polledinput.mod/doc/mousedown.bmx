' mousedown.bmx

graphics 640,480

while not keyhit(KEY_ESCAPE)
	cls
	if mousedown(1) drawrect 0,0,200,200
	if mousedown(2) drawrect 200,0,200,200
	if mousedown(3) drawrect 400,0,200,200
	flip
wend
