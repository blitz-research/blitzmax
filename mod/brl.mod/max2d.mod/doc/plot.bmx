' plot.bmx

' plots a cosine graph
' scrolls along the graph using an incrementing frame variable 

Graphics 640,480

While Not KeyHit(KEY_ESCAPE)
	Cls
	For x=0 To 640
		theta=x+frame
		y=240-Cos(theta)*240
		Plot x,y
	Next
	frame=frame+1
	Flip
Wend
