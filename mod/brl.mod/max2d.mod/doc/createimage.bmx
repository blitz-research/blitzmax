' createimage.bmx

' creates a 256x1 image with a black to blue color gradient

Const ALPHABITS=$ff000000

Graphics 640,480,32

image=CreateImage(256,1)
map=LockImage(image)
For i=0 To 255
	WritePixel(map,i,0,ALPHABITS|i)
Next
UnlockImage(image)

DrawImageRect image,0,0,640,480
DrawText "Blue Color Gradient",0,0

Flip

WaitKey